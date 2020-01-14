//
//  UIViewController+Alert.swift
//  Bluetooth Testing
//
//  Created by Tushar Gusain on 26/12/19.
//  Copyright © 2019 Hot Cocoa Software. All rights reserved.
//

import UIKit

//MARK:- UIViewController Extension

extension UIViewController
{
    func alert(title: String?, message: String?, completion: @escaping (Bool) -> Void)
    {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                completion(true)
            }))
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { _ in
                completion(false)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showOnlyAlert(title: String?, message: String?)
    {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func loadingAlert(title: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)

        let indicator = UIActivityIndicatorView(frame: alert.view.bounds)
        indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        alert.view.addSubview(indicator)
        indicator.isUserInteractionEnabled = false
        indicator.startAnimating()

        return alert
    }
}
