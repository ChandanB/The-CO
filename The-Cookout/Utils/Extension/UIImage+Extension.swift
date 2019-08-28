//
//  UIImage+Extension.swift
//  The-Cookout
//
//  Created by Chandan Brown on 5/3/19.
//  Copyright © 2019 Chandan B. All rights reserved.
//

import UIKit

private var backgroundView: UIView = {
    let backgroundView = UIView()
    backgroundView.backgroundColor = UIColor.black
    backgroundView.alpha = 0.8
    backgroundView.layer.cornerRadius = 0
    backgroundView.layer.masksToBounds = true

    return backgroundView
}()

private var activityIndicator: UIActivityIndicatorView = {
    var activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    activityIndicator.hidesWhenStopped = true
    activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
    activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
    activityIndicator.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
    activityIndicator.isUserInteractionEnabled = false

    return activityIndicator
}()

extension UIImageView {

    func showActivityIndicator() {

        self.addSubview(backgroundView)
        self.addSubview(activityIndicator)
        activityIndicator.style = .white
        activityIndicator.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        backgroundView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        backgroundView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        DispatchQueue.main.async {
            activityIndicator.startAnimating()
        }
    }

    func hideActivityIndicator() {
        DispatchQueue.main.async {
            activityIndicator.stopAnimating()
        }

        activityIndicator.removeFromSuperview()
        backgroundView.removeFromSuperview()
    }

    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds

        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }

    func setRounded() {
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = frame.size.height / 2
        clipsToBounds = true
    }

    func loadImageUsingCacheWithUrlString(_ urlString: String) {
        let imageCache = NSCache<AnyObject, AnyObject>()

        self.image = nil

        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }

        //otherwise fire off a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, _, error) in

            //download hit an error so lets return out
            if error != nil {
                print(error ?? "")
                return
            }

            DispatchQueue.main.async(execute: {

                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)

                    self.image = downloadedImage
                }
            })
        }).resume()
    }
}

extension UIImage {

    var isPortrait: Bool { return size.height > size.width }
    var isLandscape: Bool { return size.width > size.height }
    var breadth: CGFloat { return min(size.width, size.height) }
    var breadthSize: CGSize { return CGSize(width: breadth, height: breadth) }
    var breadthRect: CGRect { return CGRect(origin: .zero, size: breadthSize) }

    var roundedImage: UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: self.size.height
            ).addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }

    var circleMasked: UIImage? {
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait  ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
        UIBezierPath(ovalIn: breadthRect).addClip()
        UIImage(cgImage: cgImage).draw(in: breadthRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func scaleImageToSize(newSize: CGSize) -> UIImage {
        var scaledImageRect = CGRect.zero

        let aspectWidth = newSize.width/size.width
        let aspectheight = newSize.height/size.height

        let aspectRatio = max(aspectWidth, aspectheight)

        scaledImageRect.size.width = size.width * aspectRatio
        scaledImageRect.size.height = size.height * aspectRatio
        scaledImageRect.origin.x = (newSize.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (newSize.height - scaledImageRect.size.height) / 2.0

        UIGraphicsBeginImageContext(newSize)
        draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return scaledImage!
    }

    var asJPEGData: Data? {
        //    self.jpegData(compressionQuality: 1)
        return self.jpegData(compressionQuality: 1)   // QUALITY min = 0 / max = 1
    }
    var asPNGData: Data? {
        return self.pngData()
    }

}
