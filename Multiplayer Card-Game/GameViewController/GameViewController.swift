//
//  GameViewController.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 27/12/19.
//  Copyright © 2019 Hot Cocoa Software. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class GameViewController: UIViewController {
    //MARK:- IBOutlets
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var playersTurnLabel: UILabel!
    @IBOutlet var centreDeckTopCard: CardView!
    @IBOutlet var centreDeckBottomCard: CardView!
    @IBOutlet var startGameButton: UIButton!
    
    @IBOutlet var middlePlayerCards: [CardView]! {
        didSet {
            for index in [1,3] {
                self.middlePlayerCards[index].transform = .init(rotationAngle: CGFloat.pi/2)
            }
        }
    }
    
    @IBOutlet var playerCardsWon: [CardView]! {
        didSet {
            for index in [1,3] {
                self.playerCardsWon[index].transform = .init(rotationAngle: CGFloat.pi/2)
            }
        }
    }
    @IBOutlet var playerDeckBottomCard: [CardView]! {
        didSet {
            for index in [1,3] {
                let rotationDirection: CGFloat = index == 1 ? -1 : 1
                self.playerDeckBottomCard[index].transform = .init(rotationAngle: rotationDirection * CGFloat.pi/2)
            }
        }
    }
    @IBOutlet var playerDeckTopCard: [CardView]! {
        didSet {
            for index in [1,3] {
                let rotationDirection: CGFloat = index == 1 ? -1 : 1
                self.playerDeckTopCard[index].transform = .init(rotationAngle: rotationDirection * CGFloat.pi/2)
            }
        }
    }
    @IBOutlet var playerThrownCards: [CardView]! {
        didSet {
            for index in [1,3] {
                let rotationDirection: CGFloat = index == 1 ? -1 : 1
                self.playerThrownCards[index].transform = .init(rotationAngle: rotationDirection * CGFloat.pi/2)
            }
        }
    }
    
    //MARK:- Property variables
    private var connectedPlayers: [MCPeerID]! {
        didSet {
            playerNameArray = connectedPlayers.map({ $0.displayName })
            self.gameManager.newGame(playersArray: self.connectedPlayers)
        }
    }
    private var connectingAlert: UIAlertController?
    private let gameManager = GameManager.shared
    private var cardsGiven = 0
    private var playerNameArray: [String]!
    
    private var gameState: GameState! {
        didSet {
            if isHost || gameState == GameState.gameOver {
                gameService.messageService.sendGameStateMessage(state: gameState)
            }
            switch gameState {
            case .waitingForPlayers:
                title = "Waiting for Players..."
            case .dealing:
                DispatchQueue.main.async { [unowned self] in
                    self.title = "Game"
                    self.timeLabel.isHidden = false
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
                        gameService.stopAdvertisingToPeers()
                        self.gameManager.endGame()
                    }
                }
            case .none:
                print("Do nothing")
            }
        }
    }
    
    var game: Game! {
        didSet {
            gameService.advertiserDelegate = self
            gameService.sessionDelegate = self
            connectedPlayers = [gameService.getPeerID()]
        }
    }
    var isHost = false

    //MARK:- IBAction Methods
    @IBAction func startNewGame(_ sender: UIButton) {
        if connectedPlayers.count >= gameManager.minPlayersNeeded {
            gameManager.sendHostID(name: gameService.getPeerID().displayName)
            gameState = .dealing
            startGame()
            startGameButton.isHidden = true
        } else {
            showOnlyAlert(title: "Unable to start", message: "There must be atleast \(gameManager.minPlayersNeeded) players to start the game")
        }
    }
    @IBAction func quit(_ sender: Any) {
        alert(title: "Confirm disconnection:", message: "Are you sure you want to end the game?") { response in
            if response {
                self.gameState = .gameOver
            }
        }
    }
    
    //MARK:- Lifecycle Hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        gameManager.delegate = self
        gameManager.setAsHost(host: isHost)
        if !isHost {
            startGameButton.isHidden = true
            connectingAlert = loadingAlert(title: "Connecting ...")
            present(connectingAlert!, animated: true, completion: nil)
        } else {
            gameService.hostSession()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(throwCardInCenter(_:)))
        middlePlayerCards[0].addGestureRecognizer(tapGesture)
        
        gameState = .waitingForPlayers
        centreDeckTopCard.isHidden = true
        centreDeckBottomCard.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        AppUtility.lockOrientation(.landscape, andRotateTo: .landscapeLeft)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //MARK:- ViewController Methods
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
      }
    
    //MARK:- Custom Methods
    private func startGame() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.timeLabel.isHidden = false
            self.centreDeckTopCard.isHidden = false
            self.centreDeckBottomCard.isHidden = false
            self.gameManager.distributeCards { [weak self] result in
                guard let self = self else {
                    return
                }
                switch result {
                case .success((let card, let player)):
                    self.giveCardToPlayer(player: player)
                case .failure(let error):
                    print("Error getting card: ",error)
                }
            }
        }
    }
    
    @objc func throwCardInCenter(_ sender: UIGestureRecognizer) {
        gameManager.throwCardInCenter(player: connectedPlayers[0], card: gameManager.cardsForPlayer[0][0])
        playersTurnLabel.isHidden = true
        middlePlayerCards[0].isUserInteractionEnabled = false
    }
    
    private func enablePlayer() {
        middlePlayerCards[0].isUserInteractionEnabled = true
    }
    
    private func giveCardToPlayer(player: MCPeerID) {
        DispatchQueue.main.async { [unowned self] in
            if let index = self.connectedPlayers.firstIndex(of: player) {
                let translateDirection = Constants.distributeDirection[index]
                let translationX: CGFloat = translateDirection.x * 80.0 //middlePlayerCards[index].frame.origin.x - centreDeckTopCard.frame.origin.x
                let translationY: CGFloat = translateDirection.y * 80.0 //middlePlayerCards[index].frame.origin.y - centreDeckTopCard.frame.origin.y
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn], animations: {
                    self.centreDeckTopCard.transform = .init(translationX: translationX, y: translationY)
                },completion: { finish in
                    self.cardsGiven += 1
                    if self.cardsGiven <= self.gameManager.playerCount {
                        self.middlePlayerCards[index].isHidden = false
                    } else if self.cardsGiven <= 2 * self.gameManager.playerCount {
                        self.playerDeckBottomCard[index].isHidden = false
                    } else {
                        self.playerDeckTopCard[index].isHidden = false
                    }
                    self.centreDeckTopCard.transform = .identity
                })
            }
        }
    }
    
    private func playerTurnedCard(card: Card, player: MCPeerID) {
        DispatchQueue.main.async { [unowned self] in
            if let index = self.connectedPlayers.firstIndex(of: player) {
                let translateDirection = Constants.distributeDirection[index]
                let translationX: CGFloat = translateDirection.x * 80.0 //middlePlayerCards[index].frame.origin.x - centreDeckTopCard.frame.origin.x
                let translationY: CGFloat = translateDirection.y * 80.0 //middlePlayerCards[index].frame.origin.y - centreDeckTopCard.frame.origin.y
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn], animations: {
                    self.middlePlayerCards[index].transform = .init(translationX: -translationX, y: -translationY)
                },completion: { finish in
                    self.middlePlayerCards[index].isFaceUp = false
                    self.playerThrownCards[index].rank = card.rank.order
                    self.playerThrownCards[index].suit = card.suit.description
                    self.playerThrownCards[index].isHidden = false
                    self.middlePlayerCards[index].transform = .identity
                    self.gameState = .playing
                })
            }
        }
    }
    
    private func giveCenterCardsToWinner(player: MCPeerID) {
        DispatchQueue.main.async { [unowned self] in
            if let index = self.connectedPlayers.firstIndex(of: player) {
                let translateDirection = Constants.distributeDirection[index]
                let translationX: CGFloat = translateDirection.x * 80.0 //middlePlayerCards[index].frame.origin.x - centreDeckTopCard.frame.origin.x
                let translationY: CGFloat = translateDirection.y * 80.0 //middlePlayerCards[index].frame.origin.y - centreDeckTopCard.frame.origin.y
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn], animations: {
                    for cardView in self.playerThrownCards {
                        cardView.transform = .init(translationX: translationX, y: translationY)
                    }
                },completion: { finish in
                    for cardView in self.playerThrownCards {
                        cardView.isHidden = true
                        cardView.transform = .identity
                    }
                    self.playerCardsWon[index].isHidden = false
                    self.playerCardsWon[index].suit = self.playerThrownCards[0].suit
                    self.playerCardsWon[index].rank = self.playerThrownCards[0].rank
                    self.gameState = .playing
                })
            }
        }
    }
}

//MARK:- GameService Session Delegate Methods
extension GameViewController: GameServiceSessionDelegate {
    func connectedWithPeer(peerID: MCPeerID) {
        print("Connected with peer: ", peerID.displayName)
        if let index = connectedPlayers.firstIndex(of: peerID) {
            connectedPlayers[index] = peerID
        } else {
            connectedPlayers.append(peerID)
        }
        
        if !isHost {
            gameService.stopBrowsingForPeers()
        } else {
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
            self?.connectingAlert?.dismiss(animated: true, completion: nil)
            self?.gameManager.endGame()
            self?.navigationController?.popViewController(animated: true)
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
extension GameViewController: GameServiceAdvertiserDelegate {
    func invitationWasReceived(fromPeer: String, handler: @escaping (Bool, MCSession?) -> Void, session: MCSession) {
        self.alert(title: "Invitation to Connect", message: "\(fromPeer) wants to connect.") { (response) in
            if response {
                
            }
            handler(response,session)
        }
    }
}

//MARK:- GameManager Delegate Methods
extension GameViewController: GameManagerDelegate {

    func roundWinner(winner: MCPeerID) {
        gameState = .decidingRoundWinner
        giveCenterCardsToWinner(player: winner)
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
        print("\(card) recieved by ", playerName)
        let playerID = connectedPlayers[playerNameArray.firstIndex(of: playerName)!]
        giveCardToPlayer(player: playerID)
    }
    
    func playerTurnedCard(player: MCPeerID, card: Card) {
        print("\(player.displayName) gave the card: ",card)
        playerTurnedCard(card: card, player: player)
    }
        
    func nextPlayerTurn(playerName: String) {
        DispatchQueue.main.async { [unowned self] in
            self.playersTurnLabel.isHidden = false
            self.playersTurnLabel.text = "\(playerName)'s turn"
            if self.connectedPlayers[0].displayName == playerName {
                self.enablePlayer()
            }
        }
    }
}
