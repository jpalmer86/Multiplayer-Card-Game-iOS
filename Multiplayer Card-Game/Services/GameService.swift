//
//  GameService.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 27/12/19.
//  Copyright © 2019 Hot Cocoa Software. All rights reserved.
//
// Service type for mcpeerconnectivity valid characters include ASCII lowercase letters, numbers, and the hyphen(single)

import MultipeerConnectivity

//MARK:- Protocols

protocol GameServiceBrowserDelegate {
    func updatedPeers(peers: [MCPeerID])
}

protocol GameServiceAdvertiserDelegate {
    func invitationWasReceived(fromPeer: String, handler: @escaping (Bool, MCSession?) -> Void, session: MCSession)
}

protocol GameServiceSessionDelegate {
    func connectedWithPeer(peerID: MCPeerID)
    func connectionFailed(peerID: MCPeerID)
    func recievedData(data: String, fromPeerID: MCPeerID)
    func stateChanged(newState: GameState)
}

protocol GameServiceGameClientDelegate {
    func boutWinner(playerName: String)
    func winner(playerName: String)
    func nextPlayer(playerName: String)
    func gaveCardToPlayer(card: Card, playerName: String)
    func playerTurnedCard(playerName: String, card: Card)
    func remainingTime(time: Int)
    func cardsSwapped(byPlayer: String, index: Int)
    func gameHost(hostName: String)
    func playerListFromHost(playerNameList: [String])
    func connectedPlayersClient(connectedPlayers: [MCPeerID])
    func playerColorIndex(index: Int)
    func hostPositionStateChanged(stateArray: [String])
}

protocol GameServiceGameHostDelegate {
    func clientPlayerTurnedCard(playerName: String, card: Card)
    func clientCardsSwapped(byPlayer: String, index: Int)
    func clientPlayerName(playerName: String)
    func clientGameOverMessage()
    func connectedPlayersHost(connectedPlayers: [MCPeerID])
    func clientPlayerPositionChanged(stateArray: [String])
}

//MARK:- Service Class

class GameService: NSObject {
    // MARK:- Property Variables
    
    static var shared = GameService()
    var browserDelegate: GameServiceBrowserDelegate?
    var advertiserDelegate: GameServiceAdvertiserDelegate?
    var sessionDelegate: GameServiceSessionDelegate?
    var gameClientDelegate: GameServiceGameClientDelegate?
    var gameHostDelegate: GameServiceGameHostDelegate?
    let messageService = MessageService.shared

    private var myPeerID: MCPeerID! = MCPeerID(displayName: UIDevice.current.name)
    private lazy var session: MCSession = {
        let session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser: MCNearbyServiceBrowser!
    private var serviceType = ""
    
    private var foundPeers = [MCPeerID]() {
        didSet {
            browserDelegate?.updatedPeers(peers: foundPeers)
        }
    }
    var isHost: Bool!
    
    private var connectedPeers: [MCPeerID]! = [] {
        didSet {
            gameHostDelegate?.connectedPlayersHost(connectedPlayers: connectedPeers)
            gameClientDelegate?.connectedPlayersClient(connectedPlayers: connectedPeers)
            if connectedPeers.count > 1 {
                messageService.setHost(hostID: connectedPeers[1])
            }
        }
    }
        
    //MARK:- Constructor
    
    private override init() {
        super.init()
        myPeerID = MCPeerID(displayName: UIDevice.current.name)
        messageService.setSession(mcSession: session)
    }
    
    //MARK:- Member Methods
    
    func setServiceType(serviceType: String) {
        self.serviceType = serviceType
        setUpService()
    }

    func getPeerID() -> MCPeerID {
        return myPeerID
    }

    func hostSession() {
        isHost = true
        connectedPeers.append(myPeerID)
        advertiser.startAdvertisingPeer()
    }
    
    func joinSession() {
        isHost = false
        browser.startBrowsingForPeers()
    }
    
    func invitePeer(peerID: MCPeerID) {
         browser.invitePeer(peerID, to: session, withContext: nil, timeout: 20)
    }
    
    func stopBrowsingForPeers() {
        browser.stopBrowsingForPeers()
        foundPeers = []
    }
    
    func stopAdvertisingToPeers() {
        advertiser.stopAdvertisingPeer()
    }
    
    func disconnectSession() {
        session.disconnect()
        connectedPeers = []
    }
    
    //MARK:- Private methods
    
    private func setUpService() {
        if serviceType != "" {
            advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
            advertiser.delegate = self
            browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
            browser.delegate = self
        }
    }
    
    private func removePeer(id: MCPeerID) {
        for (index, aPeer) in foundPeers.enumerated() {
            if aPeer.displayName == id.displayName {
                foundPeers.remove(at: index)
                break
            }
        }
    }
}

//MARK:- MCSession Delegate Methods
extension GameService: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
          print("Connected: \(peerID.displayName)")
          sessionDelegate?.connectedWithPeer(peerID: peerID)
          if let index = connectedPeers.firstIndex(of: peerID) {
              connectedPeers[index] = peerID
          } else {
              connectedPeers.append(peerID)
          }
          if isHost {
            let playerIndex = connectedPeers.firstIndex(of: peerID)!
            messageService.sendPlayerIndex(peerID: peerID, index: playerIndex)
          }
        case .connecting:
          print("Connecting: \(peerID.displayName)")
        case .notConnected:
          print("Not Connected: \(peerID.displayName)")
          sessionDelegate?.connectionFailed(peerID: peerID)
          removePeer(id: peerID)
          connectedPeers.removeAll(where: { $0.displayName == peerID.displayName })
        @unknown default:
          print("fatal error")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let message = String(data: data, encoding: .utf8)!
        let messageType = messageService.getMessageType(data: data)
        
        switch messageType {
        case .BoutWinnerMessage:
            let winnerName = messageService.winnerData(data: data)
            gameClientDelegate?.boutWinner(playerName: winnerName)
        case .GameStateChangeMessage:
            let state = messageService.gameStateData(data: data)
            sessionDelegate?.stateChanged(newState: state)
        case .GameOverClientMessage:
            gameHostDelegate?.clientGameOverMessage()
        case .GameWinnerMessage:
            let gameWinnerName = messageService.winnerData(data: data)
            gameClientDelegate?.winner(playerName: gameWinnerName)
        case .GiveCardToPlayerMessage:
            let dict = messageService.cardExchangeData(data: data)
            let playerName = dict.keys.first!
            gameClientDelegate?.gaveCardToPlayer(card: dict[playerName]!, playerName: playerName)
        case .PlayerTurnedCardHostMessage:
            let dict = messageService.cardExchangeData(data: data)
            let playerName = dict.keys.first!
            gameClientDelegate?.playerTurnedCard(playerName: playerName, card: dict[playerName]!)
        case .PlayerTurnedCardClientMessage:
            let dict = messageService.cardExchangeData(data: data)
            let playerName = dict.keys.first!
            gameHostDelegate?.clientPlayerTurnedCard(playerName: playerName, card: dict[playerName]!)
        case .RemainingTimeMessage:
            let time = messageService.timeData(data: data)
            gameClientDelegate?.remainingTime(time: time)
        case .CardsSwappedHostMessage:
            let dict = messageService.cardsSwappedData(data: data)
            let playerName = dict.keys.first!
            let index = dict[playerName]!
            gameClientDelegate?.cardsSwapped(byPlayer: playerName, index: index)
        case .CardsSwappedClientMessage:
            let dict = messageService.cardsSwappedData(data: data)
            let playerName = dict.keys.first!
            let index = dict[playerName]!
            gameHostDelegate?.clientCardsSwapped(byPlayer: playerName, index: index)
        case .NextPlayerTurnMessage:
            let nextPlayerName = messageService.nextPlayerData(data: data)
            gameClientDelegate?.nextPlayer(playerName: nextPlayerName)
        case .HostNameMessage:
            let hostName = messageService.getHostNameData(data: data)
            print("Game Host is:",hostName)
            gameClientDelegate?.gameHost(hostName: hostName)
        case .ClientNameMessage:
            let clientPlayerName = messageService.getClientPlayerName(data: data)
            gameHostDelegate?.clientPlayerName(playerName: clientPlayerName)
        case .PlayerNameListMessage:
            let playerNameList = messageService.getPlayerNameList(data: data)
//            gameClientDelegate?.playerListFromHost(playerNameList: playerNameList)
        case .PlayerIndexMessage:
            let playerIndex = messageService.getPlayerIndex(data: data)
            gameClientDelegate?.playerColorIndex(index: playerIndex)
            print("indexToPlay in service", playerIndex)
        case .PositionStateHostMessage:
            let positionArray = messageService.getSelectedPositionData(data: data)
            gameClientDelegate?.hostPositionStateChanged(stateArray: positionArray)
        case .PositionStateClientMessage:
            let positionArray = messageService.getSelectedPositionData(data: data)
            gameHostDelegate?.clientPlayerPositionChanged(stateArray: positionArray)
        }
        
        sessionDelegate?.recievedData(data: message, fromPeerID: peerID)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
}

//MARK:- MCNearbyServiceBrowser Delegate Methods
extension GameService: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if let index = foundPeers.map({return $0.displayName}).firstIndex(of: peerID.displayName) {
            foundPeers[index] = peerID
        } else {
            foundPeers.append(peerID)
        }
        print(foundPeers)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        removePeer(id: peerID)
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print(error.localizedDescription)
    }
}

//MARK:- MCNearbyServiceAdvertiser Delegate Methods
extension GameService: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        advertiserDelegate?.invitationWasReceived(fromPeer: peerID.displayName, handler: invitationHandler, session: self.session)
    }
}
