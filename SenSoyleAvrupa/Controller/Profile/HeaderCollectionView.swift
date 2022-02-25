//
//  HeaderCollectionView.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 16.04.21.
//

import UIKit
import Alamofire
import SDWebImage

class HeaderCollectionView: UICollectionReusableView {
    static let identifer = "HeaderCollectionView"
    
    let topView : UIView = {
        let view = UIView()
        view.backgroundColor = .customBackground()
        view.layer.cornerRadius = 15
        return view
    }()
    
    let imgProfile : UIImageView = {
        let img = UIImageView(image: UIImage(named: "emojiman"))
        img.backgroundColor = .white
        img.heightAnchor.constraint(equalToConstant: 100).isActive = true
        img.widthAnchor.constraint(equalToConstant: 100).isActive = true
        img.layer.cornerRadius = 50
        img.clipsToBounds = true
        img.layer.borderWidth = 2
        img.layer.borderColor = UIColor.customTintColor().cgColor
        return img
    }()
    
    let lblName : UILabel = {
        let lbl = UILabel()
        lbl.text = ""
        lbl.textColor = .customLabelColor()
        lbl.textAlignment = .left
        lbl.font = .systemFont(ofSize: 19, weight: .heavy)
        return lbl
    }()
    
    let lblMail : UILabel = {
        let lbl = UILabel()
        lbl.text = "..."
        lbl.textColor = .lightGray
        lbl.textAlignment = .left
        lbl.font = .systemFont(ofSize: 15)
        return lbl
    }()
    
    let btnEditProfile : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Profili Düzenle", for: .normal)
        btn.backgroundColor = .customTintColor()
        btn.titleLabel?.tintColor = .white
        btn.layer.cornerRadius = 5
        btn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return btn
    }()
    
    let lblVideoView : UIView = {
        let view  = UIView()
        view.layer.cornerRadius = 5
       
        view.backgroundColor = .customBackground()
        return view
    }()
    
    let lblCoinView : UIView = {
        let view  = UIView()
        view.layer.cornerRadius = 5
      
        view.backgroundColor = .customBackground()
        return view
    }()
    
    let lblPuanView : UIView = {
        let view  = UIView()
        view.layer.cornerRadius = 5
        view.backgroundColor = .customBackground()
        return view
    }()
    
    let lblVideoCount : UILabel = {
        let lbl = UILabel()
        lbl.text = "..."
        lbl.textColor = .customLabelColor()
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 20, weight: .heavy)
        return lbl
    }()
    
    let lblCoinCount : UILabel = {
        let lbl = UILabel()
        lbl.text = "..."
        lbl.textColor = .customLabelColor()
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 20, weight: .heavy)
        return lbl
    }()
    
    
    let lblPuahCount : UILabel = {
        let lbl = UILabel()
        lbl.text = "..."
        lbl.textColor = .customLabelColor()
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 20, weight: .heavy)
        return lbl
    }()
    
    let lblVideo : UILabel = {
        let lbl = UILabel()
        lbl.text = "Video"
        lbl.textColor = .lightGray
        lbl.textAlignment = .center
        lbl.font = .boldSystemFont(ofSize: 15)
        return lbl
    }()
    
    let lblCoin : UILabel = {
        let lbl = UILabel()
        lbl.text = "Coin"
        lbl.textColor = .lightGray
        lbl.textAlignment = .center
        lbl.font = .boldSystemFont(ofSize: 15)
        return lbl
    }()
    
    let lblPuan : UILabel = {
        let lbl = UILabel()
        lbl.text = "Puan"
        lbl.textColor = .lightGray
        lbl.textAlignment = .center
        lbl.font = .boldSystemFont(ofSize: 15)
        return lbl
    }()
    
   
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
      
        
        backgroundColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [lblName,lblMail,btnEditProfile])
        stackView.axis = .vertical
        stackView.spacing = 10
        
        let stackViewTop = UIStackView(arrangedSubviews: [lblCoinView,lblCoin])
        stackViewTop.axis = .vertical
        stackViewTop.spacing = 5
       
        let stackViewBottom = UIStackView(arrangedSubviews: [lblVideoView,lblVideo])
        stackViewBottom.axis = .vertical
        stackViewBottom.spacing = 5
        
        let stackViewCenter = UIStackView(arrangedSubviews: [lblPuanView,lblPuan])
        stackViewCenter.axis = .vertical
        stackViewCenter.spacing = 5
        
        let stackViewAll = UIStackView(arrangedSubviews: [stackViewBottom,stackViewCenter,stackViewTop])
        stackViewAll.axis = .horizontal
        stackViewAll.spacing = 10
        stackViewAll.distribution = .fillEqually
        
        let stackViewAllView = UIStackView(arrangedSubviews: [topView,stackViewAll])
        stackViewAllView.axis = .vertical
        stackViewAllView.spacing = 10
        
        
       addSubview(stackViewAllView)
        
        topView.addSubview(imgProfile)
        
        topView.addSubview(stackView)
      
        stackViewAllView.anchor(top: nil, bottom: nil, leading: leadingAnchor, trailing: trailingAnchor,padding: .init(top: 0, left: 20, bottom: 0, right: 20))

        stackViewAllView.centerViewAtSuperView()
        imgProfile.anchor(top: topView.topAnchor, bottom: topView.bottomAnchor, leading: topView.leadingAnchor, trailing: nil,padding: .init(top: 10, left: 10, bottom: 10, right: 0))
        
        stackView.anchor(top: imgProfile.topAnchor, bottom: topView.bottomAnchor, leading: imgProfile.trailingAnchor, trailing: topView.trailingAnchor,padding: .init(top: 0, left: 10, bottom: 15, right: 10))
        
       

        lblCoinView.addSubview(lblCoinCount)
        lblVideoView.addSubview(lblVideoCount)
        lblPuanView.addSubview(lblPuahCount)
        lblCoinCount.addToSuperViewAnchors(padding: .init(top: 5, left: 5, bottom: 5, right: 5))
        lblVideoCount.addToSuperViewAnchors(padding: .init(top: 5, left: 5, bottom: 5, right: 5))
        lblPuahCount.addToSuperViewAnchors(padding: .init(top: 5, left: 5, bottom: 5, right: 5))
    }
}
