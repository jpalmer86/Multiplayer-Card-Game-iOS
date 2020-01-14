//
//  MessageService.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 07/01/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MessageService {
    
    //MARK:- Property Variables
    
    static let shared = MessageService()
    private var hostPeerID: MCPeerID!
    private let seperator = "-"
    private let suits = Card.Suit.allSuits.map({ $0.description })
    private var session: MCSession!
    
    //MARK:- Initializers
    
    private init() { }
    
    //MARK:- Member Methods
    
    func setSession(mcSession: MCSession) {
        self.session = mcSession
    }
    
    func setHost(hostID: MCPeerID) {
        self.hostPeerID = hostID
    }
    
    //MARK:- Sending Methods
    
    func sendCardExchangePlayerMessage(played: MessageType, card: Card, player: String) {
        let message = "\(played.rawValue)\(seperator)\(card)\(seperator)\(player)"
        
        if played == .PlayerTurnedCardClientMessage {
            sendToHost(message: message) { (result) in
                //
            }
        } else {
            send(message: message) { (result) in
                //
            }
        }
    }
    
    func sendGameStateMessage(state: GameState) {
        let message = "\(MessageType.GameStateChangeMessage.rawValue)\(seperator)\(state)"
        send(message: message) { (result) in
            //
        }
    }
    
    func sendWinnerMessage(bout: MessageType, player: String) {
        let message = "\(bout.rawValue)\(seperator)\(player)"
        send(message: message) { result in
            //
        }
    }
    
    func sendRemainingTime(timeString: String) {
        let message = "\(MessageType.RemainingTimeMessage.rawValue)\(seperator)\(timeString)"
        send(message: message) { result in
            //
        }
    }
    
    func sendCardsSwappedHostMessage(player: String, index: Int) {
        let message = "\(MessageType.CardsSwappedHostMessage.rawValue)\(seperator)\(player)\(seperator)\(index)"
        send(message: message) { result in
            //
        }
    }
    
    func sendCardsSwappedClientMessage(player: String, index: Int) {
        let message = "\(MessageType.CardsSwappedClientMessage.rawValue)\(seperator)\(player)\(seperator)\(index)"
        sendToHost(message: message) { (result) in
            //
        }
    }
    
    func sendNextPlayerTurn(player: String) {
        let message = "\(MessageType.NextPlayerTurnMessage.rawValue)\(seperator)\(player)"
        send(message: message) { result in
            //
        }
    }
    
    func sendHostName(player: String) {
        let message = "\(MessageType.HostNameMessage.rawValue)\(seperator)\(player)"
        send(message: message) { result in
            //
        }
    }
    
    func sendClientGameOverToHost() {
        let message = "\(MessageType.GameOverClientMessage.rawValue)\(seperator)\(GameState.gameOver)"
        sendToHost(message: message) { (result) in
            //
        }
    }
    
    func sendClientPlayerNameToHost(name: String) {
        let message = "\(MessageType.ClientNameMessage.rawValue)\(seperator)\(name)"
        sendToHost(message: message) { (result) in
            //
        }
    }
    
    //MARK:- Retrieval Methods
    
    func cardExchangeData(data: Data) -> [String:Card] {
        let message = String(data: data, encoding: .utf8)!
         
        let characterArray = message.split(separator: Character(seperator))
        let messageArray = characterArray.map({ String($0) })
                
        let cardCharacterArray = messageArray[1].split(separator: Character(" "))
        let cardArray = cardCharacterArray.map({ String($0) })
        let rank = Card.Rank.orderOf(rank: cardArray[0])
        let suit = Card.Suit.allSuits[suits.firstIndex(of: cardArray[1])!]
        
        let card = Card(suit: suit, rank: Card.Rank.allRanks[rank - 1])
        
        return [messageArray[2]: card] 
    }
    
    func gameStateData(data: Data) -> GameState {
        let message = String(data: data, encoding: .utf8)!
        
        let characterArray = message.split(separator: Character(seperator))
        let messageArray = characterArray.map({ String($0) })
        
        return GameState.gameState(state: messageArray[1])
    }
    
    func winnerData(data: Data) -> String {
        let message = String(data: data, encoding: .utf8)!
        
        let characterArray = message.split(separator: Character(seperator))
        let messageArray = characterArray.map({ String($0) })
                
        return messageArray[1]
    }
    
    func timeData(data: Data) -> Int {
        let message = String(data: data, encoding: .utf8)!
        
        let characterArray = message.split(separator: Character(seperator))
        let messageArray = characterArray.map({ String($0) })
        
        let timeCharacterArray = messageArray[1].split(separator: Character(":"))
        let timeArray = timeCharacterArray.map({ Int($0) ?? 0 })
        return 60 * timeArray[0] + timeArray[1]
    }
    
    func cardsSwappedData(data: Data) -> [String: Int] {
        let message = String(data: data, encoding: .utf8)!
         
        let characterArray = message.split(separator: Character(seperator))
        let messageArray = characterArray.map({ String($0) })
                
        let playerName = messageArray[1]
        
        let index = Int(messageArray[2])!
                
        return [playerName: index]
    }
    
    func nextPlaterData(data: Data) -> String {
        let message = String(data: data, encoding: .utf8)!
        
        let characterArray = message.split(separator: Character(seperator))
        let messageArray = characterArray.map({ String($0) })
                
        return messageArray[1]
    }
    
    func getMessageType(data: Data) -> MessageType {
        let message = String(data: data, encoding: .utf8)!
        
        let characterArray = message.split(separator: Character(seperator))
        let messageArray = characterArray.map({ String($0) })
        
        let messageType = MessageType.messageType(number: Int(messageArray[0])!)
        
        return messageType
    }
    
    func getHostNameData(data: Data) -> String {
        let message = String(data: data, encoding: .utf8)!
        
        let characterArray = message.split(separator: Character(seperator))
        let messageArray = characterArray.map({ String($0) })
        
        return messageArray[1]
    }
    
    func getClientPlayerName(data: Data) -> String {
        let message = String(data: data, encoding: .utf8)!
        
        let characterArray = message.split(separator: Character(seperator))
        let messageArray = characterArray.map({ String($0) })
        
        return messageArray[1]
    }
        
    //MARK:- Private Methods
    
    private func send(message: String, completion: @escaping (Result<Data,Error>) -> Void) {
        let data = message.data(using: .utf8)!
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(data, toPeers: self.session.connectedPeers, with: .reliable)
                completion(.success(data))
            }
            catch {
                print("Error sending message: ",error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    private func sendToHost(message: String, completion: @escaping (Result<Data,Error>) -> Void) {
        let data = message.data(using: .utf8)!
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(data, toPeers: [hostPeerID], with: .reliable)
                completion(.success(data))
            }
            catch {
                print("Error sending message: ",error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
}
