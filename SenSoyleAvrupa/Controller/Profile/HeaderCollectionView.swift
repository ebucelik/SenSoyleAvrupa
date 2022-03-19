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

    // MARK: Variables
    var userModel: UserModel? {
        didSet {
            guard let userModel = userModel else { return }

            if let pp = userModel.pp, pp != "\(NetworkManager.url)/public/pp" {
                imageViewProfilePicture.sd_setImage(with: URL(string: pp))
            }
            labelCoinCount.text = "\(userModel.coin ?? 0)"
            labelPointCount.text = "\(userModel.points ?? 0)"
            labelUsername.text = userModel.username
        }
    }

    // MARK: Views
    let imageViewProfilePicture: UIImageView = {
        let img = UIImageView(image: UIImage())
        img.backgroundColor = .white
        img.contentMode = .scaleAspectFill
        img.heightAnchor.constraint(equalToConstant: 100).isActive = true
        img.widthAnchor.constraint(equalToConstant: 100).isActive = true
        img.clipsToBounds = true
        img.layer.cornerRadius = 50
        return img
    }()
    
    let labelUsername: UILabel = {
        let lbl = UILabel()
        lbl.text = ""
        lbl.textColor = .customLabelColor()
        lbl.textAlignment = .left
        lbl.font = .systemFont(ofSize: 19, weight: .heavy)
        return lbl
    }()
    
    let labelEmail: UILabel = {
        let lbl = UILabel()
        lbl.text = "..."
        lbl.textColor = .lightGray
        lbl.textAlignment = .left
        lbl.font = .systemFont(ofSize: 15)
        return lbl
    }()
    
    let buttonEditProfile: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Profili Düzenle", for: .normal)
        btn.backgroundColor = .customTintColor()
        btn.titleLabel?.tintColor = .white
        btn.layer.cornerRadius = 5
        btn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return btn
    }()
    
    let viewVideoCount: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.backgroundColor = .customBackground()
        return view
    }()
    
    let viewCoinCount: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.backgroundColor = .customBackground()
        return view
    }()
    
    let viewPointCount: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.backgroundColor = .customBackground()
        return view
    }()
    
    let labelVideoCount: UILabel = {
        let lbl = UILabel()
        lbl.text = "..."
        lbl.textColor = .customLabelColor()
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 20, weight: .heavy)
        return lbl
    }()
    
    let labelCoinCount: UILabel = {
        let lbl = UILabel()
        lbl.text = "..."
        lbl.textColor = .customLabelColor()
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 20, weight: .heavy)
        return lbl
    }()

    let labelPointCount: UILabel = {
        let lbl = UILabel()
        lbl.text = "..."
        lbl.textColor = .customLabelColor()
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 20, weight: .heavy)
        return lbl
    }()
    
    let labelVideo: UILabel = {
        let lbl = UILabel()
        lbl.text = "Video"
        lbl.textColor = .lightGray
        lbl.textAlignment = .center
        lbl.font = .boldSystemFont(ofSize: 15)
        return lbl
    }()
    
    let labelCoin: UILabel = {
        let lbl = UILabel()
        lbl.text = "Coin"
        lbl.textColor = .lightGray
        lbl.textAlignment = .center
        lbl.font = .boldSystemFont(ofSize: 15)
        return lbl
    }()
    
    let labelPoint: UILabel = {
        let lbl = UILabel()
        lbl.text = "Puan"
        lbl.textColor = .lightGray
        lbl.textAlignment = .center
        lbl.font = .boldSystemFont(ofSize: 15)
        return lbl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        backgroundColor = .white

        let stackViewUserData = UIStackView(arrangedSubviews: [labelUsername, labelEmail, buttonEditProfile])
        stackViewUserData.axis = .vertical
        stackViewUserData.spacing = 10

        let stackView = UIStackView(arrangedSubviews: [imageViewProfilePicture, stackViewUserData])
        stackView.backgroundColor = .customBackground()
        stackView.axis = .horizontal
        stackView.layer.cornerRadius = 10
        stackView.spacing = 10
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(all: 5)

        let stackViewCoin = UIStackView(arrangedSubviews: [viewCoinCount, labelCoin])
        stackViewCoin.axis = .vertical
        stackViewCoin.spacing = 5

        let stackViewVideo = UIStackView(arrangedSubviews: [viewVideoCount, labelVideo])
        stackViewVideo.axis = .vertical
        stackViewVideo.spacing = 5

        let stackViewPoint = UIStackView(arrangedSubviews: [viewPointCount, labelPoint])
        stackViewPoint.axis = .vertical
        stackViewPoint.spacing = 5

        let stackViewVideoData = UIStackView(arrangedSubviews: [stackViewVideo, stackViewPoint, stackViewCoin])
        stackViewVideoData.axis = .horizontal
        stackViewVideoData.spacing = 10
        stackViewVideoData.distribution = .fillEqually

        let stackViewAll = UIStackView(arrangedSubviews: [stackView, stackViewVideoData])
        stackViewAll.axis = .vertical
        stackViewAll.spacing = 10

        addSubview(stackViewAll)

        stackViewAll.anchor(leading: leadingAnchor, trailing: trailingAnchor)

        viewVideoCount.addSubview(labelVideoCount)
        viewPointCount.addSubview(labelPointCount)
        viewCoinCount.addSubview(labelCoinCount)

        labelVideoCount.addToSuperViewAnchors(padding: .init(all: 5))
        labelPointCount.addToSuperViewAnchors(padding: .init(all: 5))
        labelCoinCount.addToSuperViewAnchors(padding: .init(all: 5))
    }
}
