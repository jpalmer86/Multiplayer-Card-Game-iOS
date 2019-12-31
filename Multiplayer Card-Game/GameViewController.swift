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
    //MARK:- Property variables
    var game: Game! {
        didSet {
            gameService.advertiserDelegate = self
            gameService.sessionDelegate = self
        }
    }
    var isHost = false
    private var connectingAlert: UIAlertController?

    //MARK:- Lifecycle Hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        gameService.hostSession()
        if !isHost {
            connectingAlert = loadingAlert(title: "Connecting ...")
            present(connectingAlert!, animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        gameService.stopAdvertisingToPeers()
        super.viewWillDisappear(animated)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK:- GameService Session Delegate Methods
extension GameViewController: GameServiceSessionDelegate {
    func connectedWithPeer(peerID: MCPeerID) {
        print("Connected with peer: ", peerID.displayName)
        showOnlyAlert(title: "Connected", message: "Successfully connected with \(peerID.displayName)")
        DispatchQueue.main.async {
            self.connectingAlert?.dismiss(animated: true, completion: nil)
        }
    }
    
    func connectionFailed(peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.connectingAlert?.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func recievedData(data: Data, fromPeerID: MCPeerID) {
        // 
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
