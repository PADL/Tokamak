// Copyright 2020 Tokamak contributors
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

protocol LVObjectModifier {
  func modify(object: LVObject)
}

protocol LVStyleModifier {
  var lvStyle: LVStyle { get }
}

extension LVStyleModifier {
  func modify(object: LVObject) {
    object.append(style: lvStyle)
  }
}

extension ModifiedContent: LVPrimitive where Content: View {
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    guard let objectModifier = modifier as? LVObjectModifier else {
      return AnyView(content)
    }
    let anyObject: AnyLVObject
    if let anyView = content as? LVPrimitive,
       let _anyObject = mapAnyView(
         anyView.renderedBody,
         transform: { (object: AnyLVObject) in object }
       )
    {
      anyObject = _anyObject
    } else if let _anyObject = content as? AnyLVObject {
      anyObject = _anyObject
    } else {
      return AnyView(content)
    }

    let build: (LVObject) -> LVObject = { object in
      objectModifier.modify(object: object)
      return object
    }

    let update: (LVTarget) -> () = { target in
      anyObject.update(target: target)
      objectModifier.modify(object: target.object)
    }

    if let parentView = anyObject as? ParentView, parentView.children.count > 1 {
      return AnyView(
        LVObjectView(
          build: build,
          update: update,
          content: {
            ForEach(Array(parentView.children.enumerated()), id: \.offset) { _, view in
              view
            }
          }
        )
      )
    } else if let parentView = anyObject as? ParentView, parentView.children.count == 1 {
      return AnyView(
        LVObjectView(
          build: build,
          update: update,
          content: {
            parentView.children[0]
          }
        )
      )
    } else {
      return AnyView(
        LVObjectView(
          build: build,
          update: update,
          content: {
            EmptyView()
          }
        )
      )
    }
  }
}
