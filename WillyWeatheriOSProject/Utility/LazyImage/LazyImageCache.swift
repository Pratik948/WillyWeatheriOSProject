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
    private let fileManager = FileManager.default
    private let cache = NSCache<NSString, UIImage>()
    
    @discardableResult
    func load(url: URL, completion:@escaping(UIImage?, URL?)->Swift.Void) -> URLSessionDataTask? {
        if let cached = getCachedImage(forKey: url.absoluteString) {
            completion(cached, url)
            return nil
        }
        else {
            let task = URLSession.shared.dataTask(with: url, completionHandler: { [weak self] (data, response, error) in
                if error != nil {
                    completion(nil, nil)
                    print(error?.localizedDescription ?? "")
                    return
                }
                guard let data = data else {
                    completion(nil, response?.url)
                    return
                }
                guard let image = UIImage(data: data) else {
                    completion(nil, response?.url)
                    return
                }
                completion(image, response?.url)
                self?.cache(image, forKey: url.absoluteString)
            })
            task.resume()
            return task
        }
    }
    
    private func clearCache() {
        self.cache.removeAllObjects()
    }
    
    private func cache(_ image: UIImage, forKey key: String) {
        self.cache.setObject(image, forKey: key as NSString)
        if var url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            url.appendPathComponent((key as NSString).lastPathComponent, isDirectory: false)
            try? image.pngData()?.write(to: url)
        }
    }
    
    private func getCachedImage(forKey key: String) -> UIImage? {
        if let cached = self.cache.object(forKey: key as NSString) {
            return cached
        }
        else if var url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            url.appendPathComponent((key as NSString).lastPathComponent, isDirectory: false)
            if fileManager.fileExists(atPath: url.path), let data = try? Data.init(contentsOf: url) {
                return UIImage.init(data: data)
            }
        }
        return nil
    }
}
