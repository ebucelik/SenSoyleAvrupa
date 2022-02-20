//
//  PurchaseCell.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 17.04.21.
//

import UIKit

class PurchaseCell: UICollectionViewCell {

    
    let imgCoin : UIImageView = {
        let img = UIImageView(image: UIImage(named: "coin"))
        img.heightAnchor.constraint(equalToConstant: 50).isActive = true
        img.widthAnchor.constraint(equalToConstant: 50).isActive = true
        return img
    }()
    
    let lblCoin : UILabel = {
        let lbl = UILabel()
        lbl.text = ""
        lbl.numberOfLines = 0
        lbl.textColor = .customLabelColor()
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 30, weight: .heavy)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    let lblPrice : UILabel = {
        let lbl = UILabel()
        lbl.text = ""
        lbl.textColor = .lightGray
        lbl.textAlignment = .right
        lbl.font = .systemFont(ofSize: 17)
        lbl.numberOfLines = 0
        return lbl
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let stackView = UIStackView(arrangedSubviews: [imgCoin,lblCoin,lblPrice])
        stackView.axis = .horizontal
        stackView.spacing = 10
        
        addSubview(stackView)
        
        stackView.anchor(top: nil, bottom: nil, leading: leadingAnchor, trailing: trailingAnchor,padding: .init(top: 0, left: 20, bottom: 0, right: 20))
        stackView.centerViewAtSuperView()
        
//        addSubview(imgCoin)
//
//        imgCoin.anchor(top: nil, bottom: nil, leading: leadingAnchor, trailing: nil,padding: .init(top: 0, left: 20, bottom: 0, right: 0))
//        imgCoin.merkezYSuperView()
        
        backgroundColor =  .customBackgorundButton()
        layer.masksToBounds = false
        layer.cornerRadius = 20
    }

}
