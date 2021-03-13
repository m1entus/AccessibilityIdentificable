//
//  AccessibilityIdentificable.swift
//
//  Created by Michal Zaborowski on 2021-03-13.
//  Copyright (c) 2021 Michał Zaborowski. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

@objc public protocol AccessibilityIdentificable { /* NOOP */ }

/*
 For let list = [UILabel(), UILabel()] the implementation above generate identifiers for incremental variable name ex. type.label_0, type.label_1
 */
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

/*
 Because of limitations of Sourcery, we are not able to check if property inherits from UIView, because Apple UIKit classes are unknown for Sourcery.
 Sourcery is able to detect classes that we defined,
 so we are going to make extension of UIView to detect our custom defined classes that inherits from UIView
 */
protocol UIViewAccessibilityIdentificable { /* NOOP */ }
extension UIView: UIViewAccessibilityIdentificable { /* NOOP */ }
