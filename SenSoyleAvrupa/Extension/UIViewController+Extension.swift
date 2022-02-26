//
//  UIViewController+Extension.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 26.02.22.
//

import UIKit

extension UIViewController {
    func checkInternetConnection() {
        if !CheckInternet.Connection() {
            let vc = NoInternetController()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        }
    }
}
