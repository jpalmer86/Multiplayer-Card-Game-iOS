//
//  GameService.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 27/12/19.
//  Copyright © 2019 Hot Cocoa Software. All rights reserved.
//
// Service type for mcpeerconnectivity valid characters include ASCII lowercase letters, numbers, and the hyphen(single)

import Foundation
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
    func recievedData(data: Data, fromPeerID: MCPeerID)
}

//MARK:- Service Class
class GameService: NSObject {
    
    //MARK:- IBOutlets
    var chatView: UITextView!
    var inputMessage: UITextField!
    
    // MARK:- Member Variables
    static var shared = GameService()
    var browserDelegate: GameServiceBrowserDelegate? {
        didSet {
            print("Game Service browser delegate: ", browserDelegate)
        }
    }
    var advertiserDelegate: GameServiceAdvertiserDelegate? {
        didSet {
            print("Game Service advertiser delegate: ", advertiserDelegate)
        }
    }
    var sessionDelegate: GameServiceSessionDelegate? {
        didSet {
            print("Game Service session delegate: ", sessionDelegate)
        }
    }

    private var myPeerID: MCPeerID! = MCPeerID(displayName: UIDevice.current.name)
    private lazy var mcSession : MCSession = {
        let session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser: MCNearbyServiceBrowser!
    var messageToSend: String!
    private var serviceType = ""
    private var foundPeers = [MCPeerID]()
    
    //MARK:- Constructor
    private override init() {
        super.init()
         myPeerID = MCPeerID(displayName: UIDevice.current.name)
    }
    
    //MARK:- Methods
    func setServiceType(serviceType: String) {
        self.serviceType = serviceType
        setUpService()
    }

    func getPeerID() -> MCPeerID {
        return myPeerID
    }

    func send() {
        messageToSend = "\(myPeerID.displayName): \(inputMessage.text!)\n"
        let message = messageToSend.data(using: .utf8)
        if mcSession.connectedPeers.count > 0 {
            do {
                try self.mcSession.send(message!, toPeers: self.mcSession.connectedPeers, with: .reliable)
                chatView.text = chatView.text + messageToSend
                inputMessage.text = ""
            }
            catch {
                print("Error sending message: ",error.localizedDescription)
            }
        }
    }

    func hostSession() {
        advertiser.startAdvertisingPeer()
    }
    
    func joinSession() {
        browser.startBrowsingForPeers()
    }
    
    func stopBrowsingForPeers() {
        browser.stopBrowsingForPeers()
    }
    
    func stopAdvertisingToPeers() {
        advertiser.stopAdvertisingPeer()
    }
    
    func invitePeer(peerID: MCPeerID) {
         browser.invitePeer(peerID, to: mcSession, withContext: nil, timeout: 20)
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
        DispatchQueue.main.async { [unowned self] in
            let message = String(data: data, encoding: .utf8)!
            self.chatView.text = self.chatView.text + message
        }
        sessionDelegate?.recievedData(data: data, fromPeerID: peerID)
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
        foundPeers.append(peerID)
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
//        invitationHandler(true, self.mcSession)
        advertiserDelegate?.invitationWasReceived(fromPeer: peerID.displayName, handler: invitationHandler, session: self.mcSession)
    }
}
