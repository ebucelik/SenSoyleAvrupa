//
//  EmptyView.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 19.03.22.
//

import UIKit

import SwiftHelper

class EmptyView: UIView {

    // MARK: Views
    let imageViewEmptyLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "xmark.octagon.fill")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .customLabelColor()
        imageView.heightAnchor.constraint(equalToConstant: 125).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 125).isActive = true
        return imageView
    }()

    let labelEmpty: UILabel = {
        let label = UILabel()
        label.text = "Uups!\nMalesef bu sayfa icin suan data yok.\nBaska zaman tekrar bakiniz."
        label.textColor = .customLabelColor()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .heavy)
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        addSubview(imageViewEmptyLogo)
        addSubview(labelEmpty)

        imageViewEmptyLogo.centerViewAtSuperView()
        labelEmpty.anchor(top: imageViewEmptyLogo.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: .init(all: 20))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
