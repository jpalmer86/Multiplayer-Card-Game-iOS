//
//  Player.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 12/01/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct Player {
    var playerName: String
    var peerID: MCPeerID
    
    init(playerID: MCPeerID) {
        peerID = playerID
        playerName = playerID.displayName
    }
}
