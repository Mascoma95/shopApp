//
//  FirebaseController.swift
//  FirebaseLogin
//
//  Created by Giuseppe Sapienza on 05/07/16.
//  Copyright © 2016 Giuseppe Sapienza. All rights reserved.
//

import UIKit

struct ErrorMessageView {
    
    static func createAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction.init(title: "Close", style: UIAlertAction.Style.cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        return alert
    }
}
