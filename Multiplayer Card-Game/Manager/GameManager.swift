//
//  GameManager.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 31/12/19.
//  Copyright © 2019 Hot Cocoa Software. All rights reserved.
//

import MultipeerConnectivity

class GameManager {
    //MARK:- Property variables
    static var shared = GameManager()
    var players = [MCPeerID]()
    //cards array for each player
    //deck of cards (val)
    //cards in centre stage
    
    
    //MARK:- Initializers
    private init() {}
    
    //MARK:- Member Methods
}
