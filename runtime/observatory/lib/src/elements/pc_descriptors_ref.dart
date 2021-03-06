// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:async';
import 'package:observatory/models.dart' as M
  show IsolateRef, PcDescriptorsRef;
import 'package:observatory/src/elements/helpers/rendering_scheduler.dart';
import 'package:observatory/src/elements/helpers/tag.dart';
import 'package:observatory/src/elements/helpers/uris.dart';

class PcDescriptorsRefElement extends HtmlElement implements Renderable {
  static const tag = const Tag<PcDescriptorsRefElement>('pc-ref-wrapped');

  RenderingScheduler<PcDescriptorsRefElement> _r;

  Stream<RenderedEvent<PcDescriptorsRefElement>> get onRendered =>
    _r.onRendered;

  M.IsolateRef _isolate;
  M.PcDescriptorsRef _descriptors;

  M.IsolateRef get isolate => _isolate;
  M.PcDescriptorsRef get descriptors => _descriptors;

  factory PcDescriptorsRefElement(M.IsolateRef isolate,
      M.PcDescriptorsRef descriptors, {RenderingQueue queue}) {
    assert(isolate != null);
    assert(descriptors != null);
    PcDescriptorsRefElement e = document.createElement(tag.name);
    e._r = new RenderingScheduler(e, queue: queue);
    e._isolate = isolate;
    e._descriptors = descriptors;
    return e;
  }

  PcDescriptorsRefElement.created() : super.created();

  @override
  void attached() {
    super.attached();
    _r.enable();
  }

  @override
  void detached() {
    super.detached();
    _r.disable(notify: true);
    children = [];
  }

  void render() {
    final text = (_descriptors.name == null || _descriptors.name == '')
      ? 'PcDescriptors'
      : _descriptors.name;
    children = [
      new AnchorElement(href: Uris.inspect(_isolate, object: _descriptors))
        ..text = text
    ];
  }
}
