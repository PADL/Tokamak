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

extension LVSwitch {
  func bind(isOn: Binding<Bool>) {
    setIsOn(isOn.wrappedValue)
    onEvent = { event in
      switch event.code {
      case LV_EVENT_VALUE_CHANGED:
        isOn.wrappedValue = Int(self.state) & LV_STATE_CHECKED != 0
      default:
        break
      }
    }
  }

  private func setIsOn(_ isOn: Bool) {
    if isOn {
      set(state: lv_state_t(LV_STATE_CHECKED))
    } else {
      set(state: lv_state_t(LV_STATE_DEFAULT))
    }
  }
}

extension Toggle: AnyLVObject {
  func build(with parent: LVObject) -> LVObject {
    let `switch` = LVSwitch(with: parent)
    let proxy = _ToggleProxy(self)
    `switch`.bind(isOn: proxy.isOn)
    return `switch`
  }

  func update(target: LVTarget) {
    let `switch` = target.object as! LVSwitch
    let proxy = _ToggleProxy(self)
    `switch`.bind(isOn: proxy.isOn)
  }
}
