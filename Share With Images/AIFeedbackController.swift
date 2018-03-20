//
//  AIFeedbackController.swift
//  Share With Images
//
//  Created by Hanuma Teja Maddali on 3/19/18.
//  Copyright © 2018 Hanuma Teja Maddali. All rights reserved.
//

import UIKit
import os.log

class AIFeedbackController {
   
    //MARK: Properties
    
    // A boolean that indicates whether the user has to present SharingImages in a particular
    // order (as opposed to any combination of the SharingImages)
    private var structuredInteraction: Bool
    
    // This stores the expected structure of the interaction (Person followed by Action, ... or Subject followed by Object, ... or Action only ...)
    private var interactionStructure: [SharingImage.sharingImageType]?
    
    // This stores the history of SharingImages presented to the system for a single event session (The controller interprets a set of inputs and performs some action before clearing this stack).
    private var sessionImageHistory: [(sharingImageName:String,sharingImageType:SharingImage.sharingImageType)]
    
    
    // Path to where the concepts are stored
    //static let conceptURL = DocumentsDirectory.appendingPathComponent("concepts")
    
    // This stores the concepts (in the form of templates) for each of the SharingImages.
    // The information (required or optional) that is required to complete these templates and thereby complete the interaction session between the user and the system is indicated.
    // For example: An email requires a sender (implied that its the user), recepients, some freeform input that will be sent (text, image, audio, ...) and a condition (indicating when to send it). These should be captured by the email concept in some form (a dictionary perhaps). We should also be able to either do this in an unstructured manner (shouldnt matter if the user presents the email action image along with the recipient image) or impose a structure in the interaction (the user is required to present an email action image first, then the recipients, and then the object to be sent)
    // private var conceptList = [["action":"gmail","person":["obama"],"freeform-input":["[text]?","[image]?"]]]
    
    
    init(structuredInteraction: Bool, interactionStructure:[SharingImage.sharingImageType]?){
        
        self.structuredInteraction = structuredInteraction
        if(structuredInteraction){
         self.interactionStructure = interactionStructure
        }
        self.sessionImageHistory = Array<(String,SharingImage.sharingImageType)>()
    }
    
    func clearHistory() {
        self.sessionImageHistory.removeAll()
    }
    
    func getHistoryLength() -> Int {
        return self.sessionImageHistory.count
    }
    
    //MARK: Generating responses
    
    func generateResponse(inputSharingImage: String) -> (returnCorrectInput: Bool, returnDialogue: String, returnActionURL: URL?) {
        var sharingImageMeta = inputSharingImage.split(separator:";")
        let sharingImageName:String = String(sharingImageMeta[0])
        let sharingImageType: SharingImage.sharingImageType = SharingImage.sharingImageType(rawValue:Int(String(sharingImageMeta[1]))!)!
        
        if(self.structuredInteraction){
            return generateStructuredResponse(sharingImageName: sharingImageName, sharingImageType: sharingImageType)
        }
        else{
            return generateUnstructuredResponse(sharingImageName: sharingImageName, sharingImageType: sharingImageType)
        }
    }
    
    func generateStructuredResponse(sharingImageName: String, sharingImageType: SharingImage.sharingImageType) -> (returnCorrectInput: Bool, returnDialogue: String, returnActionURL: URL?) {
        self.sessionImageHistory.append((sharingImageName: sharingImageName, sharingImageType: sharingImageType))
        let currentInputCount = sessionImageHistory.count
        
        var returnDialogue: String = "Detected image “\(sharingImageName)”. "
        var returnCorrectInput: Bool = true
        var returnActionURL: URL? = nil
        
        if(sharingImageType == self.interactionStructure![currentInputCount-1]){
            // Check if the sequence of inputs so far are compatible
            // i.e. people have email addresses when an email is to be sent
            
            //Check if a "complete" interaction has occurred i.e. the user has given all the required inputs and in the correct sequence
            if(currentInputCount == self.interactionStructure?.count){
                // Do something based on the action, persons, and freeform-input (and possibly condition)
                returnDialogue += "Great 😃! I will do this action and involve this person."
                self.sessionImageHistory.removeAll()
                let email = SharingImage.sharingEmail // This email can be a property of the sharingimage objects instead of a class property as in this example
                returnActionURL = URL(string: "mailto:\(email)")
            }
            else{
                returnDialogue += "Ok 🙂! Could you tell me the " + self.interactionStructure![currentInputCount].stringify() + " for this (if any)"
            }
        }
        else{
            // Input presented in the wrong sequence. What is the type of input expected?
            // That input may have a different name that you want to display depending on the context
            // example: A person in the context of an email could be a recipient
            returnDialogue += "I was expecting a " + self.interactionStructure![currentInputCount-1].stringify() + " instead of a " + sharingImageType.stringify() + " 😕."
            print(self.sessionImageHistory.popLast() ?? "")
            returnCorrectInput = false
        }
        return (returnCorrectInput, returnDialogue, returnActionURL)
    }
    
    func generateUnstructuredResponse(sharingImageName: String, sharingImageType: SharingImage.sharingImageType) -> (returnCorrectInput: Bool, returnDialogue: String, returnActionURL: URL?) {
        return (true, " ", nil)
    }
}
