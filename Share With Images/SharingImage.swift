//
//  SharingImage.swift
//  Share With Images
//
//  Created by Hanuma Teja Maddali on 3/11/18.
//  Copyright © 2018 Hanuma Teja Maddali. All rights reserved.
//

import UIKit
import os.log

class SharingImage: NSObject, NSCoding {
    
    //MARK: Properties
    
    enum sharingImageType: Int {
        // The SharingImage object represents a person
        case Person
        // The SharingImage object represents a request for an action
        case Action
        // The SharingImage object represents a certain type of input
        // For example a photo, text, or audio .. that can be attached to an email
        case FreeformInput
        
        func stringify() -> String {
            switch self {
            case .Person:
                return "Person"
            case .Action:
                return "Action"
            case .FreeformInput:
                return "Freeform Input"
            }
        }
    }
    
    var name: String
    var photo: UIImage
    var photoDescription: String?
    var type: sharingImageType
    static let sharingEmail: String = "xyz@gmail.com"
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("sharingImages")
    
    //MARK: Types
    
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let photoDescription = "photoDescription"
        static let type = "type"
    }
    
    //MARK: Initialization
    
    init?(name: String, photo: UIImage, photoDescription: String?, type: sharingImageType) {
        
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.photoDescription = photoDescription
        self.type = type
        
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(photoDescription, forKey: PropertyKey.photoDescription)
        aCoder.encode(type.rawValue, forKey: PropertyKey.type)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a SharingImage object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // The description is required. If we cannot decode a name string, the initializer should fail.
        guard let photoDescription = aDecoder.decodeObject(forKey: PropertyKey.photoDescription) as? String else {
            os_log("Unable to decode the description for a SharingImage object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        
        let typeRawValue = aDecoder.decodeInteger(forKey: PropertyKey.type)
        var type = sharingImageType.Person
        
        switch typeRawValue {
        case sharingImageType.Person.rawValue:
            type = sharingImageType.Person
        case sharingImageType.Action.rawValue:
            type = sharingImageType.Action
        case sharingImageType.FreeformInput.rawValue:
            type = sharingImageType.FreeformInput
        default:
            fatalError("Unable to determine type of stored SharingImage object")
        }
        
        // Must call designated initializer.
        self.init(name: name, photo: photo!, photoDescription: photoDescription, type: type)
    }
}
