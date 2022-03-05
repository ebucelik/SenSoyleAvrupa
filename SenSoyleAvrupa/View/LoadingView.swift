//
//  LoadingView.swift
//  FuFi
//
//  Created by ilyas abiyev on 23.01.21.
//

import UIKit
import NVActivityIndicatorView

class LoadingView: UIView {
  
    lazy var blurEffect = UIBlurEffect(style: .light)
    lazy var effectView = UIVisualEffectView(effect: blurEffect)
    
    let activityIndicator : NVActivityIndicatorView = {
        let view = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30), type: .ballClipRotatePulse, color: .customTintColor(), padding: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.startAnimating()
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    
        backgroundColor = .clear
        
        addSubview(effectView)
        
        effectView.addToSuperViewAnchors()

        addSubview(activityIndicator)
        
        activityIndicator.centerViewAtSuperView()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

