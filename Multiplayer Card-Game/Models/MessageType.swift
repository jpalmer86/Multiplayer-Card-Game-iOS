//
//  MessageType.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 07/01/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import Foundation

enum MessageType: Int {
    case GameStateMessage = 1
    case GiveCardToPlayerMessage = 2
    case PlayerTurnCardMessage = 3
    case BoutWinnerMessage = 4
    case GameWinnerMessage = 5
    case RemainingTime = 6
    case CardsSwapped = 7
    
    static let allMessageType = [MessageType.GameStateMessage, .GiveCardToPlayerMessage, .PlayerTurnCardMessage, .BoutWinnerMessage, .GameWinnerMessage, .RemainingTime]
    
    static func messageType(number: Int) -> MessageType {
        let messageTypeArray = allMessageType.map({ $0.rawValue })
        return allMessageType[messageTypeArray.firstIndex(of: number)!]
    }
}
