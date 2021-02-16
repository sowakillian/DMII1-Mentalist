//
//  CommunicationManager.swift
//  Mentalist
//
//  Created by SOWA KILLIAN on 15/02/2021.
//

import Foundation

class CommunicationManager {
    var splittedString: [String]
    var moodStrings: [String:String]
    var readingState: Int
    
    init(splittedString: [String] = [],
         readingState: Int = 0,
         moodStrings: [String:String] = ["content": "", "pas content": "", "pourquoi j'ai choisi DMII?": ""]) {
        self.splittedString = splittedString
        self.readingState = readingState
        self.moodStrings = moodStrings
    }
    
    func sendSplittedStringCharacters(completionBlock: @escaping (_ success: Bool) -> Void) {
        self.splittedString.forEach { (stringItem) in
            //self.editHistory(message: stringItem, received: false)
            if let characterAsData = stringItem.data(using: .utf8) {
                BLEManager.instance.sendData(data: characterAsData) { success in
                    
                }
            }
        }
        
        completionBlock(true)
    }
    
    func attributeValuesToMoodStrings() {
        self.moodStrings["content"] = self.splittedString[0]
        self.moodStrings["pas content"] = self.splittedString[1]
        self.moodStrings["pourquoi j'ai choisi DMII?"] = self.splittedString[2]
    }
    
    func compareAndReturnMoodString(messageReceived: String, completionHandler: @escaping (_ message: String) -> Void) {
        if let happyValue = self.moodStrings["content"],
           let sadValue = self.moodStrings["pas content"],
           let whyValue = self.moodStrings["pourquoi j'ai choisi DMII?"] {
            
            let distanceHappy = messageReceived.distance(between: happyValue)
            let distanceSad = messageReceived.distance(between: sadValue)
            let distanceWhy = messageReceived.distance(between: whyValue)
            
            print(messageReceived, happyValue, sadValue, whyValue)
            
            let smallest = min(distanceHappy, distanceSad, distanceWhy)
            
            print(smallest, "smallest")
            print(distanceHappy, distanceSad, distanceWhy)
            
            if smallest == distanceHappy {
                let messageToSend = "content"
                BLEManager.instance.sendData(data: messageToSend.data(using: .utf8)!) { success in
                    completionHandler(messageToSend)
                }
            }
            
            if smallest == distanceSad {
                let messageToSend = "pas content"
                BLEManager.instance.sendData(data: messageToSend.data(using: .utf8)!) { success in
                    completionHandler(messageToSend)
                }
            }
            
            if smallest == distanceWhy {
                let messageToSend = "pourquoi j'ai choisi DMII?"
                BLEManager.instance.sendData(data: messageToSend.data(using: .utf8)!) { success in
                    completionHandler(messageToSend)
                }
            }
        }
    }
    
    
}
