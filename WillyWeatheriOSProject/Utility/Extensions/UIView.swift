//
//  UIView.swift
//  WillyWeatheriOSProject
//
//  Created by Hubilo Softech Private Limited on 18/11/20.
//

import UIKit

extension UIView {
    func edges(to view: UIView, top: CGFloat=0, left: CGFloat=0, bottom: CGFloat=0, right: CGFloat=0) {
        NSLayoutConstraint.activate([
            leftAnchor.constraint(equalTo: view.leftAnchor, constant: left),
            rightAnchor.constraint(equalTo: view.rightAnchor, constant: right),
            topAnchor.constraint(equalTo: view.topAnchor, constant: top),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom)
        ])
    }
}

class GradientView: UIView {
    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }
    
    var colors: [UIColor] = [UIColor.black.withAlphaComponent(1), UIColor.black.withAlphaComponent(0.5)] {
        didSet {
            (self.layer as? CAGradientLayer)?.colors = colors.compactMap { $0.cgColor }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let gradientLayer = self.layer as! CAGradientLayer
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.colors = colors
        backgroundColor = UIColor.clear
    }
}
