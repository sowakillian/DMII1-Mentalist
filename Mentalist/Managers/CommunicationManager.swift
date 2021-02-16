//
//  CommunicationManager.swift
//  Mentalist
//
//  Created by SOWA KILLIAN on 15/02/2021.
//

import Foundation

class CommunicationManager {
    var splittedString: [String]
    var readingState: Int
    
    init(splittedString: [String] = [], readingState: Int = 0) {
        self.splittedString = splittedString
        self.readingState = readingState
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
    
    
}
