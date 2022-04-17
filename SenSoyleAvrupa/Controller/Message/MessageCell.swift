//
//  MessageCell.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 22.04.21.
//

import UIKit

import SwiftHelper

class MessageCell: UITableViewCell {

    // MARK: Views
    let allView: UIView = {
        let view = UIView()
        view.roundCorners([.topLeft, .bottomLeft, .bottomRight], radius: 15)
        view.backgroundColor = .customTintColor()
        return view
    }()

    let labelMessage: UILabel = {
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
        
        allView.addSubview(labelMessage)
        
        allView.addToSuperViewAnchors(padding: .init(top: 10, left: 30, bottom: 10, right: 10))
        labelMessage.addToSuperViewAnchors(padding: .init(all: 10))
    }
}
