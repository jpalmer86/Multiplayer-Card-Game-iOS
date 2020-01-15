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
                                      gameDescription: "A game where the first person to get rid of all their cards win!",
                                      minPlayers: 1,
                                      gameTime: 3 * 60)
    
    //MARK:- Colors
    
    struct Colors {
        static let crazy8Green = UIColor(red: 0, green: 127, blue: 120, alpha: 1)
        static let crazy8Blue = UIColor(red: 0, green: 73, blue: 132, alpha: 1)
        static let crazy8Pink = UIColor(red: 149, green: 0, blue: 83, alpha: 1)
        static let crazy8Yellow = UIColor(red: 248, green: 171, blue: 0, alpha: 1)
        static let crazy8Red = UIColor(red: 248, green: 40, blue: 53, alpha: 1)
        static let crazy8Grey = UIColor(red: 214, green: 213, blue: 213, alpha: 1)
        
        static func getAllColors() -> [UIColor] {
            let allColors = [crazy8Green, crazy8Blue, crazy8Pink, crazy8Yellow, crazy8Red, crazy8Grey]
            return allColors
        }
    }
    
    //MARK:- Other Constants
    
    static let distributeDirection = [CGPoint(x: 0.0, y: 1.0),CGPoint(x: 1.0, y: 0.0),CGPoint(x: 0.0, y: -1.0),CGPoint(x: -1.0, y: 0.0)]
    static let translateDistance = [CGPoint(x: 0.0, y: 32.0),CGPoint(x: 128.0, y: 0.0),CGPoint(x: 0.0, y: -32.0),CGPoint(x: -128.0, y: 0.0)]
        
    static let shadowColor = UIColor.black.cgColor
    static let shadowOffset = CGSize(width: 2, height: 2)
    static let shadowRadius: CGFloat = 3
    static let shadowOpacity: Float = 0.5
    
    static let gameCardRadius: CGFloat = 42
    
    //MARK:- Method to get information of all games
    
    static func getAllGamesInfo() -> [Game] {
        let games = [CRAZY8S]
        return games
    }
}
