//
//  DeckGameViewController.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 16/01/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import UIKit
import MultipeerConnectivity

//MARK:- Enum CardState

fileprivate enum CardsState {
    case unselected
    case selected
    case taken
}

fileprivate enum StartButtonState {
    case startOrWaiting
    case options
}

class DeckGameViewController: UIViewController {
    
    //MARK:- IBOUtlets
    
    @IBOutlet var startGameAndOptionsButton: UIButton! {
        didSet {
            startGameAndOptionsButton.addShadow()
            startGameAndOptionsButton.layer.cornerRadius = Constants.buttonCornerRadius
        }
    }
    @IBOutlet var gameStateLabel: UILabel!
    @IBOutlet var connectedPlayersLabel: UILabel!
    
    @IBOutlet var stackViewDeck: UIStackView!
    @IBOutlet var deckRightView: UIView!
    @IBOutlet var deckLeftView: UIView!

    @IBOutlet var player1StackView: UIStackView!
    @IBOutlet var player2StackView: UIStackView!
    @IBOutlet var player3StackView: UIStackView!
    @IBOutlet var player4StackView: UIStackView!
    
    @IBOutlet var emptyPlayerView: [UIView]!
    
    @IBOutlet var player1Cards: [UIView]!
    @IBOutlet var player2Cards: [UIView]!
    @IBOutlet var player3Cards: [UIView]!
    @IBOutlet var player4Cards: [UIView]!
    
    @IBOutlet var playerNameLabel: [UILabel]!
    
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var playersTurnLabel: UILabel!
    
    @IBOutlet var roundsWonLabel: [UILabel]!
    
    //MARK:- Property Variables
    
    private var cardViews: [[UIView]]!
    private var noPlayer = Constants.noplayer
    private var colorKey: [Int: String]!
    private let unSelectColor = Constants.Colors.color[Constants.Colors.Crazy8.lightGrey.rawValue]!
    private let takenColor = Constants.Colors.color[Constants.Colors.Crazy8.darkGrey.rawValue]!
    private var connectingAlert: UIAlertController?
    private let gameManager = GameManager.shared
    private let animationDuration = 0.8
    private let myName = gameService.getPeerID().displayName
    
    private var selectedColor: UIColor! {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.startGameAndOptionsButton?.backgroundColor = self.selectedColor
                self.gameStateLabel.textColor = self.selectedColor
                self.setColor(self.selectedColor)
            }
        }
    }
    
    private var startOrOptionsButtonState = StartButtonState.startOrWaiting {
           didSet {
               switch startOrOptionsButtonState {
               case .startOrWaiting:
                   if isHost{
                       startGameAndOptionsButton.setTitle("Start Game", for: .normal)
                   } else {
                       startGameAndOptionsButton.setTitle("Waiting for Game Start", for: .normal)
                   }
               case .options:
                   self.startGameAndOptionsButton.setTitle("Options", for: .normal)
               }
           }
       }
    
    private var cardViewsState: [CardsState]! {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                for index in 0..<self.cardViewsState.count {
                    switch self.cardViewsState[index] {
                    case .unselected:
                        if index == 0 {
                            self.setViewColor(viewsArray: [self.cardViews[index][0]], color: self.unSelectColor)
                            self.addBorderToViews(viewArrays: [[self.cardViews[index][1]]], color: UIColor.white)
                        } else {
                            self.setViewColor(viewsArray: self.cardViews[index], color: self.unSelectColor)
                        }
                        self.playerNameLabel[index].textColor = self.unSelectColor
                        var name = "Player \(index)"
                        if index == 0 {
                            name = "Deck"
                        }
                        self.playerNameLabel[index].text = name
                    case .selected:
                        if index == 0 {
                            self.setViewColor(viewsArray: [self.cardViews[index][0]], color: self.selectedColor)
                            self.addBorderToViews(viewArrays: [[self.cardViews[index][1]]], color: self.selectedColor)
                        } else {
                            self.setViewColor(viewsArray: self.cardViews[index], color: self.selectedColor)
                        }
                        self.playerNameLabel[index].textColor = self.selectedColor
                        self.playerNameLabel[index].text = self.playerIndexState[index]
                        print(self.playerIndexState[index])
                    case .taken:
                        if index == 0 {
                            self.setViewColor(viewsArray: [self.cardViews[index][0]], color: self.takenColor)
                            self.addBorderToViews(viewArrays: [[self.cardViews[index][1]]], color: self.takenColor)
                        } else {
                            self.setViewColor(viewsArray: self.cardViews[index], color: self.takenColor)
                        }
                        self.playerNameLabel[index].textColor = self.takenColor
                        self.playerNameLabel[index].text = self.playerIndexState[index]
                    }
                }
            }
        }
    }
    
    private var connectedPlayers: [MCPeerID]! {
        didSet {
            playerNameArray = connectedPlayers.map({ $0.displayName })
            self.gameManager.newGame(/*playersArray: self.connectedPlayers,*/ newGame: game)
        }
    }
    private var playerNameArray: [String]! {
        didSet {
            var labelString = "CONNECTED:\n"
            for player in playerNameArray {
                labelString += "\(player)\n"
            }
            DispatchQueue.main.async { [weak self] in
                
            }
        }
    }
    
    private var gameState: GameState! {
        didSet {
            if isHost {
                gameService.messageService.sendGameStateMessage(state: gameState)
            }
            switch gameState {
            case .waitingForPlayers:
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.title = "Waiting for Players..."
                    var gameStateDescription = ""
                    if self.isHost {
                        gameStateDescription = "Start the game or wait for more devices"
                    } else {
                       gameStateDescription = "Will begin when host taps Start Game"
                    }
                    self.gameStateLabel.text = gameStateDescription
                }
            case .dealing:
                DispatchQueue.main.async { [unowned self] in
                    self.title = "Game"
                    if self.isHost {
                        gameService.stopAdvertisingToPeers()
                    }
                    for index in 1..<self.playerIndexState.count {
                        if self.playerIndexState[index] != self.noPlayer {
                            self.roundsWonLabel[index].isHidden = false
                        }
                    }
                    self.timeLabel.isHidden = false
                    self.connectedPlayersLabel.isHidden = true
                    self.gameStateLabel.text = "Game has started"
                    self.startOrOptionsButtonState = .options
                    self.disableUserInteraction(viewArrays: self.cardViews)
                }
            case .decidingRoundWinner:
                print("round winner decided")
            case .playing:
                print("play the game turn by turn")
                DispatchQueue.main.async { [unowned self] in
                    self.playersTurnLabel.isHidden = false
                    
                }
            case .gameOver:
                DispatchQueue.main.async { [unowned self] in
                    self.dismiss(animated: true) {
                        AppUtility.lockOrientation(.all)
                        let value = UIInterfaceOrientation.portrait.rawValue
                        UIDevice.current.setValue(value, forKey: "orientation")
                        gameService.disconnectSession()
                        if self.isHost {
                            gameService.stopAdvertisingToPeers()
                            self.gameManager.endGame()
                        } else {
                            gameService.joinSession()
                        }
                    }
                }
            case .none:
                print("Do nothing")
            }
        }
    }
    
    private var playerIndexState: [String] = ["noPlayer", "noPlayer", "noPlayer", "noPlayer", "noPlayer"] {
        didSet {
            for (i,playerName) in playerIndexState.enumerated() {
                if playerName == noPlayer {
                    cardViewsState[i] = .unselected
                } else if playerName == myName {
                    cardViewsState[i] = .selected
                } else {
                    cardViewsState[i] = .taken
                }
            }
        }
    }
    
    var isHost: Bool! {
        didSet {
            gameManager.setAsHost(host: isHost)
        }
    }
    
    var indexToPlay = 0 {
        didSet {
            selectedColor = Constants.Colors.color[colorKey[indexToPlay]!]!
        }
    }
    
    var game: Game! {
        didSet {
            gameService.advertiserDelegate = self
            gameService.sessionDelegate = self
            connectedPlayers = [gameService.getPeerID()]
            colorKey = gameManager.colorKey
            selectedColor = Constants.Colors.color[colorKey[indexToPlay]!]!
            gameManager.delegate = self
        }
    }
    
    var setDeck: ((Bool) -> Void)!
    var enablePlayer: ((Bool)->Void)!
    var setColor: ((UIColor)-> Void)!
    
    
    //MARK:- IBActions
    
    @IBAction func startGameOrOptions(_ sender: UIButton) {
        switch startOrOptionsButtonState {
        case .startOrWaiting:
            if connectedPlayers.count >= gameManager.minPlayersNeeded {
                if getSelectedPlayerCount() > 1 {
                    gameState = .dealing
                    startGame()
                } else {
                    showOnlyAlert(title: "Unable to start", message: "There must be atleast \(gameManager.minPlayersNeeded) players to start the game")
                }
            } else {
                showOnlyAlert(title: "Unable to start", message: "There must be atleast \(gameManager.minPlayersNeeded) players to start the game")
            }
        case .options:
            print("options selected")
        }
        
    }
    
    //MARK:- Lifecycle Hooks

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardViews =  [[deckLeftView, deckRightView], player1Cards, player2Cards, player3Cards, player4Cards]
        
        cardViewsState = [.unselected, .unselected, .unselected, .unselected, .unselected]

        addShadowToViews(viewArrays: [[deckRightView, deckLeftView]])
        
        addShadowToViews(viewArrays: [player1Cards, player2Cards, player3Cards, player4Cards], offset: Constants.shadowOffsetCard)
        
        addBorderToViews(viewArrays: [emptyPlayerView])
        rotateViewArray(viewArrays: [emptyPlayerView, [player1StackView, player2StackView, player3StackView, player4StackView]])
        
        for label in playerNameLabel {
            label.textColor = unSelectColor
        }
        
        startOrOptionsButtonState = .startOrWaiting
        
        if isHost {
            gameService.hostSession()
            
            stackViewDeck.isUserInteractionEnabled = true
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectDeck(_:)))
            stackViewDeck.addGestureRecognizer(tapRecognizer)
            for deckView in cardViews[0] {
                let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectDeck(_:)))
                deckView.addGestureRecognizer(tapRecognizer)
            }
        } else {
            connectingAlert = loadingAlert(title: "Connecting ...")
            present(connectingAlert!, animated: true, completion: nil)
            gameService.stopBrowsingForPeers()
        }

        for playerIndex in 1..<cardViews.count {
            for cardIndex in 0..<cardViews[playerIndex].count {
                let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectedPlayer(_:)))
                cardViews[playerIndex][cardIndex].addGestureRecognizer(tapRecognizer)
            }
        }
        
        deckRightView.addRoundCorner()
        
        gameState = .waitingForPlayers

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AppUtility.lockOrientation(.all)
    }
    
    //MARK:- Custom Methods
    
    @objc func selectedPlayer(_ sender: UIGestureRecognizer) {
        if let tappedView = sender.view, let playerIndex = getPlayerIndexOf(cardView: tappedView) {
            var newPlayerIndexState = playerIndexState
            if cardViewsState[playerIndex] == .unselected {
                if let index = newPlayerIndexState.firstIndex(of: myName) {
                    newPlayerIndexState[index] = noPlayer
                }
                newPlayerIndexState[playerIndex] = myName
                gameManager.changeplayerIndexState(state: newPlayerIndexState)
            }
        }
    }
    
    @objc func selectDeck(_ sender: UIGestureRecognizer) {
        var newPlayerIndexState = playerIndexState
        if cardViewsState[0] == .unselected {
            if let index = newPlayerIndexState.firstIndex(of: myName) {
                newPlayerIndexState[index] = noPlayer
            }
            newPlayerIndexState[0] = myName
            gameManager.changeplayerIndexState(state: newPlayerIndexState)
        }
    }
    
    //MARK:- Private Methods
    
    private func getSelectedPlayerCount() -> Int {
        var count = 0
        for playerName in playerIndexState {
            if playerName != noPlayer {
                count += 1
            }
        }
        return count
    }
    
    private func getPlayerIndexOf(cardView: UIView) -> Int? {
        for playerIndex in 1..<5 {
            if let _ = cardViews[playerIndex].firstIndex(of: cardView) {
                return playerIndex
            }
        }
        return nil
    }
    
    private func rotateViewArray(viewArrays: [[UIView]]) {
        for viewArray in viewArrays {
            for index in 0..<viewArray.count {
                if index == 1 || index == 3 {
                    let rotationDirection: CGFloat = index == 1 ? -1 : 1
                    viewArray[index].transform = .init(rotationAngle: rotationDirection * CGFloat.pi/2)
                }
            }
        }
    }
    
    private func addShadowToViews(viewArrays: [[UIView]], offset: CGSize = CGSize(width: 0, height: 0)) {
        for viewArray in viewArrays {
            for index in 0..<viewArray.count {
                viewArray[index].addShadow(offset: offset)
                viewArray[index].layer.cornerRadius = Constants.buttonCornerRadius
            }
        }
    }
    
    private func addBorderToViews(viewArrays: [[UIView]], color: UIColor = Constants.shadowColor) {
        for viewArray in viewArrays {
            for index in 0..<viewArray.count {
                viewArray[index].addBorder(color: color)
            }
        }
    }
    
    private func setViewColor(viewsArray: [UIView], color: UIColor) {
        for viewToColor in viewsArray {
            viewToColor.backgroundColor = color
        }
    }
    
    private func disableUserInteraction(viewArrays: [[UIView]]) {
        for viewArray in viewArrays {
            for index in 0..<viewArray.count {
                viewArray[index].isUserInteractionEnabled = false
            }
        }
    }
    
    private func quit(_ sender: Any) {
        alert(title: "Confirm disconnection:", message: "Are you sure you want to end the game?") { response in
            if response {
                if self.isHost || self.gameState == GameState.waitingForPlayers {
                    self.gameState = .gameOver
                } else {
                    gameService.messageService.sendClientGameOverToHost()
                }
            }
        }
    }
    
    private func startGame() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.timeLabel.isHidden = false
            self.gameManager.distributeCards { [weak self] result in
                guard let self = self else {
                    return
                }
                switch result {
                case .success((let card, let player)):
                    print("gave \(card) to \(player)")
                case .failure(let error):
                    print("Error getting card: ",error)
                }
            }
        }
    }
}

//MARK:- Gesture Recognizer Delegate Methods

//extension DeckGameViewController: UIGestureRecognizerDelegate {
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//}

//MARK:- GameService Session Delegate Methods

extension DeckGameViewController: GameServiceSessionDelegate {
    
    func connectedWithPeer(peerID: MCPeerID) {
        print("Connected with peer: ", peerID.displayName)
        if let index = connectedPlayers.firstIndex(of: peerID) {
            connectedPlayers[index] = peerID
        } else {
            connectedPlayers.append(peerID)
        }
        if isHost {
            if connectedPlayers.count == 4 {
                gameService.stopAdvertisingToPeers()
            }
        }
        
        DispatchQueue.main.async {
            self.connectingAlert?.dismiss(animated: true, completion: nil)
        }
        showOnlyAlert(title: "Connected", message: "Successfully connected with \(peerID.displayName)")
    }
    
    func connectionFailed(peerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.connectedPlayers.removeAll(where: {$0 == peerID})
            if self.gameState == GameState.waitingForPlayers && self.isHost {
                self.showOnlyAlert(title: "\(peerID.displayName) Left", message: "\(peerID.displayName) disconnected from the game.")
            } else if !self.isHost {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func recievedData(data: String, fromPeerID: MCPeerID) {
        print("Recieved data: ",data)
    }
    
    func stateChanged(newState: GameState) {
        gameState = newState
    }
}

//MARK:- GameService Advertiser Delegate Methods

extension DeckGameViewController: GameServiceAdvertiserDelegate {
    
    func invitationWasReceived(fromPeer: String, handler: @escaping (Bool, MCSession?) -> Void, session: MCSession) {
        self.alert(title: "Invitation to Connect", message: "\(fromPeer) wants to connect.") { (response) in
            handler(response,session)
        }
    }
}

//MARK:- GameManager Delegate Methods

extension DeckGameViewController: GameManagerDelegate {
    func cardStateUpdated(state: [String]) {
        playerIndexState = state
    }
    
    func playerColorIndex(index: Int) {
        indexToPlay = index
    }
    
    func playerList(playerList: [MCPeerID]) {
        connectedPlayers = playerList
        print("player list from host",connectedPlayers)
    }
    
    func roundWinner(winner: MCPeerID) {
        gameState = .decidingRoundWinner
        gameState = .playing
    }
    
    func gameWinner(winner: MCPeerID) {
        alert(title: "Game Over", message: "\(winner.displayName) won the game") { _ in
            self.gameState = .gameOver
        }
    }
    
    func timeRemaining(timeString: String) {
        DispatchQueue.main.async { [weak self] in
            self?.timeLabel.text = timeString
        }
    }
    
    func gaveCardToPlayer(card: Card, playerName: String) {
        let playerID = connectedPlayers[playerNameArray.firstIndex(of: playerName)!]
        print("gave \(card) to player: ",playerID.displayName)
    }
    
    func playerTurnedCard(player: MCPeerID, card: Card) {
    }
        
    func nextPlayerTurn(playerName: String) {
        DispatchQueue.main.async { [weak self] in
            self?.playersTurnLabel.isHidden = false
            self?.playersTurnLabel.text = "\(playerName)'s turn"
            if self?.connectedPlayers[0].displayName == playerName {
                self?.enablePlayer(true)
            } else {
                self?.enablePlayer(false)
            }
        }
    }
    
    func roundsWonPerPlayer(playerArray: [String], wonCountArray: [Int]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, wonCountArray.count > 0 else { return }
            for (index,playername) in playerArray.enumerated() {
                if let playerIndex = self.playerIndexState.firstIndex(of: playername) {
                    self.roundsWonLabel[playerIndex].text = "Won: \(wonCountArray[index])"
                }
            }
        }
    }
    
    func setDeck(deck: Bool) {
        setDeck(deck)
    }
    
    func quit() {
        gameState = .gameOver
    }
}
