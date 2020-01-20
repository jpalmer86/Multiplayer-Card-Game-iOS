//
//  JoinGameViewController.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 27/12/19.
//  Copyright © 2019 Hot Cocoa Software. All rights reserved.
//

import Foundation
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
            print(availableDevices)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.lobbiesTableView.reloadData()
            }
        }
    }
    
    //MARK:- Lifecycle Hooks
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameService.browserDelegate = self
        playerNameTextField.text = gameService.getPeerID().displayName
        AppUtility.setBackNavigationBarItem(navigationItem: navigationItem)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gameService.joinSession()
        
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AppUtility.lockOrientation(.all)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            if let pageVC = segue.destination as? GamePageViewController {
                if let cell = sender as? UITableViewCell {
                    pageVC.isHost = false
                    pageVC.game = game
                    if let indexPath = lobbiesTableView.indexPathForSelectedRow {
                        gameService.invitePeer(peerID: availableDevices[indexPath.item])
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
//        gameService.invitePeer(peerID: availableDevices[indexPath.item])
//        performSegue(withIdentifier: segueIdentifier, sender: tableView.cellForRow(at: indexPath))
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
    
    func updatedPeers(peers: [MCPeerID]) {
        availableDevices = peers
    }
}

//MARK:- UITextField Delegate Methods

extension JoinGameViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let playerName = textField.text {
            // set the player.playerName to this value
        }
    }
}
