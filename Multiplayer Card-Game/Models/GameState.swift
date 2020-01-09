//
//  GameState.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 03/01/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import Foundation

enum GameState: String {
    case waitingForPlayers
    case dealing
    case playing
    case decidingRoundWinner
    case gameOver
    
    static let allStates = [GameState.waitingForPlayers, .dealing, .playing, .decidingRoundWinner, .gameOver]
    
    static func gameState(state: String) -> GameState {
        let gameStatesArray = allStates.map({ $0.rawValue })
        return allStates[gameStatesArray.firstIndex(of: state)!]
    }
}
