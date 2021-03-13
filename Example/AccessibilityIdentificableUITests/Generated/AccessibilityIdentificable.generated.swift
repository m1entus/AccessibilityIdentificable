// Generated using Sourcery 1.3.4 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// @generated

// MARK: - Identifiers

public enum Identifiers {
    // NOOP - just namespace
}

// MARK: - ArrayIdentifiers

public struct ArrayIdentifiers {
    let value: String

    public subscript(index: Int) -> String {
        return value + "_\(index)"
    }
}

// MARK: - Identifiers > CustomView

public extension Identifiers {
    struct CustomView {
        public static var label = "CustomView.label"
    }
}

// MARK: - Identifiers > ViewController

public extension Identifiers {
    struct ViewController {
        public static var testView = "ViewController.testView"
        public static var viewArray = ArrayIdentifiers(value: "ViewController.viewArray")
        public static var button = "ViewController.button"
    }
}

