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

extension Text: AnyLVObject {
  func build(with parent: LVObject) -> LVObject {
    let label = LVLabel(with: parent)
    label.text = _TextProxy(self).rawText
    return label
  }

  func update(target: LVTarget) {
    let label = target.object as! LVLabel
    label.text = _TextProxy(self).rawText
  }
}
