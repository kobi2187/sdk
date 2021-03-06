// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'package:observatory/models.dart' as M;
import 'package:observatory/src/elements/class_ref.dart';
import 'package:observatory/src/elements/code_ref.dart';
import 'package:observatory/src/elements/context_ref.dart';
import 'package:observatory/src/elements/error_ref.dart';
import 'package:observatory/src/elements/field_ref.dart';
import 'package:observatory/src/elements/function_ref.dart';
import 'package:observatory/src/elements/helpers/rendering_scheduler.dart';
import 'package:observatory/src/elements/helpers/uris.dart';
import 'package:observatory/src/elements/icdata_ref.dart';
import 'package:observatory/src/elements/instance_ref.dart';
import 'package:observatory/src/elements/megamorphiccache_ref.dart';
import 'package:observatory/src/elements/library_ref.dart';
import 'package:observatory/src/elements/local_var_descriptors_ref.dart';
import 'package:observatory/src/elements/objectpool_ref.dart';
import 'package:observatory/src/elements/pc_descriptors_ref.dart';
import 'package:observatory/src/elements/script_ref.dart';
import 'package:observatory/src/elements/sentinel_value.dart';
import 'package:observatory/src/elements/type_arguments_ref.dart';
import 'package:observatory/src/elements/token_stream_ref.dart';
import 'package:observatory/src/elements/unknown_ref.dart';

Element anyRef(M.IsolateRef isolate, ref,
    M.InstanceRepository instances, {RenderingQueue queue}) {
  if (ref is M.Guarded) {
    return anyRef(isolate, ref.asSentinel ?? ref.asValue, instances,
        queue: queue);
  } else if (ref is M.ObjectRef) {
    if (ref is M.ClassRef) {
      return new ClassRefElement(isolate, ref, queue: queue);
    } else if (ref is M.CodeRef) {
      return new CodeRefElement(isolate, ref, queue: queue);
    } else if (ref is M.ContextRef) {
      return new ContextRefElement(isolate, ref, queue: queue);
    } else if (ref is M.Error ) {
      return new ErrorRefElement(ref, queue: queue);
    } else if (ref is M.FieldRef) {
      return new FieldRefElement(isolate, ref, instances, queue: queue);
    }  else if (ref is M.FunctionRef) {
      return new FunctionRefElement(isolate, ref, queue: queue);
    } else if (ref is M.ICDataRef) {
      return new ICDataRefElement(isolate, ref, queue: queue);
    } else if (ref is M.InstanceRef) {
      return new InstanceRefElement(isolate, ref, instances, queue: queue);
    } else if (ref is M.LibraryRef) {
      return new LibraryRefElement(isolate, ref, queue: queue);
    } else if (ref is M.LocalVarDescriptorsRef) {
      return new LocalVarDescriptorsRefElement(isolate, ref, queue: queue);
    } else if (ref is M.MegamorphicCacheRef) {
      return new MegamorphicCacheRefElement(isolate, ref, queue: queue);
    } else if (ref is M.ObjectPoolRef) {
      return new ObjectPoolRefElement(isolate, ref, queue: queue);
    } else if (ref is M.PcDescriptorsRef) {
      return new PcDescriptorsRefElement(isolate, ref, queue: queue);
    } else if (ref is M.Sentinel) {
      return new SentinelValueElement(ref, queue: queue);
    } else if (ref is M.ScriptRef) {
      return new ScriptRefElement(isolate, ref, queue: queue);
    } else if (ref is M.TypeArgumentsRef) {
      return new TypeArgumentsRefElement(isolate, ref, queue: queue);
    } else if (ref is M.TokenStreamRef) {
      return new TokenStreamRefElement(isolate, ref, queue: queue);
    } else if (ref is M.UnknownObjectRef) {
      return new UnknownObjectRefElement(isolate, ref, queue: queue);
    } else {
      return new AnchorElement(href: Uris.inspect(isolate, object: ref))
        ..text = 'object';
    }
  }
  throw new Exception('Unknown runtimeType (${ref.runtimeType})');
}
