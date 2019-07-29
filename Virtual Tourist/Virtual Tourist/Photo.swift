//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Najd  on 20/11/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation
import UIKit

extension Photo {
    
    func set(image: UIImage) {
        self.image = image.pngData()
    }
    
    func getImage() -> UIImage? {
        return (image == nil) ? nil : UIImage(data: image!)
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
