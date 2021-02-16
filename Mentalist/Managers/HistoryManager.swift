//
//  HistoryManager.swift
//  Mentalist
//
//  Created by SOWA KILLIAN on 15/02/2021.
//

import Foundation

class HistoryManager {
    static let instance = HistoryManager()
    
    var history: [HistoryItem] = []
    
    func editHistory(message: String, received: Bool) {
        HistoryManager.instance.history.append(HistoryItem(message: message, received: received))
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "historyEdited"), object: nil)
    }
}
