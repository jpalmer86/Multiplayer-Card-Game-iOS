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
            joinGameButton.layer.shadowColor = Constants.shadowColor
            joinGameButton.layer.shadowOffset = Constants.shadowOffset
            joinGameButton.layer.shadowRadius = Constants.shadowRadius
            joinGameButton.layer.shadowOpacity = Constants.shadowOpacity
        }
    }
    @IBOutlet var startgameButton: UIButton! {
        didSet {
            startgameButton.layer.cornerRadius = 10
            startgameButton.layer.shadowColor = Constants.shadowColor
            startgameButton.layer.shadowOffset = Constants.shadowOffset
            startgameButton.layer.shadowRadius = Constants.shadowRadius
            startgameButton.layer.shadowOpacity = Constants.shadowOpacity
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
        AppUtility.setBackNavigationBarItem(navigationItem: navigationItem)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        AppUtility.lockOrientation(.all)
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == joinSegueIdentifier {
            if let joinVC = segue.destination as? JoinGameViewController {
                joinVC.game = game
            }
        } else if segue.identifier == startGameSegureIdentifier {
            if let tabBarVC = segue.destination as? UITabBarController, let gameVC = tabBarVC.viewControllers?.first {
                if let gameVC = gameVC as? GameViewController {
                    gameVC.game = game
                    gameVC.isHost = true
                }
            }
        }
    }
    
    //MARK:- ViewController Methods
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
      }
}
