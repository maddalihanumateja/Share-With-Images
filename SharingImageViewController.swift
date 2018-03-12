//
//  SharingImageViewController.swift
//  Share With Images
//
//  Created by Hanuma Teja Maddali on 3/11/18.
//  Copyright © 2018 Hanuma Teja Maddali. All rights reserved.
//

import UIKit
import os.log

class SharingImageViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var sharingImageNameTextField: UITextField!
    @IBOutlet weak var sharingImageDescriptionTextField: UITextField!
    @IBOutlet weak var sharingImagePhotoView: UIImageView!
    @IBOutlet weak var sharingImageTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    /*
     This value is either passed by `SharingImageTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new SharingImage.
     */
    var sharingImage: SharingImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Handle the text fields' user input through delegate callbacks.
        sharingImageNameTextField.delegate = self
        sharingImageDescriptionTextField.delegate = self
        
        // Set up views if editing an existing Meal.
        if let sharingImage = sharingImage {
            navigationItem.title = sharingImage.name
            sharingImageNameTextField.text   = sharingImage.name
            sharingImageDescriptionTextField.text = sharingImage.description
            sharingImagePhotoView.image = sharingImage.photo
            switch sharingImage.type
            {
            case SharingImage.sharingImageType.Action:
                sharingImageTypeSegmentedControl.selectedSegmentIndex = 1
            case SharingImage.sharingImageType.FreeformInput:
                sharingImageTypeSegmentedControl.selectedSegmentIndex = 2
            case SharingImage.sharingImageType.Person:
                sharingImageTypeSegmentedControl.selectedSegmentIndex = 0
            }
        }
        
        // Enable the Save button only if the name and description text fields are not empty.
        updateSaveButtonState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        if(textField == sharingImageNameTextField){
            navigationItem.title = textField.text
        }
    }
    
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        sharingImagePhotoView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
     // MARK: - Navigation
     
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let sharingImageName = sharingImageNameTextField.text ?? ""
        let sharingImagePhoto = sharingImagePhotoView.image
        let sharingImageDescription = sharingImageDescriptionTextField.text ?? ""
        var sharingImageType = SharingImage.sharingImageType.Person
        switch sharingImageTypeSegmentedControl.selectedSegmentIndex
        {
        case 1:
            sharingImageType = SharingImage.sharingImageType.Action
        case 2:
            sharingImageType = SharingImage.sharingImageType.FreeformInput
        default:
            sharingImageType = SharingImage.sharingImageType.Person
        }
        
        // Set the sharingImage to be passed to SharingImageTableViewController after the unwind segue.
        sharingImage = SharingImage(name: sharingImageName, photo: sharingImagePhoto!, description: sharingImageDescription, type: sharingImageType)
     }
    
    //MARK: Actions
    
    @IBAction func typeSelectionChanged(_ sender: UISegmentedControl) {
        switch sharingImageTypeSegmentedControl.selectedSegmentIndex
        {
        case 1:
            sharingImageDescriptionTextField.placeholder = "What is this image supposed to do?"
        case 2:
            sharingImageDescriptionTextField.placeholder = "What do you want to send?"
        default:
            sharingImageDescriptionTextField.placeholder = "Who is in this image?"
        }
    }
    @IBAction func selectSharingImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        // Hide the keyboard.
        sharingImageNameTextField.resignFirstResponder()
        sharingImageDescriptionTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    //MARK: Private Methods
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let nameText = sharingImageNameTextField.text ?? ""
        let descriptionText = sharingImageDescriptionTextField.text ?? ""
        saveButton.isEnabled = !nameText.isEmpty && !descriptionText.isEmpty
    }
    
}
