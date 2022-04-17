//
//  UIViewController+Extension.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 26.02.22.
//

import UIKit
import TTGSnackbar

import SwiftHelper

extension UIViewController {
    func checkInternetConnection(completion: (() -> Void)?) {
        if !CheckInternet.Connection() {
            let vc = NoInternetController(completion: completion)
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        }
    }

    func showSnackBar(message: String) {
        let snackBar = TTGSnackbar(message: message, duration: .middle)
        snackBar.backgroundColor = .customTintColor()
        snackBar.messageTextColor = .white
        snackBar.show()
    }

    @objc func dismissViewController() {
        navigationController?.popViewController(animated: true)
    }
}
