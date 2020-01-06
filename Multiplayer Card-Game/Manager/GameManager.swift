//
//  GameManager.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 31/12/19.
//  Copyright © 2019 Hot Cocoa Software. All rights reserved.
//

import MultipeerConnectivity

//MARK:- GameManager Protocol
protocol GameManagerDelegate {
    func roundWinner(winner: MCPeerID)
    func gameWinner(winner: MCPeerID)
    func timeRemaining(timeString: String)
}

class GameManager {
    //MARK:- Property Variables
    static var shared = GameManager()
    private var deck: Deck!
    private let numberOfCardsPerPlayer = 13
    private var currentPlayerIndex = 0
    private var timer: Timer? = nil
    private var timeLeft = 5 * 60 {
        didSet {
            if timeLeft == 0 {
                delegate?.gameWinner(winner: getGameWinner())
                self.stopTimer()
                timeLeft = 5 * 60
            }
        }
    }
    
    var delegate: GameManagerDelegate?

    let minPlayersNeeded = 1
    var players: [MCPeerID]!
    var playerCount = 1
    var cardsForPlayer: [[Card]]!
    var cardsInCentre: [Card]! {
        didSet {
            if cardsInCentre.count == playerCount {
                delegate?.roundWinner(winner: players[getBoutWinnerIndex()])
            }
        }
    }
    var cardsWonPerPlayer: [[Card]]!
    
    
    //MARK:- Initializers
    private init() { }
    
    //MARK:- Member Methods
    func newGame(playersArray: [MCPeerID]) {
        players = playersArray
        playerCount = players.count
        deck = Deck()
        cardsInCentre = [Card]()
        cardsForPlayer = [[Card]]()
        cardsWonPerPlayer = [[Card]]()
        timeLeft *= playerCount
        for _ in 0..<players.count {
            cardsForPlayer.append([Card]())
            cardsWonPerPlayer.append([Card]())
        }
    }
    
    func distributeCards(uiHandler: @escaping (Result<(Card,MCPeerID),CardError>) -> Void) {
        for _ in 0..<numberOfCardsPerPlayer {
            for playerIndex in 0..<players.count {
                if let card = deck.draw() {
                    cardsForPlayer[playerIndex].append(card)
                    uiHandler(.success((card,players[playerIndex])))
                } else {
                    print("Error getting the card from the deck")
                    uiHandler(.failure(.CardDrawError))
                }
            }
        }
        startTimer()
    }
    
    func throwCardInCenter(card: Card, completion: @escaping (MCPeerID) -> Void) {
        cardsInCentre.append(card)
        updateNextPlayer()
        completion(players[currentPlayerIndex])
    }
    
    //MARK:- Private Methods
    private func getBoutWinnerIndex() -> Int {
        var winnerIndex = 0
        for index in 1..<cardsInCentre.count {
            if cardsInCentre[index].rank.order > cardsInCentre[winnerIndex].rank.order {
                winnerIndex = index
            }
        }
        for card in cardsInCentre {
            cardsWonPerPlayer[winnerIndex].append(card)
        }
        cardsInCentre = [Card]()
        return winnerIndex
    }
    
    private func updateNextPlayer() {
        if currentPlayerIndex == playerCount {
            currentPlayerIndex = 0
        } else {
            currentPlayerIndex += 1
        }
        
        if cardsForPlayer[currentPlayerIndex].count == 0 {
            updateNextPlayer()
        }
    }
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(1.0), repeats: true) { [weak self] (timer) in
            guard let self = self else { return }
            self.timeLeft -= 1
            self.delegate?.timeRemaining(timeString: self.getTimeString())
        }
    }
    
    private func stopTimer() {
        if timer != nil {
            timer?.invalidate()
        }
    }
    
    private func getTimeString() -> String {
        let seconds = timeLeft
        var min = 0
        var sec = 0
        min = Int(seconds/60)
        sec = seconds % 60
        var timeString = "\(min): \(sec)"
        if sec < 10 {
            timeString = "\(min): 0\(sec)"
        }
        return timeString
    }
    
    private func getGameWinner() -> MCPeerID {
        var winnerIndex = 0
        for index in 1..<playerCount {
            if cardsForPlayer[winnerIndex].count < cardsForPlayer[index].count {
                winnerIndex = index
            }
        }
        return players[winnerIndex]
    }
}
