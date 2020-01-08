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
    func foundPeer(peers: [MCPeerID])
    func lostPeer(peerID: MCPeerID)
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

protocol GameServiceGameDelegate {
    func boutWinner(playerName: String)
    func winner(playerName: String)
    func gaveCardToPlayer(card: Card, playerName: String)
    func playerTurnedCard(playerName: String, card: Card)
    func remainingTime(time: Int)
}

//MARK:- Service Class
class GameService: NSObject {
    // MARK:- Property Variables
    static var shared = GameService()
    var browserDelegate: GameServiceBrowserDelegate?
    var advertiserDelegate: GameServiceAdvertiserDelegate?
    var sessionDelegate: GameServiceSessionDelegate?
    var gameDelegate: GameServiceGameDelegate?
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
    private var foundPeers = [MCPeerID]()
        
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
        advertiser.startAdvertisingPeer()
    }
    
    func joinSession() {
        browser.startBrowsingForPeers()
    }
    
    func invitePeer(peerID: MCPeerID) {
         browser.invitePeer(peerID, to: session, withContext: nil, timeout: 20)
    }
    
    func stopBrowsingForPeers() {
        browser.stopBrowsingForPeers()
    }
    
    func stopAdvertisingToPeers() {
        advertiser.stopAdvertisingPeer()
    }
    
    func disconnectSession() {
        session.disconnect()
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
}

//MARK:- MCSession Delegate Methods
extension GameService: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
          print("Connected: \(peerID.displayName)")
          sessionDelegate?.connectedWithPeer(peerID: peerID)
        case .connecting:
          print("Connecting: \(peerID.displayName)")
        case .notConnected:
          print("Not Connected: \(peerID.displayName)")
          sessionDelegate?.connectionFailed(peerID: peerID)
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
            gameDelegate?.boutWinner(playerName: winnerName)
        case .GameStateMessage:
            let state = messageService.gameStateData(data: data)
            sessionDelegate?.stateChanged(newState: state)
        case .GameWinnerMessage:
            let gameWinnerName = messageService.winnerData(data: data)
            gameDelegate?.winner(playerName: gameWinnerName)
        case .GiveCardToPlayerMessage:
            let dict = messageService.cardExchangeData(data: data)
            let playerName = dict.keys.first!
            gameDelegate?.gaveCardToPlayer(card: dict[playerName]!, playerName: playerName)
        case .PlayerTurnCardMessage:
            let dict = messageService.cardExchangeData(data: data)
            let playerName = dict.keys.first!
            gameDelegate?.playerTurnedCard(playerName: playerName, card: dict[playerName]!)
        case .RemainingTime:
            let time = messageService.timeData(data: data)
            gameDelegate?.remainingTime(time: time)
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
        browserDelegate?.foundPeer(peers: foundPeers)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        for (index, aPeer) in foundPeers.enumerated() {
            if aPeer == peerID {
                foundPeers.remove(at: index)
                break
            }
        }

        browserDelegate?.lostPeer(peerID: peerID)
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
