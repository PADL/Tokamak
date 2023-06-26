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

private func translateCoordinate(_ coordinate: CGFloat?) -> lv_coord_t {
  let lvCoordinate: lv_coord_t

  if let coordinate {
    if coordinate == .infinity {
      lvCoordinate = .maxCoordinate
    } else {
      lvCoordinate = lv_coord_t(coordinate)
    }
  } else {
    lvCoordinate = .sizeContent
  }

  return lvCoordinate
}

extension _FrameLayout: LVObjectModifier {
  func modify(object: LVObject) {
    object.size = LVSize(
      width: translateCoordinate(width),
      height: translateCoordinate(height)
    )
  }
}

extension _FlexFrameLayout: LVObjectModifier {
  func modify(object: LVObject) {
    object.withLocalStyle { style in
      style.alignment = alignment.lv_alignment
      style.minWidth = translateCoordinate(minWidth)
      style.width = translateCoordinate(idealWidth)
      style.maxWidth = translateCoordinate(maxWidth)
      style.minHeight = translateCoordinate(minHeight)
      style.height = translateCoordinate(idealHeight)
      style.maxHeight = translateCoordinate(maxHeight)
    }
  }
}

extension Color {
  func lvValue(_ environment: EnvironmentValues) -> (LVColor, lv_opa_t) {
    let rgba = _ColorProxy(self).resolve(in: environment)
    return (
      LVColor(
        red: UInt8(rgba.red * 255),
        green: UInt8(rgba.green * 255),
        blue: UInt8(rgba.blue * 255)
      ),
      UInt8(rgba.opacity * 255)
    )
  }
}

extension _OverlayModifier: LVStyleModifier, LVObjectModifier
  where Overlay == _ShapeView<_StrokedShape<TokamakCore.Rectangle._Inset>, Color>
{
  var lvStyle: LVStyle {
    let lvStyle = LVStyle()
    // FIXME: check conversion ratio
    lvStyle.borderWidth = lv_coord_t(overlay.shape.style.lineWidth)
    (lvStyle.borderColor, lvStyle.borderOpacity) = overlay.style.lvValue(environment)
    return lvStyle
  }
}

extension _BackgroundModifier: LVStyleModifier, LVObjectModifier where Background == Color {
  var lvStyle: LVStyle {
    let lvStyle = LVStyle()
    (lvStyle.backgroundColor, lvStyle.backgroundOpacity) = background.lvValue(environment)
    return lvStyle
  }
}
