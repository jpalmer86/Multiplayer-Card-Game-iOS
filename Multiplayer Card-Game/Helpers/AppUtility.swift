//
//  AppUtility.swift
//  Multiplayer Card-Game
//
//  Created by Tushar Gusain on 06/01/20.
//  Copyright © 2020 Hot Cocoa Software. All rights reserved.
//

import UIKit

struct AppUtility {

    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {

        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }

    //// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {

        self.lockOrientation(orientation)

        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
    
    static func setBackNavigationBarItem(navigationItem: UINavigationItem, action: Selector? = nil) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: nil, action: action)
    }

}
