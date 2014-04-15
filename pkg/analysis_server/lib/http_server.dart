// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library http.server;

import 'dart:io';

import 'package:analysis_server/src/channel.dart';
import 'package:analysis_server/src/get_handler.dart';
import 'package:analysis_server/src/socket_server.dart';
import 'package:args/args.dart';

/**
 * Instances of the class [HttpServer] implement a simple HTTP server. The
 * primary responsibility of this server is to listen for an UPGRADE request and
 * to start an analysis server.
 */
class HttpAnalysisServer {
  /**
   * The name of the application that is used to start a server.
   */
  static const BINARY_NAME = 'server';

  /**
   * The name of the option used to print usage information.
   */
  static const String HELP_OPTION = "help";

  /**
   * The name of the option used to specify the port to which the server will
   * connect.
   */
  static const String PORT_OPTION = "port";

  /**
   * An object that can handle either a WebSocket connection or a connection
   * to the client over stdio.
   */
  SocketServer socketServer = new SocketServer();

  /**
   * An object that can handle GET requests.
   */
  GetHandler getHandler;

  /**
   * Initialize a newly created HTTP server.
   */
  HttpAnalysisServer();

  /**
   * Use the given command-line arguments to start this server.
   */
  void start(List<String> args) {
    ArgParser parser = new ArgParser();
    parser.addFlag(
        HELP_OPTION,
        help: "print this help message without starting a server",
        defaultsTo: false,
        negatable: false);
    parser.addOption(
        PORT_OPTION,
        help: "[port] the port on which the server will listen");

    ArgResults results = parser.parse(args);
    if (results[HELP_OPTION]) {
      _printUsage(parser);
      return;
    }
    if (results[PORT_OPTION] == null) {
      print('Missing required port number');
      print('');
      _printUsage(parser);
      exitCode = 1;
      return;
    }

    try {
      int port = int.parse(results[PORT_OPTION]);
      HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, port).then(_handleServer);
      print('Listening on port $port');
    } on FormatException {
      print('Invalid port number: ${results[PORT_OPTION]}');
      print('');
      _printUsage(parser);
      exitCode = 1;
      return;
    }
  }

  /**
   * Attach a listener to a newly created HTTP server.
   */
  void _handleServer(HttpServer httServer) {
    httServer.listen((HttpRequest request) {
      List<String> updateValues = request.headers[HttpHeaders.UPGRADE];
      if (updateValues != null && updateValues.indexOf('websocket') >= 0) {
        WebSocketTransformer.upgrade(request).then((WebSocket websocket) {
          _handleWebSocket(websocket);
        });
      } else if (request.method == 'GET') {
        _handleGetRequest(request);
      } else {
        _returnUnknownRequest(request);
      }
    });
  }

  /**
   * Handle a GET request received by the HTTP server.
   */
  void _handleGetRequest(HttpRequest request) {
    if (getHandler == null) {
      getHandler = new GetHandler(socketServer);
    }
    getHandler.handleGetRequest(request);
  }

  /**
   * Handle an UPGRADE request received by the HTTP server by creating and
   * running an analysis server on a [WebSocket]-based communication channel.
   */
  void _handleWebSocket(WebSocket socket) {
    socketServer.createAnalysisServer(new WebSocketServerChannel(socket));
  }

  /**
   * Print information about how to use the server.
   */
  void _printUsage(ArgParser parser) {
    print('Usage: $BINARY_NAME [flags]');
    print('');
    print('Supported flags are:');
    print(parser.getUsage());
  }

  /**
   * Return an error in response to an unrecognized request received by the HTTP
   * server.
   */
  void _returnUnknownRequest(HttpRequest request) {
    HttpResponse response = request.response;
    response.statusCode = HttpStatus.NOT_FOUND;
    response.headers.add(HttpHeaders.CONTENT_TYPE, "text/plain");
    response.write('Not found');
    response.close();
  }
}
