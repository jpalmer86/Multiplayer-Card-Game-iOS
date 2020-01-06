//
//  JoinGameViewController.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 27/12/19.
//  Copyright © 2019 Hot Cocoa Software. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class JoinGameViewController: UIViewController {

    //MARK:- IBOutlets
    @IBOutlet var playerNameTextField: UITextField!
    @IBOutlet var lobbiesTableView: UITableView! {
        didSet {
            lobbiesTableView.delegate = self
            lobbiesTableView.dataSource = self
            lobbiesTableView.tableFooterView = UIView()
        }
    }
    
    //MARK:- Property Variables
    let segueIdentifier = "Join Existing Segue"
    var game: Game!
    var availableDevices = [MCPeerID]() {
        didSet {
            lobbiesTableView.reloadData()
        }
    }
    
    //MARK:- Lifecycle Hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        gameService.browserDelegate = self
        playerNameTextField.text = gameService.getPeerID().displayName
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "back", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gameService.joinSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        gameService.stopBrowsingForPeers()
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            if let tabBarVC = segue.destination as? UITabBarController, let gameVC = tabBarVC.viewControllers?.first {
                if let cell = sender as? UITableViewCell {
                    if let gameVC = gameVC as? GameViewController {
                        gameService.stopBrowsingForPeers()
                        gameVC.game = game
                    }
                }
            }
        }
    }
    
    //MARK:- ViewController Methods
    override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
      }
}

//MARK:- UITableView Delegate Methods
extension JoinGameViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        gameService.invitePeer(peerID: availableDevices[indexPath.item])
        performSegue(withIdentifier: segueIdentifier, sender: tableView.cellForRow(at: indexPath))
    }
}

//MARK:- UITableView Datasource Delegate
extension JoinGameViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AvailableLobbyCell") {
            cell.textLabel?.text = availableDevices[indexPath.item].displayName
            return cell
        }
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

//MARK:- GameService Browser Delegate Methods
extension JoinGameViewController: GameServiceBrowserDelegate {
    func foundPeer(peers: [MCPeerID]) {
        availableDevices = peers
    }
    
    func lostPeer(peerID: MCPeerID) {
        if let index = availableDevices.firstIndex(of: peerID) {
            availableDevices.remove(at: index)
        }
    }
}
