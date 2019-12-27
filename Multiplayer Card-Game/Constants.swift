//
//  Constants.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 27/12/19.
//  Copyright © 2019 Hot Cocoa Software. All rights reserved.
//

import UIKit

struct Constants {
    //MARK:- Games
    static private let CRAZY8S = Game(name: "Crazy 8's",
                                      image: UIImage(imageLiteralResourceName: "crazy_eights_image"),
                                      playerDescription: "2-5 Players",
                                      gameDescription: "A game where the first person to get rid of all their cards win!")
    
    //MARK:- Method to get information of all games 
    static func getAllGamesInfo() -> [Game] {
        var games = [Game]()
        games.append(CRAZY8S)
        return games
    }
}
