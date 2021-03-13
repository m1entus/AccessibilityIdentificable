//
//  AccessibilityInjector.swift
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

public final class AccessibilityInjector {
    private static func classesConforming(protocol: Protocol) -> [AnyClass] {

        let classesCount = objc_getClassList(nil, 0)

        guard classesCount > 0 else {
            return []
        }

        let allClasses = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(classesCount))
        defer { free(allClasses) }

        objc_getClassList(AutoreleasingUnsafeMutablePointer(allClasses), classesCount)

        var classes = [AnyClass]()
        for index in 0..<classesCount {
            guard let currentClass: AnyClass = allClasses[Int(index)] else {
                continue
            }
            if class_conformsToProtocol(currentClass, `protocol`) {
                classes.append(currentClass)
            }
        }
        return classes
    }

    /*
    Swizzle UIViewController.viewDidLoad, UIView.init(frame:), UIView.init(coder:)
    Only for objects that conforming to AccessibilityIdentificable
    */
    public static func inject() {
        let classes = AccessibilityInjector.classesConforming(protocol: AccessibilityIdentificable.self)
        let viewControllerSubclasses = classes.compactMap { $0 as? UIViewController.Type }
        let viewSubclasses = classes.compactMap { $0 as? UIView.Type }

        injectViewInitWithFrame(into: viewSubclasses) {
            ($0 as? AccessibilityIdentificable)?.generateAccessibilityIdentifiers()
        }
        injectViewInitWithCoder(into: viewSubclasses) {
            ($0 as? AccessibilityIdentificable)?.generateAccessibilityIdentifiers()
        }
        injectViewDidLoad(into: viewControllerSubclasses) {
            ($0 as? AccessibilityIdentificable)?.generateAccessibilityIdentifiers()
        }
    }

    private static func injectViewInitWithFrame(into supportedClasses: [UIView.Type], injection: @escaping (UIView) -> Void) {

        let selector = #selector(UIView.init(frame:))

        typealias FunctionReference = @convention(c)(UIView, Selector, CGRect) -> UIView

        for klass in supportedClasses {
            guard let originalMethod = class_getInstanceMethod(klass, selector) else {
                fatalError("\(selector) must be implemented")
            }

            var originalIMP: IMP? = nil
            let swizzledViewDidLoadBlock: @convention(block) (UIView, CGRect) -> UIView = { receiver, rect in

                if let originalIMP = originalIMP {
                    let castedIMP = unsafeBitCast(originalIMP, to: FunctionReference.self)
                    let returnValue = castedIMP(receiver, selector, rect)

                    injection(receiver)

                    return returnValue
                } else {
                    fatalError("Original implementation not found")
                }
            }

            let swizzledIMP = imp_implementationWithBlock(unsafeBitCast(swizzledViewDidLoadBlock, to: AnyObject.self))
            originalIMP = method_setImplementation(originalMethod, swizzledIMP)
        }
    }

    private static func injectViewInitWithCoder(into supportedClasses: [UIView.Type], injection: @escaping (UIView) -> Void) {

        let selector = #selector(UIView.init(coder:))

        typealias FunctionReference = @convention(c)(UIView, Selector, NSCoder) -> UIView

        for klass in supportedClasses {
            guard let originalMethod = class_getInstanceMethod(klass, selector) else {
                fatalError("\(selector) must be implemented")
            }

            var originalIMP: IMP? = nil
            let swizzledViewDidLoadBlock: @convention(block) (UIView, NSCoder) -> UIView = { receiver, rect in

                if let originalIMP = originalIMP {
                    let castedIMP = unsafeBitCast(originalIMP, to: FunctionReference.self)
                    let returnValue = castedIMP(receiver, selector, rect)

                    injection(receiver)

                    return returnValue
                } else {
                    fatalError("Original implementation not found")
                }
            }

            let swizzledIMP = imp_implementationWithBlock(unsafeBitCast(swizzledViewDidLoadBlock, to: AnyObject.self))
            originalIMP = method_setImplementation(originalMethod, swizzledIMP)
        }
    }

    private static func injectViewDidLoad(into classes: [UIViewController.Type], injection: @escaping (UIViewController) -> Void) {
        let selector = #selector(UIViewController.viewDidLoad)

        for klass in classes {
            guard let originalMethod = class_getInstanceMethod(klass, selector) else {
                fatalError("\(selector) must be implemented")
            }

            var originalIMP: IMP? = nil
            typealias FunctionReference = @convention(c)(UIViewController, Selector) -> Void

            let swizzledViewDidLoadBlock: @convention(block) (UIViewController) -> Void = { receiver in
                if let originalIMP = originalIMP {
                    let castedIMP = unsafeBitCast(originalIMP, to: FunctionReference.self)
                    castedIMP(receiver, selector)
                }

                injection(receiver)
            }

            let swizzledIMP = imp_implementationWithBlock(unsafeBitCast(swizzledViewDidLoadBlock, to: AnyObject.self))
            originalIMP = method_setImplementation(originalMethod, swizzledIMP)
        }
    }
}
