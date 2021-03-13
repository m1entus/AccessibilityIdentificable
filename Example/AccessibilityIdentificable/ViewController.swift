//
//  ViewController.swift
//  AccessibilityIdentificable
//
//  Created by Michal Zaborowski on 2021-03-13.
//

import UIKit

class ViewController: UIViewController, AccessibilityIdentificable {

    @AccessibilityIdentify(identifier: "custom_id")
    var testView = UIView()

    var viewArray = [UIView(), UIView()]
    
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        testView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(testView)
        testView.backgroundColor = UIColor.red
        testView.heightAnchor.constraint(equalToConstant: 150.0).isActive = true
        testView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        testView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        testView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        viewArray.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
            $0.backgroundColor = .black
            $0.heightAnchor.constraint(equalToConstant: 100.0).isActive = true
            $0.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            $0.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
    }


}

