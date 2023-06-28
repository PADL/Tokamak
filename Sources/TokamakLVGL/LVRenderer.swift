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
import Dispatch
import LVGL
@_spi(TokamakCore) import TokamakCore

// marker protocol for content sizing
protocol LVContentSizeable {}

// container expands to fill parent size, is this correct?
class LVContainer: LVObject, LVContentSizeable {
  required init(with parent: LVObject!) {
    super.init(with: parent)
    size = parent.size
  }
}

class LVApplication: LVObject, LVContentSizeable {}

extension EnvironmentValues {
  static var defaultEnvironment: Self {
    var environment = EnvironmentValues()
    environment[_ColorSchemeKey.self] = .light
    return environment
  }
}

extension LVStyle {
  // swiftformat:disable redundantSelf
  convenience init(colorScheme: ColorScheme) {
    self.init()

    switch colorScheme {
    case .dark:
      self.backgroundColor = LVColor.black
      self.textColor = LVColor.white
    case .light:
      self.backgroundColor = LVColor.white
      self.textColor = LVColor.black
    }
    self.backgroundOpacity = lv_opa_t(LV_OPA_COVER)
  }
}

final class LVRenderer: Renderer {
  private(set) var reconciler: StackReconciler<LVRenderer>?

  typealias TargetType = LVTarget

  private var theme: LVTheme
  private var application: LVApplication

  init<A: App>(
    _ app: A,
    _ rootEnvironment: EnvironmentValues? = nil
  ) {
    let environment: EnvironmentValues = .defaultEnvironment.merging(rootEnvironment)
    let runLoop = LVRunLoop.shared // FIXME: needs to be called at top to do global initialization
    let activeScreen = LVScreen.active

    theme = LVTheme { _, object in
      if object == activeScreen {
        object.append(style: LVStyle(colorScheme: environment.colorScheme))
      }
    }
    LVDisplay.default.theme = theme

    application = LVApplication(with: activeScreen)

    reconciler = StackReconciler(
      app: app,
      target: LVTarget(object: application),
      environment: environment,
      renderer: self,
      scheduler: { next in
        DispatchQueue.main.async {
          next()
          activeScreen.clear(flag: LVFlags.hidden)
        }
      }
    )
    runLoop.run()
  }

  public func mountTarget(
    before sibling: LVTarget?,
    to parent: LVTarget,
    with host: MountedHost
  ) -> LVTarget? {
    guard let anyObject = mapAnyView(
      host.view,
      transform: { (object: AnyLVObject) in object }
    ) else {
      if mapAnyView(host.view, transform: { (view: ParentView) in view }) != nil {
        return parent
      } else {
        return nil
      }
    }

    let object = anyObject.build(with: parent.object)
    debugPrint("LVGL renderer mounting \(object)")
    object.debugViewTree()

    if let stack = mapAnyView(parent.view, transform: { (view: StackProtocol) in view }) {
      object.align(to: stack.alignment.lv_alignment)
    }

    if let sibling {
      let siblingIndex = sibling.object.index
      object.move(to: siblingIndex)
    }

    object.update()
    return LVTarget(host.view, object)
  }

  func update(
    target: LVTarget,
    with host: MountedHost
  ) {
    precondition(target.object != nil)
    debugPrint("LVGL renderer updating \(target)")

    guard let anyObject = mapAnyView(host.view, transform: { (object: AnyLVObject) in object })
    else {
      return
    }

    anyObject.update(target: target)
    target.object.update()
  }

  func unmount(
    target: LVTarget,
    from parent: LVTarget,
    with task: UnmountHostTask<LVRenderer>
  ) {
    defer { task.finish() }

    guard mapAnyView(task.host.view, transform: { (object: AnyLVObject) in object }) != nil
    else { return }

    if let object = target.object {
      debugPrint("LVGL renderer unmounting \(object) from \(parent)")
      object.set(flag: .hidden)
      object.parent = nil
      object.invalidate()
    }
    target.object = nil
  }

  public func isPrimitiveView(_ type: Any.Type) -> Bool {
    type is LVPrimitive.Type
  }

  public func primitiveBody(for view: Any) -> AnyView? {
    (view as? LVPrimitive)?.renderedBody
  }
}

protocol LVPrimitive {
  var renderedBody: AnyView { get }
}

extension LVObject {
  func update() {
    // FIXME: is this correct
    if self is any LVContentSizeable {
      self.size = .content
    }
    updateLayout()
  }
}
