//
//  CustomView.swift
//  AccessibilityIdentificable
//
//  Created by Michal Zaborowski on 2021-03-13.
//

import UIKit

class CustomView: UIView, AccessibilityIdentificable {

    private lazy var label: UILabel = UILabel(frame: .zero)
    private let counter: Int = 0

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        

        label.text = "SAMPLE LABEL"
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
