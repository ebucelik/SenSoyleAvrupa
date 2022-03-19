//
//  EmptyCell.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 19.03.22.
//

import UIKit

class EmptyCell: UITableViewCell {

    // MARK: Views
    let emptyView = EmptyView()
    var tableViewFrame: CGRect = .zero

    override func awakeFromNib() {
        super.awakeFromNib()

        addSubview(emptyView)

        emptyView.addToSuperViewAnchors()
    }

    override func layoutSubviews() {
        frame = tableViewFrame
    }
}
