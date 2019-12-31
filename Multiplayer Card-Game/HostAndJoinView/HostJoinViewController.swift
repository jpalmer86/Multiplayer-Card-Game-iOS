//
//  HostJoinViewController.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 27/12/19.
//  Copyright © 2019 Hot Cocoa Software. All rights reserved.
//

import UIKit

class HostJoinViewController: UIViewController {
    //MARK:- IBOutlets
    @IBOutlet var joinGameButton: UIButton! {
        didSet {
            joinGameButton.layer.cornerRadius = 10
        }
    }
    @IBOutlet var startgameButton: UIButton! {
        didSet {
            startgameButton.layer.cornerRadius = 10
        }
    }
    
    //MARK:- Property variables
    var game: Game!
    let joinSegueIdentifier = "Active Game segue"
    let startGameSegureIdentifier = "Start Game segue"
    
    //MARK:- Lifecycle Hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Play"
        gameService.setServiceType(serviceType: game.serviceType)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == joinSegueIdentifier {
            if let joinVC = segue.destination as? JoinGameViewController {
                joinVC.game = game
            }
        } else if segue.identifier == startGameSegureIdentifier {
            if let tabBarVC = segue.destination as? UITabBarController, let gameVC = tabBarVC.viewControllers?.first {
                print("Game view controller: ", gameVC)
                if let gameVC = gameVC as? GameViewController {
                    gameVC.game = game
                    gameVC.isHost = true
                }
            }
        }
    }
}
