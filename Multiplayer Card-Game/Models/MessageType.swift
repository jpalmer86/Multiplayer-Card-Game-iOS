//
//  MessageType.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 07/01/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import Foundation

enum MessageType: Int {
    //// HostMessage:- sent by host
    //// ClientMessage:- sent by client
    case GameStateChangeMessage = 1
    case GameOverClientMessage = 2
    case GiveCardToPlayerMessage = 3
    
    case PlayerTurnedCardClientMessage = 4
    case PlayerTurnedCardHostMessage = 5
    
    case BoutWinnerMessage = 6
    case GameWinnerMessage = 7
    case RemainingTimeMessage = 8
    
    case CardsSwappedClientMessage = 9
    case CardsSwappedHostMessage = 10
    
    case NextPlayerTurnMessage = 11
    
    case HostNameMessage = 12
    case ClientNameMessage = 13
    
    case PlayerNameListMessage = 14
    
    case PlayerIndexMessage = 15
    
    case SelectedPositionHostMessage = 16
    case SelectedPositionClientMessage = 17
    
    static let allMessageType = [MessageType.GameStateChangeMessage, .GameOverClientMessage, .GiveCardToPlayerMessage, .PlayerTurnedCardClientMessage, .PlayerTurnedCardHostMessage, .BoutWinnerMessage, .GameWinnerMessage, .RemainingTimeMessage, .CardsSwappedClientMessage, .CardsSwappedHostMessage, .NextPlayerTurnMessage, .HostNameMessage, .ClientNameMessage, .PlayerNameListMessage, .PlayerIndexMessage, .SelectedPositionHostMessage, .SelectedPositionClientMessage]
    
    static func messageType(number: Int) -> MessageType {
        let messageTypeArray = allMessageType.map({ $0.rawValue })
        return allMessageType[messageTypeArray.firstIndex(of: number)!]
    }
}
