//
//  Multiplayer_Card_GameTests.swift
//  Multiplayer Card-GameTests
//
//  Created by Tushar Gusain on 27/12/19.
//  Copyright © 2019 Hot Cocoa Software. All rights reserved.
//

import XCTest
import MultipeerConnectivity
@testable import Multiplayer_Card_Game

class MockGameServiceBrowser: NSObject, GameServiceBrowserDelegate {
    var mockPeers = [MCPeerID]()
    func updatedPeers(peers: [MCPeerID]) {
        mockPeers = peers
    }
}

class Multiplayer_Card_GameTests: XCTestCase {
    
    var sut1: GameManager!
    var host: MCPeerID!
    var client1: MCPeerID!
    var serviceType: String!
    
    var sut2: GameService!
    var mockGameServiceBrowser: MockGameServiceBrowser!

    override func setUp() {
        super.setUp()
        serviceType = "Game"
        
        sut1 = GameManager.shared
        host = MCPeerID(displayName: "Host iphone")
        client1 = MCPeerID(displayName: "Client iphone 1")
        
        sut1.newGame(newGame: Constants.getAllGamesInfo()[0])
        sut1.setAsHost(host: true)
        
        sut2 = gameService
        sut2.setServiceType(serviceType: serviceType)
        mockGameServiceBrowser = MockGameServiceBrowser()
        sut2.browserDelegate = mockGameServiceBrowser
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        sut1 = nil
        host = nil
        client1 = nil
        serviceType = nil
        
        sut2 = nil
        mockGameServiceBrowser = nil
        super.tearDown()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func test_DistributedCards() {
        XCTAssertEqual(sut1.cardsForPlayer[0].count, 0, "CardsForPlayer Array not initialized")
        sut1.connectedPlayersHost(connectedPlayers: [host,client1])
        sut1.distributeCards { (result) in
            switch result {
            case .success(_, _):
                print("distributedCards + 1")
            case .failure(let error):
                print("Failed to get the card, Error: \(error.localizedDescription)")
            }
        }
        XCTAssertEqual(sut1.cardsForPlayer[0].count + sut1.cardsForPlayer[1].count, 26, "Didn't gave 13 cards each to both the players")
    }
    
    func test_FoundPeers() {
        XCTAssertEqual(mockGameServiceBrowser.mockPeers.count, 0, "There should not be any pears available before browsing")
        let serviceBrowser = MCNearbyServiceBrowser(peer: host, serviceType: serviceType)
        
        gameService.browser(serviceBrowser, foundPeer: client1, withDiscoveryInfo: nil)
        
        XCTAssertEqual(mockGameServiceBrowser.mockPeers.count, 1, "Didn't get the nearby client")
    }

}
