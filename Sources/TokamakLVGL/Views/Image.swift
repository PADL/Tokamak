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
//  Created by Morten Bek Ditlevsen on 14/12/2020.
//

import Foundation
import LVGL
import TokamakCore

extension Image: AnyLVObject {
  func build(with parent: LVObject) -> LVObject {
    LVImage(with: parent)
  }

  func update(target: LVTarget) {
    let proxy = _ImageProxy(self)
    let image = target.object as! LVImage
    image.source = .file(imagePath(for: proxy))
  }

  func imagePath(for proxy: _ImageProxy) -> String {
    let resolved = proxy.provider.resolve(in: proxy.environment)
    switch resolved.storage {
    case let .named(name, bundle),
         let .resizable(.named(name, bundle), _, _):
      return bundle?.path(forResource: name, ofType: nil) ?? name
    default: return ""
    }
  }
}
