//
//  MessageType.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 07/01/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import Foundation

enum MessageType: Int {
    case GameStateChange = 1
    case GiveCardToPlayer = 2
    
    case PlayerTurnedCardClientMessage = 3
    case PlayerTurnedCardHostMessage = 4
    
    case BoutWinnerMessage = 5
    case GameWinnerMessage = 6
    case RemainingTime = 7
    
    case CardsSwappedClientMessage = 8
    case CardsSwappedHostMessage = 9
    
    case NextPlayerTurn = 10
    case HostNameMessage = 11
    
    static let allMessageType = [MessageType.GameStateChange, .GiveCardToPlayer, .PlayerTurnedCardClientMessage, .PlayerTurnedCardHostMessage, .BoutWinnerMessage, .GameWinnerMessage, .RemainingTime, .CardsSwappedClientMessage, .CardsSwappedHostMessage, .NextPlayerTurn, .HostNameMessage]
    
    static func messageType(number: Int) -> MessageType {
        let messageTypeArray = allMessageType.map({ $0.rawValue })
        return allMessageType[messageTypeArray.firstIndex(of: number)!]
    }
}
