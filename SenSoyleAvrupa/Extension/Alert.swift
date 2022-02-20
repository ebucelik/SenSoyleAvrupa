//
//  Alert.swift
//  Fiind
//
//  Created by İlyas Abiyev on 5/31/20.
//  Copyright © 2020 İlyas Abiyev. All rights reserved.
//

import UIKit

extension UIViewController {
    func makeAlert(tittle: String, message : String) {
            let alert = UIAlertController(title: tittle, message: message, preferredStyle: UIAlertController.Style.alert)
            let okButton =  UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
    }
}

