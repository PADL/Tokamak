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

import CLVGL
import LVGL
import TokamakCore

extension LVRoller {
  func bind(_ block: @escaping (String?) -> ()) {
    onEvent = { event in
      switch event.code {
      case LV_EVENT_VALUE_CHANGED:
        block(self.selectedString)
      default:
        break
      }
    }
  }
}

extension _PickerContainer: AnyLVObject {
  func build(with parent: LVObject) -> LVObject {
    let roller = LVRoller(with: parent)
    var options = [String]()
    for element in elements {
      if let text = mapAnyView(element.anyContent, transform: { (view: Text) in view }) {
        options.append(_TextProxy(text).rawText)
      }
    }
    roller.options = options
    return roller
  }

  func update(target: LVTarget) {
    let roller = target.object as! LVRoller
    updateSelection(of: roller)
  }

  func updateSelection(of roller: LVRoller) {
    guard let activeElement = elements.firstIndex(where: {
      guard let selectedValue = $0.anyId as? SelectionValue else { return false }
      return selectedValue == selection
    }) else { return }

    roller.selected = UInt16(activeElement)
  }

  func bind(_ roller: LVRoller) {
    roller.bind { selectedString in
      let element = elements.first {
        guard let text = mapAnyView($0.anyContent, transform: { (view: Text) in view })
        else { return false }
        return _TextProxy(text).rawText == selectedString
      }
      if let selectedValue = element?.anyId as? SelectionValue {
        selection = selectedValue
      }
    }
  }
}
