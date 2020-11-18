//
//  AsyncImageView.swift
//  WillyWeatheriOSProject
//
//  Created by Hubilo Softech Private Limited on 18/11/20.
//

import UIKit

class AsyncImageView: UIImageView {
    
    private var url: URL?
    func setImage(from url: URL) {
        self.url = url
        self.image = nil
        LazyImageCache.shared.load(url: url) { [weak self] (image, url) in
            DispatchQueue.main.async {
                if self?.url == url, let image = image {
                    self?.image = image
                    self?.alpha = 0
                    UIView.animate(withDuration: 0.2) {
                        self?.alpha = 1
                    }
                }
                else {
                    self?.image = nil
                }
            }
        }
    }
    
}
