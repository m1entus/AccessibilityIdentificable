# AccessibilityIdentificable

Identifiers for UI testing: a reflection based approach

One of the most annoying things about UI Testing in iOS is the need to assign Accessibility Identifiers to views that are hard to access otherwise.

#### What if we could generate and assign Accessibility Identifiers automatically?

Usually, assigning an Accessibility Identifier to a View is rather straightforward and it is creating a lot of boilerplate code…
```swift
override func viewDidLoad() {
    titleLabel.accessibilityIdentifier          = "SomethingViewController.titleLabel"
    descriptionLabel.accessibilityIdentifier    = "SomethingViewController.descriptionLabel"
    doneButton.accessibilityIdentifier          = "SomethingViewController.doneButton"
}
```

I was searching for some solution but they were not fully satisfy me, but i used them to create this one.
I have used Swift’s reflection API: Mirror with Objective-C swizzling technique and everything is completed by the code generator [Sourcery](https://github.com/krzysztofzablocki/Sourcery) to have direct reference from UITests.

```swift
@objc public protocol AccessibilityIdentificable { /* NOOP */ }

public extension AccessibilityIdentificable {

    func generateAccessibilityIdentifiers() {
        let mirror = Mirror(reflecting: self)

        for child in mirror.children {
            guard let identifier = child.label?.replacingOccurrences(of: ".storage", with: "")
                    .replacingOccurrences(of: "$__lazy_storage_$_", with: "") else {
                continue
            }

            if let view = child.value as? UIView {
                view.accessibilityIdentifier = "\(type(of: self)).\(identifier)"

            } else if let array = child.value as? [UIView] {
                for (index, object) in array.enumerated() {
                    object.accessibilityIdentifier = "\(type(of: self)).\(identifier)_\(index)"
                }
            }
        }
    }
}
```

Usage is straightforward, all properties from classes that implements `AccessibilityIdentificable` protocol will have generated accessibility identifiers. Just implement `AccessibilityIdentificable` to UIViewController or custom object and add `AccessibilityInjector.inject()` line for swizzling UIViewController `viewDidLoad`, `init(frame:)` and `init(coder:)` of UIView. We need that to call automatically `generateAccessibilityIdentifiers` from `AccessibilityIdentificable` after these methods and assign `accessibilityIdentifier` to each UIView.

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.

    if ProcessInfo.processInfo.arguments.contains("-xcuitest") {
        AccessibilityInjector.inject()
    }
    return true
}
```

```swift
class CustomView: UIView, AccessibilityIdentificable {
    private var label: UILabel = UILabel(frame: .zero) #--> will set accessibilityIdentifier: CustomView.label
}
```

To be able to find and generate all classes that implements `AccessibilityIdentificable` you need to add `Build Phases -> Run Script` which will change depends on project structure and for me look like this:

```sh
#/bin/sh

$PODS_ROOT/Sourcery/bin/sourcery --sources $SRCROOT --sources $SRCROOT/../Source --output $SRCROOT/AccessibilityIdentificableUITests/Generated --templates $SRCROOT/../Template
```

Sourcery in UITests will generate classes:

```swift
// @generated
// MARK: - Identifiers > CustomView

public extension Identifiers {
    struct CustomView {
        public static var label = "CustomView.label"
    }
}
```

Then inside UITests you can use this identifiers:

```swift
func testExample() throws {
    // UI tests must launch the application that they test.
    let app = XCUIApplication()
    app.launchArguments.append("-xcuitest")
    app.launch()

    XCTAssert(app.staticTexts[Identifiers.CustomView.label].exists)
}
```

In addition to that if you would like to add custom accessibility identifiers for some reasons, i prepared `@propertyWrapper` named `@AccessibilityIdentify` which you can use setting custom identifiers.

```swift
class ViewController: UIViewController {

    @AccessibilityIdentify(identifier: "custom_id")
    var testView = UIView()
}
```
