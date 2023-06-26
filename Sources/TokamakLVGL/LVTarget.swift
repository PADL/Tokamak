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

final class LVTarget: Target, CustomStringConvertible {
  var object: LVObject!
  var view: AnyView

  init<V: View>(_ view: V, _ object: LVObject) {
    self.object = object
    self.view = AnyView(view)
  }

  init(object: LVObject) {
    self.object = object
    view = AnyView(EmptyView())
  }

  var description: String {
    "LVTarget(object: \(object!))"
  }
}

extension LVObject {
  var isContainer: Bool {
    childCount != 0
  }
}
