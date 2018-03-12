//
//  SharingImage.swift
//  Share With Images
//
//  Created by Hanuma Teja Maddali on 3/11/18.
//  Copyright © 2018 Hanuma Teja Maddali. All rights reserved.
//

import UIKit

class SharingImage{
    
    //MARK: Properties
    
    enum sharingImageType{
        // The SharingImage object represents a person
        case Person
        // The SharingImage object represents a request for an action
        case Action
        // The SharingImage object represents a certain type of input
        // For example a photo, text, or audio .. that can be attached to an email
        case FreeformInput
    }
    
    
    var name: String
    var photo: UIImage
    var description: String?
    var type: sharingImageType
    
    //MARK: Initialization
    
    init?(name: String, photo: UIImage, description: String?, type: sharingImageType) {
        
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.description = description
        self.type = type
        
    }
}
