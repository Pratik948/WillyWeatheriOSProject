//
//  UINavigationController.swift
//  WillyWeatheriOSProject
//
//  Created by Hubilo Softech Private Limited on 19/11/20.
//

import UIKit

extension UINavigationController {
    override open var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
}
