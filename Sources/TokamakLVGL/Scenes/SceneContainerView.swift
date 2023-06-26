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
//  Created by Carson Katri on 10/10/20.
//

import CLVGL
import LVGL
import TokamakCore

struct SceneContainerView<Content: View>: View, AnyLVObject {
  let content: Content

  func build(with parent: LVObject) -> LVObject {
    LVScreen(with: parent)
  }

  var body: Never {
    neverBody("SceneContainerView")
  }

  func update(target: LVTarget) {}
}
