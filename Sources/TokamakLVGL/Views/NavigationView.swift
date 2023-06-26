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

import LVGL
import TokamakCore

protocol LVStackProtocol {}

extension NavigationView: LVPrimitive {
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    let proxy = _NavigationViewProxy(self)
    return AnyView(HStack {
      proxy.content
        .environmentObject(proxy.context)
      proxy.destination
    }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity))
  }
}

extension NavigationLink: LVPrimitive {
  @_spi(TokamakCore)
  public var renderedBody: AnyView {
    let proxy = _NavigationLinkProxy(self)
    return AnyView(Button(action: { proxy.activate() }) {
      proxy.label
    })
  }
}
