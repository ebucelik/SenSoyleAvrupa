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

class HomeCell: UICollectionViewCell {

    var homeView: HomeView = HomeView(frame: .zero)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        homeView = HomeView(frame: bounds)

        addSubview(homeView)

        homeView.addToSuperViewAnchors()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(homeView)

        homeView.addToSuperViewAnchors()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        homeView.resetViewsForReuse()
    }
}
