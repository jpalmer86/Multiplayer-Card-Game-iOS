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
    case GameOverClientMessage = 2
    case GiveCardToPlayer = 3
    
    case PlayerTurnedCardClientMessage = 4
    case PlayerTurnedCardHostMessage = 5
    
    case BoutWinnerMessage = 6
    case GameWinnerMessage = 7
    case RemainingTime = 8
    
    case CardsSwappedClientMessage = 9
    case CardsSwappedHostMessage = 10
    
    case NextPlayerTurn = 11
    case HostNameMessage = 12
    
    static let allMessageType = [MessageType.GameStateChange, .GameOverClientMessage, .GiveCardToPlayer, .PlayerTurnedCardClientMessage, .PlayerTurnedCardHostMessage, .BoutWinnerMessage, .GameWinnerMessage, .RemainingTime, .CardsSwappedClientMessage, .CardsSwappedHostMessage, .NextPlayerTurn, .HostNameMessage]
    
    static func messageType(number: Int) -> MessageType {
        let messageTypeArray = allMessageType.map({ $0.rawValue })
        return allMessageType[messageTypeArray.firstIndex(of: number)!]
    }
}
