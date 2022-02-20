//
//  CommentCell.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 18.04.21.
//

import UIKit

class CommentCell: UITableViewCell {
    
    let imgProfile : UIImageView = {
        let img = UIImageView(image: UIImage(systemName: "person.crop.circle")?.withRenderingMode(.alwaysOriginal).withTintColor(.customLabelColor()))
        img.heightAnchor.constraint(equalToConstant: 40).isActive = true
        img.widthAnchor.constraint(equalToConstant: 40).isActive = true
        img.layer.cornerRadius = 20
        img.clipsToBounds = true
        return img
    }()
    
    let commentView : UIView = {
       let view = UIView()
        view.backgroundColor = .customBackgorund()
        view.layer.cornerRadius = 15
        return view
    }()
    
    let lblName : UILabel = {
       let lbl = UILabel()
        lbl.textColor = .customLabelColor()
        lbl.font = .boldSystemFont(ofSize: 18)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.text = ""
        return lbl
    }()
    
    let lblComment : UILabel = {
       let lbl = UILabel()
        lbl.textColor = .customLabelColor()
        lbl.font = .systemFont(ofSize: 17)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.text = ""
        return lbl
    }()
    
    let btnSpam : UIButton = {
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
        
        let stackView = UIStackView(arrangedSubviews: [lblName,lblComment])
        stackView.axis = .vertical
        stackView.spacing = 5
        
        addSubview(imgProfile)
        
        addSubview(commentView)
        
        addSubview(btnSpam)
        
        commentView.addSubview(stackView)
        
        imgProfile.anchor(top: topAnchor, bottom: nil, leading: leadingAnchor, trailing: nil,padding: .init(top: 10, left: 10, bottom: 0, right: 0))
        
        btnSpam.anchor(top: imgProfile.bottomAnchor, bottom: nil, leading: leadingAnchor, trailing: nil,padding: .init(top: 5, left: 15, bottom: 0, right: 0))
        
        commentView.anchor(top: topAnchor, bottom: bottomAnchor, leading: imgProfile.trailingAnchor, trailing: trailingAnchor,padding: .init(top: 10, left: 5, bottom: 10, right: 10))
        
        stackView.anchor(top: commentView.topAnchor, bottom: commentView.bottomAnchor, leading: commentView.leadingAnchor, trailing: commentView.trailingAnchor,padding: .init(top: 10, left: 10, bottom: 10, right: 10))
        
        btnSpam.isHidden = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
