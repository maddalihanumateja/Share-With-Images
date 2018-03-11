//
//  SharingImageViewController.swift
//  Share With Images
//
//  Created by Hanuma Teja Maddali on 3/11/18.
//  Copyright © 2018 Hanuma Teja Maddali. All rights reserved.
//

import UIKit

class SharingImageViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var sharingImageNameLabel: UILabel!
    @IBOutlet weak var sharingImageNameTextField: UITextField!
    @IBOutlet weak var sharingImageDescriptionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Handle the text fields' user input through delegate callbacks.
        sharingImageNameTextField.delegate = self
        sharingImageDescriptionTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField == sharingImageNameTextField){
            sharingImageNameLabel.text = textField.text
        }
    }
    
    //MARK: Actions

}
