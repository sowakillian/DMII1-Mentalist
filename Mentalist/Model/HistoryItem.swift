//
//  HistoryItem.swift
//  Mentalist
//
//  Created by SOWA KILLIAN on 15/02/2021.
//

import Foundation

struct HistoryItem {
    var message: String
    var received: Bool

    enum CodingKeys: String, CodingKey {
        case message
        case received
    }
}
