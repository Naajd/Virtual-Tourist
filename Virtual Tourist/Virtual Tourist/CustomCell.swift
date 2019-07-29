//
//  CustomICell.swift
//  Virtual Tourist
//
//  Created by Najd  on 20/11/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import UIKit



class CustomCell: UIImageView {
    let imagesCache = NSCache<NSString, AnyObject>()
    
    var photoURL: URL!
    
    
    
    func showActivityIndicatorView() {
        DispatchQueue.main.async {
            self.activityIndicatorView.startAnimating()
        }
    }
    
    func hideActivityIndicatorView() {
        DispatchQueue.main.async {
            self.activityIndicatorView.stopAnimating()
        }
    }
    

    func setPhoto(_ newPhoto: Photo) {
        
        photo = newPhoto
    }
    
    private var photo: Photo! {
        didSet {
            if let image = photo.getImage() {
                hideActivityIndicatorView()
                self.image = image
                return
            }
            
            guard let url = photo.imageURL else {
                return
            }
            
            loadImagebyCache(with: url)
        }
    }
    
    func loadImagebyCache(with url: URL) {
        photoURL = url
        image = nil
        showActivityIndicatorView()
        
        if let cachedImage = imagesCache.object(forKey: url.absoluteString as NSString) as? UIImage {
            self.image = cachedImage
            hideActivityIndicatorView()
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let Downloaded = UIImage(data: data!) else { return }
            self.imagesCache.setObject(Downloaded, forKey:  url.absoluteString as NSString)
            DispatchQueue.main.async {
                self.image = Downloaded
                self.photo.set(image: Downloaded)
                ((try? self.photo.managedObjectContext?.save()) as ()??)
                self.hideActivityIndicatorView()
            }
            
            }.resume()
    }
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        self.addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activityIndicatorView.color = .black
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }()
    
    
}
