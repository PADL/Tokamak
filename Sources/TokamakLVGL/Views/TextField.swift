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

extension LVTextArea {
  private func bind(textBinding: Binding<String>) {
    onEvent = { event in
      switch event.code {
      case LV_EVENT_VALUE_CHANGED:
        textBinding.wrappedValue = self.text
      default:
        break
      }
    }
  }

  static func build(
    with parent: LVObject,
    textBinding: Binding<String>,
    label: _TextProxy,
    secure: Bool = false
  ) -> Self {
    let textArea = Self(with: parent)
    textArea.text = textBinding.wrappedValue
    textArea.placeholderText = label.rawText
    textArea.passwordMode = secure
    textArea.bind(textBinding: textBinding)
    return textArea
  }

  func update(
    textBinding: Binding<String>,
    label: _TextProxy
  ) {
    text = textBinding.wrappedValue
    placeholderText = label.rawText
    bind(textBinding: textBinding) // TODO: GTK backend doesn't do this
  }
}

extension SecureField: LVPrimitive where Label == Text {
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    let proxy = _SecureFieldProxy(self)
    return AnyView(LVObjectView(build: { parent in
      LVTextArea.build(
        with: parent,
        textBinding: proxy.textBinding,
        label: proxy.label,
        secure: true
      )
    }, update: { target in
      let textArea = target.object as! LVTextArea
      textArea.update(textBinding: proxy.textBinding, label: proxy.label)
    }) {})
  }
}

extension TextField: LVPrimitive where Label == Text {
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    let proxy = _TextFieldProxy(self)
    return AnyView(LVObjectView(build: { parent in
      LVTextArea.build(with: parent, textBinding: proxy.textBinding, label: _TextProxy(proxy.label))
    }, update: { target in
      let textArea = target.object as! LVTextArea
      textArea.update(textBinding: proxy.textBinding, label: _TextProxy(proxy.label))
    }) {})
  }
}
