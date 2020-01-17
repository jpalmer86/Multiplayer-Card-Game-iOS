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
        
        enum Crazy8: String {
            case green = "Crazy 8 Green"
            case blue = "Crazy 8 Blue"
            case pink = "Crazy 8 Pink"
            case yellow = "Crazy 8 Yellow"
            case red = "Crazy 8 Red"
            case lightGrey = "Crazy 8 LightGrey"
            case darkGrey = "Crazy 8 DarkGrey"

        }
        
        static let color: [String: UIColor] = [
            Crazy8.green.rawValue: UIColor(red: 0, green: 127, blue: 120, alpha: 1),
            Crazy8.blue.rawValue: UIColor(red: 0, green: 73, blue: 132, alpha: 1),
            Crazy8.pink.rawValue: UIColor(red: 149, green: 0, blue: 83, alpha: 1),
            Crazy8.yellow.rawValue: UIColor(red: 248, green: 171, blue: 0, alpha: 1),
            Crazy8.red.rawValue: UIColor(red: 248, green: 40, blue: 53, alpha: 1),
            Crazy8.lightGrey.rawValue: UIColor(red: 214, green: 213, blue: 213, alpha: 1),
            Crazy8.darkGrey.rawValue: UIColor(red: 94, green: 94, blue: 94, alpha: 1)
        ]

    }
    
    //MARK:- Other Constants
    
    static let distributeDirection = [CGPoint(x: 0.0, y: 1.0),CGPoint(x: 1.0, y: 0.0),CGPoint(x: 0.0, y: -1.0),CGPoint(x: -1.0, y: 0.0)]
    static let translateDistance = [CGPoint(x: 0.0, y: 32.0),CGPoint(x: 128.0, y: 0.0),CGPoint(x: 0.0, y: -32.0),CGPoint(x: -128.0, y: 0.0)]
    
    static let buttonCornerRadius: CGFloat = 10
    static let borderWidth: CGFloat = 2
        
    static let shadowColor = UIColor.black
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
