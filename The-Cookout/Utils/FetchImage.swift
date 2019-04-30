//
//  FetchImage.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/15/18.
//  Copyright © 2018 Chandan B. All rights reserved.
//

import LBTAComponents
import Kingfisher

class FetchImage  {
    
    func fetch(with imageUrl: String, completion: @escaping (UIImage?) -> Void) {
        // Check if cache is existing.
        if checkImageCache(with: imageUrl) {
            fetchImageFromCache(with: imageUrl, completion: { (image: Image?) in
                completion(image)
            })
            return
        }
        
        // Download image from url.
        download(from: imageUrl) { (image: Image?) in
            if let image = image {
                // Save image to cache
                self.saveImageToDisk(with: image, key: imageUrl)
                completion(image)
                
                return
            }
            completion(nil)
        }
    }
    
    private func checkImageCache(with key: String) -> Bool {
        return ImageCache.default.imageCachedType(forKey: key).cached
    }
    
    private func fetchImageFromCache(with key: String, completion: @escaping (Image?) -> Void) {
        ImageCache.default.retrieveImage(forKey: key, options: nil) { (image, cacheType) in
            completion(image)
        }
    }
    
    private func download(from imageUrl: String, completion: @escaping (Image?) -> Void) {
        guard let url = URL(string: imageUrl) else {return}
        ImageDownloader.default.downloadImage(with: url, options: [], progressBlock: nil) {
            (image, error, url, data) in
            completion(image)
        }
    }
    
    private func saveImageToDisk(with image: Image, key: String) {
        ImageCache.default.store(image, forKey: key)
    }
}
