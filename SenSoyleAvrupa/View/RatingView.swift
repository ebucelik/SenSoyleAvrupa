//
//  RatingView.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 18.04.21.
//

import UIKit
import Cosmos

class RatingView : UIView {
    
    
    let allView : UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        return view
    }()
    
    let centerView : UIView = {
       let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        return view
    }()
    
    let btnLeft : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.tintColor = .customTintColor()
        btn.heightAnchor.constraint(equalToConstant: 36).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 36).isActive = true
        btn.layer.cornerRadius = 18
        btn.backgroundColor = .customBackgorundButton()
        return btn
    }()
    
    let ratingView : CosmosView = {
        let cosmosView = CosmosView()
        cosmosView.settings.fillMode = .full
        cosmosView.settings.starSize = 30
        cosmosView.settings.starMargin = 5
        cosmosView.settings.filledColor = UIColor.orange
        cosmosView.settings.emptyBorderColor = UIColor.orange
        cosmosView.settings.filledBorderColor = UIColor.orange
        cosmosView.settings.filledImage = UIImage(named: "GoldStarFilled")
        cosmosView.settings.emptyImage = UIImage(named: "GoldStarEmpty")
        cosmosView.rating = 0
        return cosmosView
    }()
    
    let lblTop : UILabel = {
        let lbl = UILabel()
        lbl.text = "0"
        lbl.textColor = .customLabelColor()
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 30, weight: .heavy)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    let btnSend : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Send", for: .normal)
        btn.backgroundColor = .customTintColor()
        btn.titleLabel?.tintColor = .white
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .heavy)
        btn.layer.cornerRadius = 15
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //backgroundColor = .clear
        
        addSubview(allView)
        
        allView.addSubview(centerView)
        
        centerView.addSubview(btnLeft)
        
        centerView.addSubview(lblTop)
        
        centerView.addSubview(ratingView)
        
        centerView.addSubview(btnSend)
        
        
        
        allView.doldurSuperView()
        
        centerView.anchor(top: nil, bottom: nil, leading: allView.leadingAnchor, trailing: allView.trailingAnchor,padding: .init(top: 0, left: 20, bottom: 0, right: 20))
        centerView.merkezKonumlamdirmaSuperView()
        
        btnLeft.anchor(top: centerView.topAnchor, bottom: nil, leading: centerView.leadingAnchor, trailing: nil,padding: .init(top: 20, left: 20, bottom: 0, right: 0))
        
        lblTop.anchor(top: btnLeft.bottomAnchor, bottom: nil, leading: centerView.leadingAnchor, trailing: centerView.trailingAnchor,padding: .init(top: 5, left: 20, bottom: 0, right: 20))
        
        ratingView.anchor(top: lblTop.bottomAnchor, bottom: nil, leading: nil, trailing: nil,padding: .init(top: 15, left: 0, bottom: 0, right: 0))
        ratingView.merkezXSuperView()
        
        btnSend.anchor(top: ratingView.bottomAnchor, bottom: centerView.bottomAnchor, leading: centerView.leadingAnchor, trailing: centerView.trailingAnchor,padding: .init(top: 15, left: 20, bottom: 20, right: 20))
        
       
      
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


