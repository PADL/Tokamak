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
//

import CLVGL
import Foundation
import LVGL
import TokamakCore

extension LVButton {
  func bind(action: @escaping () -> ()) {
    onEvent = { event in
      switch event.code {
      case LV_EVENT_PRESSED:
        action()
      default:
        break
      }
    }
  }
}

extension _Button: AnyLVObject, ParentView {
  func build(with parent: LVObject) -> LVObject {
    let button = LVButton(with: parent)
    button.bind(action: action)
    return button
  }

  func update(target: LVTarget) {
    let button = target.object as! LVButton
    button.bind(action: action)
  }

  public var children: [AnyView] {
    [AnyView(label)]
  }
}
