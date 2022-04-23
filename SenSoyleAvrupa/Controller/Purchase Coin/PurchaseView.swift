//
//  PurchaseView.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 17.04.21.
//

import UIKit

import SwiftHelper

class PurchaseView: UIView {
    private let imageViewCoin: UIImageView = {
        let img = UIImageView(image: UIImage(named: "coin"))
        img.heightAnchor.constraint(equalToConstant: 50).isActive = true
        img.widthAnchor.constraint(equalToConstant: 50).isActive = true
        return img
    }()

    private let labelCoin: UILabel = {
        let lbl = UILabel()
        lbl.text = ""
        lbl.textColor = .customLabelColor()
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 30, weight: .heavy)
        lbl.numberOfLines = 0
        lbl.setContentHuggingPriority(.required, for: .horizontal)
        return lbl
    }()

    private let labelPrice: UILabel = {
        let lbl = UILabel()
        lbl.text = ""
        lbl.textColor = .lightGray
        lbl.textAlignment = .right
        lbl.font = .systemFont(ofSize: 17)
        lbl.numberOfLines = 0
        return lbl
    }()

    private let imageViewInfo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "info.circle.fill")?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .lightGray
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        return imageView
    }()

    private let labelInfo: UILabel = {
        let label = UILabel()
        label.text = "Ilk coin almaniz 9.99€'dan basliyor, ondan sonrasi 4.99€."
        label.textColor = .lightGray
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 10)
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .customBackgroundColor()
        layer.masksToBounds = false
        layer.cornerRadius = 10

        let stackViewComponents = UIStackView(arrangedSubviews: [imageViewCoin, labelCoin, labelPrice])
        stackViewComponents.axis = .horizontal
        stackViewComponents.spacing = 10
        stackViewComponents.distribution = .fillProportionally

        let stackViewInfo = UIStackView(arrangedSubviews: [imageViewInfo, labelInfo])
        stackViewInfo.axis = .horizontal
        stackViewInfo.spacing = 10

        let stackView = UIStackView(arrangedSubviews: [stackViewComponents, stackViewInfo])
        stackView.axis = .vertical
        stackView.spacing = 30

        addSubview(stackView)

        stackView.anchor(top: topAnchor, bottom: bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: .init(all: 24))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(model: PurchaseModel) {
        labelCoin.text = "\(model.coin)"
        labelPrice.text = "\(model.price) €".replacingOccurrences(of: ".", with: ",")
    }
}
