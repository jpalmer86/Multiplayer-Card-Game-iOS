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
    @IBOutlet var centreDeckTopCard: CardView!
    @IBOutlet var centreDeckBottomCard: CardView!
    @IBOutlet var startGameButton: UIButton!
    @IBOutlet var middlePlayerCards: [CardView]! {
        didSet {
            for index in [1,3] {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn], animations: {
                    self.middlePlayerCards[index].transform = .init(rotationAngle: CGFloat.pi/2)
                },completion: nil )
            }
            
//            for card in middlePlayerCards {
//                
//            }
        }
    }
    
    @IBOutlet var playerCardsWon: [CardView]! {
        didSet {
            for index in [1,3] {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn], animations: {
                    self.playerCardsWon[index].transform = .init(rotationAngle: CGFloat.pi/2)
                },completion: nil )
            }
        }
    }
    @IBOutlet var playerDeckBottomCard: [CardView]! {
        didSet {
            for index in [1,3] {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn], animations: {
                    self.playerDeckBottomCard[index].transform = .init(rotationAngle: CGFloat.pi/2)
                },completion: nil )
            }
        }
    }
    @IBOutlet var playerDeckTopCard: [CardView]! {
        didSet {
            for index in [1,3] {
                let rotationDirection: CGFloat = index == 1 ? -1 : 1
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn], animations: {
                    self.playerDeckTopCard[index].transform = .init(rotationAngle: rotationDirection * CGFloat.pi/2)
                },completion: nil )
            }
        }
    }
    
    //MARK:- Property variables
    private lazy var connectedPlayers = [gameService.getPeerID()]
    private var connectingAlert: UIAlertController?
    private let gameManager = GameManager.shared
    private var dispatchGroup = DispatchGroup()
    private var cardsGiven = 0
    
    private var gameState: GameState! {
        didSet {
            switch gameState {
            case .waitingForPlayers:
                title = "Waiting for Players..."
            case .dealing:
                startGame()
            case .decidingRoundWinner:
                print("round winner decided")
            case .playing:
                print("play the game turn by turn")
            case .gameOver:
                navigationController?.popViewController(animated: true)
            case .none:
                print("Do nothing")
            }
        }
    }
    
    var game: Game! {
        didSet {
            gameService.advertiserDelegate = self
            gameService.sessionDelegate = self
        }
    }
    var isHost = false

    //MARK:- IBAction Methods
    @IBAction func startNewGame(_ sender: UIButton) {
        if connectedPlayers.count >= gameManager.minPlayersNeeded {
            gameState = .dealing
            startGameButton.isHidden = true
        } else {
            showOnlyAlert(title: "Unable to start", message: "There must be atleast \(gameManager.minPlayersNeeded) players to start the game")
        }
    }
    
    //MARK:- Lifecycle Hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        gameManager.delegate = self
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        if !isHost {
            startGameButton.isHidden = true
            connectingAlert = loadingAlert(title: "Connecting ...")
            present(connectingAlert!, animated: true, completion: nil)
        } else {
            gameService.hostSession()
        }
        gameState = .waitingForPlayers
        centreDeckTopCard.isHidden = true
        centreDeckBottomCard.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        AppUtility.lockOrientation(.landscape)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        alert(title: "Confirm disconnection:", message: "Are you sure you want to end the game?") { response in
            if response {
                gameService.stopAdvertisingToPeers()
                gameService.disconnectSession()
                super.viewWillDisappear(animated)
            }
        }
        AppUtility.lockOrientation(.all)
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
        title = "Game"
        timeLabel.isHidden = false
        centreDeckTopCard.isHidden = false
        centreDeckBottomCard.isHidden = false
        gameManager.newGame(playersArray: connectedPlayers)
        gameManager.distributeCards { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success((let card, let player)):
                print("gave \(card) to \(player)")
                self.giveCardToPlayer(player: player)
            case .failure(let error):
                print("Error getting card: ",error)
            }
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {
            self.gameState = .playing
        }
    }
    
    private func giveCardToPlayer(player: MCPeerID) {
        cardsGiven += 1
        if let index = connectedPlayers.firstIndex(of: player) {
            let translateDirection = Constants.distributeDirection[index]
            let translationX: CGFloat = translateDirection.x * 80.0 //middlePlayerCards[index].frame.origin.x - centreDeckTopCard.frame.origin.x
            let translationY: CGFloat = translateDirection.y * 80.0 //middlePlayerCards[index].frame.origin.y - centreDeckTopCard.frame.origin.y
            self.dispatchGroup.enter()
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn], animations: {
                self.centreDeckTopCard.transform = .init(translationX: translationX, y: translationY)
            },completion: { finish in
                if self.cardsGiven <= self.gameManager.playerCount {
                    self.middlePlayerCards[index].isHidden = false
                } else if self.cardsGiven <= 2 * self.gameManager.playerCount {
                    self.playerDeckBottomCard[index].isHidden = false
                } else {
                    self.playerDeckTopCard[index].isHidden = false
                }
                self.centreDeckTopCard.transform = .identity
                self.dispatchGroup.leave()
            })
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
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    func recievedData(data: String, fromPeerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            self?.showOnlyAlert(title: "Data Recieved", message: data)
        }
    }
}

//MARK:- GameService Advertiser Delegate Methods
extension GameViewController: GameServiceAdvertiserDelegate {
    func invitationWasReceived(fromPeer: String, handler: @escaping (Bool, MCSession?) -> Void, session: MCSession) {
        self.alert(title: "Invitation to Connect", message: "\(fromPeer) wants to connect.") { (response) in
            handler(response,session)
        }
    }
}

//MARK:- GameManager Delegate Methods
extension GameViewController: GameManagerDelegate {
    func roundWinner(winner: MCPeerID) {
        gameState = .decidingRoundWinner
        //animate cards coming to winning deck then change game state to playing
    }
    
    func gameWinner(winner: MCPeerID) {
        alert(title: "Game Over", message: "\(winner.displayName) won the game") { _ in
            self.gameState = .gameOver
        }
    }
    
    func timeRemaining(timeString: String) {
        timeLabel.text = timeString
    }
}
