//
//  CommentCell.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 18.04.21.
//

import UIKit

import SwiftHelper

class CommentCell: UITableViewCell {

    // MARK: Views
    let imageViewProfile: UIImageView = {
        let img = UIImageView(image: UIImage(systemName: "person.crop.circle")?.withRenderingMode(.alwaysOriginal).withTintColor(.customLabelColor()))
        img.contentMode = .scaleAspectFill
        img.heightAnchor.constraint(equalToConstant: 40).isActive = true
        img.widthAnchor.constraint(equalToConstant: 40).isActive = true
        img.layer.cornerRadius = 20
        img.clipsToBounds = true
        return img
    }()

    let viewComment: UIView = {
        let view = UIView()
        view.backgroundColor = .customBackground()
        view.layer.cornerRadius = 10
        return view
    }()
    
    let labelDate: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .customLabelColor()
        lbl.font = .systemFont(ofSize: 12)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.text = ""
        return lbl
    }()
    
    let labelComment: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .customLabelColor()
        lbl.font = .systemFont(ofSize: 17)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.text = ""
        return lbl
    }()
    
    let buttonSpam: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "rectangle.and.pencil.and.ellipsis"), for: .normal)
        btn.tintColor = .black
        return btn
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        backgroundColor = .clear
        
        let stackView = UIStackView(arrangedSubviews: [labelComment, labelDate])
        stackView.axis = .vertical
        stackView.spacing = 5
        
        addSubview(imageViewProfile)
        addSubview(viewComment)
        
        viewComment.addSubview(stackView)
        
        imageViewProfile.anchor(top: topAnchor,
                                leading: leadingAnchor,
                                padding: .init(top: 10, left: 10, bottom: 0, right: 0))

        viewComment.anchor(top: topAnchor,
                           bottom: bottomAnchor,
                           leading: imageViewProfile.trailingAnchor,
                           trailing: trailingAnchor,
                           padding: .init(top: 10, left: 5, bottom: 10, right: 10))
        
        stackView.anchor(top: viewComment.topAnchor,
                         bottom: viewComment.bottomAnchor,
                         leading: viewComment.leadingAnchor,
                         trailing: viewComment.trailingAnchor,
                         padding: .init(all: 10))
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        labelDate.text = nil
        labelComment.text = nil
    }
}
