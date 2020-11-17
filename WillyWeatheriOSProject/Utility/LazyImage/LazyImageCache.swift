//
//  LazyImageCache.swift
//  WillyWeatheriOSProject
//
//  Created by Hubilo Softech Private Limited on 18/11/20.
//

import UIKit

class LazyImageCache {
    static let shared: LazyImageCache = LazyImageCache()
    private init() {}
    
    private let cache = NSCache<NSString, UIImage>()
    private let utilityQueue = DispatchQueue.global(qos: .utility)
    
    func load(url: URL, completion:@escaping(UIImage?)->Swift.Void) {
        if let cached = self.cache.object(forKey: url.absoluteString as NSString) {
            DispatchQueue.main.async {
                completion(cached)
            }
        }
        else {
            utilityQueue.async { [weak self] in
                guard let data = try? Data(contentsOf: url) else { return }
                guard let image = UIImage(data: data) else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                self?.cache.setObject(image, forKey: url.absoluteString as NSString)
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }
    
}
