//
//  MessageCell.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 22.04.21.
//

import UIKit

class MessageCell: UITableViewCell {
    
    let allView : UIView = {
        let view = UIView()
        view.roundCorners([.topLeft,.bottomLeft,.bottomRight], radius: 15)
        view.backgroundColor = .customTintColor()
        return view
    }()
    
    let lblMessage : UILabel = {
       let lbl = UILabel()
        lbl.textColor = .white
        lbl.numberOfLines = 0
        lbl.font = .boldSystemFont(ofSize: 17)
        lbl.text = ""
        return lbl
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = .clear
        selectionStyle = .none
        
        addSubview(allView)
        
        allView.addSubview(lblMessage)
        
        allView.doldurSuperView(padding: .init(top: 10, left: 30, bottom: 10, right: 10))
        
        lblMessage.doldurSuperView(padding: .init(top: 10, left: 10, bottom: 10, right: 10))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
