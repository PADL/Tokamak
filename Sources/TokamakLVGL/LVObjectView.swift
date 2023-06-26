// Copyright 2023 Tokamak contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import LVGL
import TokamakCore

protocol AnyLVObject {
  func build(with: LVObject) -> LVObject
  func update(target: LVTarget)
}

struct LVObjectView<Content: View>: View, AnyLVObject, ParentView {
  let build: (LVObject) -> LVObject
  let update: (LVTarget) -> ()
  let content: Content

  init(
    build: @escaping (LVObject) -> LVObject,
    update: @escaping (LVTarget) -> () = { _ in },
    @ViewBuilder content: () -> Content
  ) {
    self.build = build
    self.content = content()
    self.update = update
  }

  func build(with parent: LVObject) -> LVObject {
    build(parent)
  }

  func update(target: LVTarget) {
    update(target)
  }

  var body: Never {
    neverBody("LVObjectView")
  }

  var children: [AnyView] {
    [AnyView(content)]
  }
}
