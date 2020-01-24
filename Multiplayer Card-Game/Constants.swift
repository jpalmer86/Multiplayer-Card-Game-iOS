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
            Crazy8.green.rawValue: UIColor(red: 0 / 255.0, green: 127 / 255.0, blue: 120 / 255.0, alpha: 1),
            Crazy8.blue.rawValue: UIColor(red: 0 / 255.0, green: 73 / 255.0, blue: 132 / 255.0, alpha: 1),
            Crazy8.pink.rawValue: UIColor(red: 149 / 255.0, green: 0 / 255.0, blue: 83 / 255.0, alpha: 1),
            Crazy8.yellow.rawValue: UIColor(red: 248 / 255.0, green: 171 / 255.0, blue: 0 / 255.0, alpha: 1),
            Crazy8.red.rawValue: UIColor(red: 248 / 255.0, green: 60 / 255.0, blue: 70 / 255.0, alpha: 1),
            Crazy8.lightGrey.rawValue: UIColor(red: 214 / 255.0, green: 213 / 255.0, blue: 213 / 255.0, alpha: 1),
            Crazy8.darkGrey.rawValue: UIColor(red: 94 / 255.0, green: 94 / 255.0, blue: 94 / 255.0, alpha: 1)
        ]
        
        static func allColors() -> [UIColor] {
            let allColors = [color[Crazy8.green.rawValue]!, color[Crazy8.blue.rawValue]!, color[Crazy8.pink.rawValue]!, color[Crazy8.yellow.rawValue]!, color[Crazy8.red.rawValue]!, color[Crazy8.lightGrey.rawValue]!, color[Crazy8.darkGrey.rawValue]!]
            return allColors
        }

    }
    
    //MARK:- Other Constants
    
    static let distributeDirection = [CGPoint(x: 0.0, y: 1.0),CGPoint(x: 1.0, y: 0.0),CGPoint(x: 0.0, y: -1.0),CGPoint(x: -1.0, y: 0.0)]
    static let translateDistance = [CGPoint(x: 0.0, y: 48.0),CGPoint(x: 48.0, y: 0.0),CGPoint(x: 0.0, y: 48.0),CGPoint(x: 48.0, y: 0.0)]
    
    static let animateDistance: CGFloat = 64
    
    static let buttonCornerRadius: CGFloat = 10
    static let borderWidth: CGFloat = 2
        
    static let shadowColor = UIColor.black
    static let shadowOffset = CGSize(width: 2, height: 2)
    static let shadowOffsetCard = CGSize(width: -3, height: 0)
    static let shadowRadius: CGFloat = 3
    static let shadowOpacity: Float = 0.5
    
    static let gameCardRadius: CGFloat = 60
    static let noplayer = "noPlayer"
    
    //MARK:- Method to get information of all games
    
    static func getAllGamesInfo() -> [Game] {
        let games = [CRAZY8S]
        return games
    }
}
