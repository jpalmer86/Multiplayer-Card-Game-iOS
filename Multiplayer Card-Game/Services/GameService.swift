//
//  GameService.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 27/12/19.
//  Copyright © 2019 Hot Cocoa Software. All rights reserved.
//

import MultipeerConnectivity

//MARK:- Protocols
protocol GameServiceBrowserDelegate {
    func foundPeer(peers: [MCPeerID])
    func lostPeer(peerID: MCPeerID)
}

protocol GameServiceAdvertiserDelegate {
    func invitationWasReceived(fromPeer: String, completion: @escaping (Bool)->Void)
}

protocol GameServiceSessionDelegate {
    func connectedWithPeer(peerID: MCPeerID)
    func recievedData(data: Data, fromPeerID: MCPeerID)
}

class GameService: NSObject {
    
    //MARK:- IBOutlets
    var chatView: UITextView!
    var inputMessage: UITextField!
    
    // MARK:- Member Variables
    static var shared = GameService()
    var browserDelegate: GameServiceBrowserDelegate?
    var advertiserDelegate: GameServiceAdvertiserDelegate?
    var sessionDelegate: GameServiceSessionDelegate?

    var peerID: MCPeerID!
    var mcSession: MCSession!
    var advertiser: MCNearbyServiceAdvertiser!
    var browser: MCNearbyServiceBrowser!
    var messageToSend: String!
    private var serviceType = ""
    var foundPeers = [MCPeerID]()
    var invitationHandler: ((Bool, MCSession?)->Void)!
    
    //MARK:- Constructor
    private override init() {}
    
    //MARK:- Methods
    func setServiceType(serviceType: String) {
        self.serviceType = serviceType
    }
    
    func setUpService() {
        if serviceType != "" {
            peerID = MCPeerID(displayName: UIDevice.current.name)
            mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
            advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
            browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
            advertiser.delegate = self
            browser.delegate = self
            mcSession.delegate = self
            //        advertiser.startAdvertisingPeer()
            //        browser.startBrowsingForPeers()
        }
    }

    func send() {
        messageToSend = "\(peerID.displayName): \(inputMessage.text!)\n"
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
    
    func getPeerID() -> MCPeerID {
        return peerID
    }
    
    func invitePeer(peerID: MCPeerID) {
         browser.invitePeer(peerID, to: mcSession, withContext: nil, timeout: 20)
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
//        browser.invitePeer(peerID, to: mcSession, withContext: nil, timeout: 20)
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
        advertiserDelegate?.invitationWasReceived(fromPeer: peerID.displayName, completion: { invitationResponse in
            invitationHandler(true, self.mcSession)
        })
    }
}
