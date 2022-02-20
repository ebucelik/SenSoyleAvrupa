//
//  ProfileVideoCell.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 14.04.21.
//

import UIKit
import AVFoundation
import AVKit

class ProfileVideoCell: UICollectionViewCell {
    
    var player: AVPlayer?
    
    private var model : Home?
    
    let playerView = AVPlayerLayer()

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor =  .customBackgorund()
        layer.masksToBounds = false
        layer.cornerRadius = 20
        clipsToBounds = true
        
//        let gesture = UITapGestureRecognizer(target: self, action: #selector(actionGesture))
//        addGestureRecognizer(gesture)
    }
    
//    @objc func actionGesture() {
//        print("123")
//    }
    
    
    public func configure(with model:Home) {
        self.model = model
        confugireVideo()
    }
    
    func confugireVideo() {
        guard let url = URL(string: "cknuls.gq/video/\(model?.video ?? "")") else {
            return
        }
        player = AVPlayer(url: url)
        
        
        playerView.backgroundColor = UIColor.customBackgorund().cgColor
        playerView.player = player
       
        playerView.videoGravity = .resizeAspectFill
        contentView.layer.addSublayer(playerView)
        //player?.volume = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playerView.frame = contentView.bounds
    }
    
   
}

