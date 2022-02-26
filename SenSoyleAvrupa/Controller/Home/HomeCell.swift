//
//  HomeCell.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 16.04.21.
//

import UIKit
import AVFoundation
import AVKit
import NVActivityIndicatorView
import Alamofire

class HomeCell: UITableViewCell {

    var homeView: HomeView = HomeView(frame: .zero)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none

        homeView = HomeView(frame: bounds)

        addSubview(homeView)

        homeView.addToSuperViewAnchors()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        homeView.resetViewsForReuse()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        homeView.setSelected()
    }
}
