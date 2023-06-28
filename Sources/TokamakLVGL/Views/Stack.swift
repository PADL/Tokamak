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
import Foundation
import LVGL
import TokamakCore

class LVStackContainer: LVContainer {
  convenience init(
    flow: lv_flex_flow_t,
    padding: Int16,
    alignment: Alignment,
    with parent: LVObject!
  ) {
    self.init(with: parent)

    withLocalStyle { style in
      style.flexMainPlace = LV_FLEX_ALIGN_SPACE_EVENLY.rawValue
      style.flexCrossPlace = LV_FLEX_ALIGN_SPACE_EVENLY.rawValue
      style.flexTrackPlace = LV_FLEX_ALIGN_SPACE_AROUND.rawValue
      style.flexFlow = flow.rawValue
      style.flexGrow = 1
      switch flow {
      case LV_FLEX_FLOW_ROW:
        style.rowPadding = padding
      case LV_FLEX_FLOW_COLUMN:
        style.columnPadding = padding
      default:
        break
      }
    }

    set(layout: LV_LAYOUT_FLEX)
    set(flag: .layout1) // LV_OBJ_FLAG_FLEX_IN_NEW_TRACK
    align(to: alignment.lv_alignment)
  }

  required init(with parent: LVObject!) {
    super.init(with: parent)
  }
}

protocol StackProtocol {
  var alignment: Alignment { get }
}

struct Box<Content: View>: View, ParentView, AnyLVObject, StackProtocol {
  let content: Content
  let flow: lv_flex_flow_t
  let padding: Int16
  let alignment: Alignment

  func build(with parent: LVObject) -> LVObject {
    LVStackContainer(flow: flow, padding: padding, alignment: alignment, with: parent)
  }

  func update(target: LVTarget) {}

  var body: Never {
    neverBody("Box")
  }

  public var children: [AnyView] {
    [AnyView(content)]
  }
}

extension VStack: LVPrimitive {
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    AnyView(
      Box(
        content: content,
        flow: LV_FLEX_FLOW_ROW,
        padding: Int16(_VStackProxy(self).spacing),
        alignment: .init(horizontal: alignment, vertical: .center)
      )
    )
  }
}

extension HStack: LVPrimitive {
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    AnyView(
      Box(
        content: content,
        flow: LV_FLEX_FLOW_COLUMN,
        padding: Int16(_HStackProxy(self).spacing),
        alignment: .init(horizontal: .center, vertical: alignment)
      )
    )
  }
}

extension Alignment {
  var lv_alignment: lv_align_t {
    switch horizontal {
    case .center:
      switch vertical {
      case .center:
        return lv_align_t(LV_ALIGN_CENTER)
      case .top:
        return lv_align_t(LV_ALIGN_TOP_MID)
      case .bottom:
        return lv_align_t(LV_ALIGN_BOTTOM_MID)
      default:
        return lv_align_t(LV_ALIGN_DEFAULT)
      }
    case .leading:
      switch vertical {
      case .center:
        return lv_align_t(LV_ALIGN_LEFT_MID)
      case .top:
        return lv_align_t(LV_ALIGN_TOP_LEFT)
      case .bottom:
        return lv_align_t(LV_ALIGN_BOTTOM_LEFT)
      default:
        return lv_align_t(LV_ALIGN_DEFAULT)
      }
    case .trailing:
      switch vertical {
      case .center:
        return lv_align_t(LV_ALIGN_RIGHT_MID)
      case .top:
        return lv_align_t(LV_ALIGN_TOP_RIGHT)
      case .bottom:
        return lv_align_t(LV_ALIGN_BOTTOM_RIGHT)
      default:
        return lv_align_t(LV_ALIGN_DEFAULT)
      }
    default:
      return lv_align_t(LV_ALIGN_DEFAULT)
    }
  }
}
