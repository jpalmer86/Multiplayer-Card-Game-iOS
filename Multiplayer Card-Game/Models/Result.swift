//
//  Result.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 02/01/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import Foundation

enum Result<Response,Error> {
    case success(Response)
    case failure(Error)
}
