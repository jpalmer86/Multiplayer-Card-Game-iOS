//
//  GameState.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 03/01/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import Foundation

enum GameState {
    case waitingForPlayers
    case dealing
    case playing
    case decidingRoundWinner
    case gameOver
}
