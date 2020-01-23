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
    func gaveCardToPlayer(card: Card, playerName: String)
    func playerTurnedCard(player: MCPeerID, card: Card)
    func nextPlayerTurn(playerName: String)
    func roundsWonPerPlayer(playerArray: [String],wonCountArray: [Int])
    func playerList(playerList: [MCPeerID])
    func playerColorIndex(index: Int)
    func cardStateUpdated(state: [String])
    func setDeck(deck: Bool)
    func quit()
}

protocol GameCardManagerDelegate {
    func cardsSwapped(updatedCards: [Card], deck: Bool)
}

class GameManager {
    //MARK:- Property Variables
    
    static var shared = GameManager()
    private var deck: Deck!
    private let numberOfCardsPerPlayer = 13
    private let noPlayer = Constants.noplayer
    private var currentPlayerIndex = 0 {
        didSet {
            delegate?.nextPlayerTurn(playerName: players[currentPlayerIndex].displayName)
            if isHost {
                gameService.messageService.sendNextPlayerTurn(player: players[currentPlayerIndex].displayName)
            }
        }
    }
    private var timer: Timer? = nil
    private var timeLeft = 0 {
        didSet {
            self.delegate?.timeRemaining(timeString: self.getTimeString())
            if timeLeft == 0 {
                let winner = getGameWinner()
                if isHost {
                    gameService.messageService.sendWinnerMessage(bout: .GameWinnerMessage, player: winner.displayName)
                    delegate?.gameWinner(winner: winner)
                    self.stopTimer()
                    timeLeft = game.gameTime
                }
            }
        }
    }
    private var isHost = true
    lazy var hostID: MCPeerID = {
        let id = gameService.messageService.getHost()
        return id
    }()
    private let myPeerID = gameService.getPeerID()
    private var colorIndex = 0 {
        didSet {
            delegate?.playerColorIndex(index: colorIndex)
        }
    }
    private var game: Game!

    var delegate: GameManagerDelegate?
    var cardsDelegate: GameCardManagerDelegate?

    var minPlayersNeeded = 1
    var playerNames: [String]! = [] {
        didSet {
            if isHost {
                gameService.messageService.sendPlayerListData(names: playerNames)
            }
        }
    }
    var players: [MCPeerID] = [] {
        didSet {
            newGame(/*playersArray: self.connectedPlayers,*/ newGame: game)
        }
    }
    var playersConnected: [MCPeerID] = [] {
        didSet {
            players = playersConnected
        }
    }
    var playerCount: Int!
    var cardsForPlayer: [[Card]]! {
        didSet {
            if cardsForPlayer.count > 0 {
                if isHost && playerIndexState[0] == myPeerID.displayName {
                    //// print("host is a deck, so no cards given from here")
                } else {
                    cardsDelegate?.cardsSwapped(updatedCards: cardsForPlayer[0], deck: false)
                }
            }
        }
    }
    var cardsInCentre: [Card]! {
        didSet {
            if isHost && playerIndexState[0] == myPeerID.displayName {
                cardsDelegate?.cardsSwapped(updatedCards: cardsInCentre, deck: true)
            }
            if cardsInCentre.count == playerCount && playerCount > 0 {
                let roundWinnerIndex = getBoutWinnerIndex()
                let winner = players[roundWinnerIndex]
                if isHost {
                    gameService.messageService.sendWinnerMessage(bout: .BoutWinnerMessage, player: winner.displayName)
                    delegate?.roundWinner(winner: winner)
                    updateWonRoundCountPerPlayer(player: winner)
                }
            }
        }
    }
    var cardsWonPerPlayer: [[Card]]!
    var roundsWonPerPlayer: [Int]! {
        didSet {
            delegate?.roundsWonPerPlayer(playerArray: playerNames, wonCountArray: roundsWonPerPlayer)
        }
    }
    
    var playerIndexState: [String] = ["noPlayer", "noPlayer", "noPlayer", "noPlayer", "noPlayer"] {
        didSet {
            delegate?.cardStateUpdated(state: playerIndexState)
            if isHost {
                delegate?.setDeck(deck: playerIndexState[0] == myPeerID.displayName)
                var updatedPlayers: [MCPeerID] = []
                for player in playersConnected {
                    if player.displayName != playerIndexState[0] {
                        updatedPlayers.append(player)
                    }
                }
                players = updatedPlayers
                
            } else {
                var updatedPlayers: [MCPeerID] = []
                for player in playersConnected {
                    if player.displayName != playerIndexState[0] {
                        updatedPlayers.append(player)
                    }
                }
                players = updatedPlayers
            }
        }
    }
    
    let colorKey: [Int: String] = [
        0: Constants.Colors.Crazy8.green.rawValue,
        1: Constants.Colors.Crazy8.blue.rawValue,
        2: Constants.Colors.Crazy8.pink.rawValue,
        3: Constants.Colors.Crazy8.yellow.rawValue,
        4: Constants.Colors.Crazy8.red.rawValue
    ]
    
    //MARK:- Initializers
    
    private init() {  }
    
    //MARK:- Member Methods
    
    func setAsHost(host: Bool) {
        isHost = host
        if isHost {
            gameService.gameHostDelegate = self
        } else {
            gameService.gameClientDelegate = self
        }
    }
    
    func sendHostID(name: String) {
//        gameService.messageService.sendHostName(player: name)
    }
    
    func newGame(/*playersArray: [MCPeerID],*/ newGame: Game) {
        
        if isHost {
            sendHostID(name: gameService.getPeerID().displayName)
        }
        
        game = newGame
        minPlayersNeeded = game.minPlayers
        playerCount = players.count
        deck = Deck()
        cardsInCentre = [Card]()
        cardsForPlayer = [[Card]]()
        cardsWonPerPlayer = [[Card]]()
        timeLeft = game.gameTime
        roundsWonPerPlayer = [Int]()
        playerNames = [String]()
        for i in 0..<players.count {
            cardsForPlayer.append([Card]())
            cardsWonPerPlayer.append([Card]())
            roundsWonPerPlayer.append(0)
            playerNames.append(players[i].displayName)
        }
    }
    
    func distributeCards(uiHandler: @escaping (Result<(Card,MCPeerID),CardError>) -> Void) {
        for _ in 0..<numberOfCardsPerPlayer {
            for playerIndex in 0..<players.count {
                if let card = deck.draw() {
                    cardsForPlayer[playerIndex].append(card)
                    gameService.messageService.sendCardExchangePlayerMessage(played: .GiveCardToPlayerMessage, card: card, player: players[playerIndex].displayName)
                    uiHandler(.success((card,players[playerIndex])))
                } else {
                    print("Error getting the card from the deck")
                    uiHandler(.failure(.CardDrawError))
                }
            }
        }
        startTimer()
        if  playerCount > 0 {
            currentPlayerIndex = 0
        }
    }
    
    func throwCardInCenter(player: MCPeerID, card: Card) {
        if isHost {
            throwCardInCenterClient(player: player, card: card)
            gameService.messageService.sendCardExchangePlayerMessage(played: .PlayerTurnedCardHostMessage, card: card, player: player.displayName)
            updateNextPlayer()
        } else {
            gameService.messageService.sendCardExchangePlayerMessage(played: .PlayerTurnedCardClientMessage, card: card, player: player.displayName)
        }
    }
    
    func giveCardToPlayerFromDeck(card: Card, player: MCPeerID) {
        if let cardToTake = deck.draw(card: card) {
            cardsForPlayer[players.firstIndex(of: player)!].append(cardToTake)
            delegate?.gaveCardToPlayer(card: card, playerName: player.displayName)
        } else {
            print("Error getting the card from the deck")
        }
    }
    
    func setTime(time: Int) {
        timeLeft = time
    }
    
    func swapCard(player: MCPeerID, index: Int) {
        if isHost {
            swapCardWithFirst(player: player, index: index)
            gameService.messageService.sendCardsSwappedHostMessage(player: player.displayName, index: index)
        } else {
            gameService.messageService.sendCardsSwappedClientMessage(player: player.displayName, index: index)
        }
    }
    
    func endGame() {
        stopTimer()
    }
    
    func changeplayerIndexState(state: [String]) {
        if isHost {
            playerIndexState = state
        }
        gameService.messageService.sendPlayerPositionState(positionState: state, toHost: !isHost)
    }
    
    //MARK:- Private Methods
    
    private func throwCardInCenterClient(player: MCPeerID, card: Card) {
        cardsInCentre.append(card)
        let playerIndex = players.firstIndex(of: player)!
        let cardIndex = cardsForPlayer[playerIndex].firstIndex(of: card)!
        cardsForPlayer[playerIndex].remove(at: cardIndex)
        delegate?.playerTurnedCard(player: player, card: card)
    }
    
    private func swapCardWithFirst(player: MCPeerID, index: Int) {
        let playerIndex = players.firstIndex(of: player)!
        let card = cardsForPlayer[playerIndex][0]
        cardsForPlayer[playerIndex][0] = cardsForPlayer[playerIndex][index]
        cardsForPlayer[playerIndex][index] = card
        if player.displayName == gameService.getPeerID().displayName {
            cardsDelegate?.cardsSwapped(updatedCards: cardsForPlayer[0], deck: false)
        }
    }
    
    private func getBoutWinnerIndex() -> Int {
        var winnerIndex = 0
        for (index,_) in cardsInCentre.enumerated() {
            if cardsInCentre[index] > cardsInCentre[winnerIndex] {
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
        if currentPlayerIndex == playerCount - 1 {
            currentPlayerIndex = 0
        } else {
            currentPlayerIndex += 1
        }
        if cardsForPlayer[currentPlayerIndex].count == 0 {
            let winner = getGameWinner()
            delegate?.gameWinner(winner: winner)
            gameService.messageService.sendWinnerMessage(bout: .GameWinnerMessage, player: winner.displayName)
        }
    }
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(1.0), repeats: true) { [weak self] (timer) in
            guard let self = self else { return }
            self.timeLeft -= 1
            gameService.messageService.sendRemainingTime(timeString: self.getTimeString())
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
        var timeString = "\(min):\(sec)"
        if sec < 10 {
            timeString = "\(min):0\(sec)"
        }
        return timeString
    }
    
    private func getGameWinner() -> MCPeerID {
        var winnerIndex = 0
        for index in 1..<playerCount {
            if cardsWonPerPlayer[winnerIndex].count < cardsWonPerPlayer[index].count {
                winnerIndex = index
            }
        }
        return players[winnerIndex]
    }
    
    private func updateWonRoundCountPerPlayer(player: MCPeerID) {
        let roundWinnerIndex = players.firstIndex(of: player)!
        roundsWonPerPlayer[roundWinnerIndex] += 1
    }
    
}

//MARK:- GameService Game Client Delegate Methods

extension GameManager: GameServiceGameClientDelegate {
    func playerColorIndex(index: Int) {
        colorIndex = index
    }
    
    func connectedPlayersClient(connectedPlayers: [MCPeerID]) {
        playersConnected = connectedPlayers
//        players = connectedPlayers
    }
    
    func playerListFromHost(playerNameList: [String]) {
        var hostConnectedPlayerList = [MCPeerID]()
        for name in playerNameList {
            if let index = playerNames.firstIndex(of: name) {
                hostConnectedPlayerList.append(players[index])
            }
        }
        players = hostConnectedPlayerList
        if !isHost {
            delegate?.playerList(playerList: players)
        }
    }
    
    func boutWinner(playerName: String) {
        let playerIndex = playerNames.firstIndex(of: playerName)!
        let boutWinner = players[playerIndex]
        delegate?.roundWinner(winner: boutWinner)
        updateWonRoundCountPerPlayer(player: boutWinner)
    }

    func winner(playerName: String) {
        let playerIndex = playerNames.firstIndex(of: playerName)!
        let winner = players[playerIndex]
        delegate?.gameWinner(winner: winner)
        self.stopTimer()
        timeLeft = game.gameTime
    }
    
    func remainingTime(time: Int) {
        timeLeft = time
    }
    
    func nextPlayer(playerName: String) {
        let index = playerNames.firstIndex(of: playerName)!
        currentPlayerIndex = index
    }
    
    func gaveCardToPlayer(card: Card, playerName: String) {
        if !isHost {
            let playerID = players[playerNames.firstIndex(of: playerName)!]
            giveCardToPlayerFromDeck(card: card, player: playerID)
        }
    }
    
    func playerTurnedCard(playerName: String, card: Card) {
        let playerID = players[playerNames.firstIndex(of: playerName)!]
        throwCardInCenterClient(player: playerID, card: card)
    }
    
    func cardsSwapped(byPlayer: String, index: Int) {
        let playerIndex = playerNames.firstIndex(of: byPlayer)!
        let player = players[playerIndex]
        swapCardWithFirst(player: player, index: index)
    }
    
    func hostPositionStateChanged(stateArray: [String]) {
        playerIndexState = stateArray
    }
}

//MARK:- GameService Game Host Delegate Methods

extension GameManager: GameServiceGameHostDelegate {
    func clientPlayerPositionChanged(stateArray: [String]) {
        changeplayerIndexState(state: stateArray)
    }
    
    func connectedPlayersHost(connectedPlayers: [MCPeerID]) {
        playersConnected = connectedPlayers
//        players = connectedPlayers
        gameService.messageService.sendPlayerPositionState(positionState: playerIndexState, toHost: !isHost)
    }
    
    func clientPlayerTurnedCard(playerName: String, card: Card) {
        let playerID = players[playerNames.firstIndex(of: playerName)!]
        throwCardInCenter(player: playerID, card: card)
    }
    
    func clientCardsSwapped(byPlayer: String, index: Int) {
        let playerIndex = playerNames.firstIndex(of: byPlayer)!
        let player = players[playerIndex]
        swapCard(player: player, index: index)
    }
    
    func clientPlayerName(playerName: String) {
        ////  set the name of the player
    }
    
    func clientGameOverMessage() {
        delegate?.quit()
    }
}
