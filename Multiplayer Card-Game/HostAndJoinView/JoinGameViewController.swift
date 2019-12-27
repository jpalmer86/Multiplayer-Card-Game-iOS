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
    @IBOutlet var playerNameTextField: UITextField! {
        didSet {
            playerNameTextField.text = gameService.getPeerID().displayName
        }
    }
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
    let gameService = GameService.shared
    var availableDevices = [MCPeerID]() {
        didSet {
            lobbiesTableView.reloadData()
        }
    }
    
    //MARK:- Lifecycle Hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            if let tabBarVC = segue.destination as? UITabBarController, let gameVC = tabBarVC.viewControllers?.first {
                if let cell = sender as? UITableViewCell {
                    //set your game values
                }
            }
        }
    }
}

//MARK:- UITableView Delegate Methods
extension JoinGameViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: segueIdentifier, sender: tableView.cellForRow(at: indexPath))
    }
}

//MARK:- UITableView Datasource Delegate
extension JoinGameViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "GameTableViewCell") {
            cell.textLabel?.text = availableDevices[indexPath.item].displayName
            return cell
        }
        return GameTableViewCell()

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
