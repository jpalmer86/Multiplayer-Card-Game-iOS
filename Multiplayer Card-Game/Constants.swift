//
//  Constants.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 27/12/19.
//  Copyright © 2019 Hot Cocoa Software. All rights reserved.
//

import UIKit

var gameService = GameService.shared

struct Constants {
    //MARK:- Games
    static private let CRAZY8S = Game(name: "Crazy 8's",
                                      serviceType: "crazy8-service",
                                      image: UIImage(imageLiteralResourceName: "c8i"),
                                      playerDescription: "2-5 Players",
                                      gameDescription: "A game where the first person to get rid of all their cards win!")
    
    //MARK:- Other Constants
    static let distributeDirection = [CGPoint(x: 0.0, y: 1.0),CGPoint(x: 1.0, y: 0.0),CGPoint(x: 0.0, y: -1.0),CGPoint(x: -1.0, y: 0.0)]
    static let translateDistance = [CGPoint(x: 0.0, y: 16.0),CGPoint(x: 128.0, y: 0.0),CGPoint(x: 0.0, y: -16.0),CGPoint(x: -128.0, y: 0.0)]
    
    static let gameTime = [3 * 60]
    static let minimumPlayersNeeded = [2]
    
    static let shadowColor = UIColor.black.cgColor
    static let shadowOffset = CGSize(width: 2, height: 2)
    static let shadowRadius: CGFloat = 3
    static let shadowOpacity: Float = 0.5
    
    static let gameCardRadius: CGFloat = 42
    
    //MARK:- Method to get information of all games 
    static func getAllGamesInfo() -> [Game] {
        var games = [Game]()
        games.append(CRAZY8S)
        return games
    }
}
