//
//  UIView+Extension.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 22.04.22.
//

import UIKit

extension UIView {
    func showError() {
        let emptyView = EmptyView()

        if subviews.filter({ $0.isKind(of: EmptyView.self) }).isEmpty {
            addSubview(emptyView)

            emptyView.addToSuperViewAnchors()
        }
    }

    func showLoading() {
        let loadingView = LoadingView()
        loadingView.isHidden = false

        if subviews.filter({ $0.isKind(of: LoadingView.self )} ).isEmpty {
            addSubview(loadingView)

            loadingView.addToSuperViewAnchors()
        } else {
            if let loadingView = subviews.first(where: { $0.isKind(of: LoadingView.self)} ) {
                loadingView.isHidden = false
            }
        }
    }

    func hideLoading() {
        if let loadingView = subviews.first(where: { $0.isKind(of: LoadingView.self)} ) {
            if let lastElement = subviews.last?.isKind(of: LoadingView.self), !lastElement {
                bringSubviewToFront(loadingView)
            }

            loadingView.isHidden = true
        }
    }
}
