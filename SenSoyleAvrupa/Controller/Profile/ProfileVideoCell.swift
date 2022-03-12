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

    var playerView: PlayerView = {
        let playerView = PlayerView()
        playerView.backgroundColor = UIColor.customBackground()
        return playerView
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .customBackground()
        layer.masksToBounds = false
        layer.cornerRadius = 10
        clipsToBounds = true

        addSubview(playerView)

        playerView.addToSuperViewAnchors()
    }

    func configureVideo(model: VideoDataModel) {
        guard let url = URL(string: "\(NetworkManager.url)/video/\(model.video ?? "")") else {
            return
        }

        player = AVPlayer(url: url)

        playerView.playerLayer.player = player
        playerView.playerLayer.videoGravity = .resizeAspectFill
    }

    func playVideo() {
        playerView.playerLayer.player?.play()
    }

    func pauseVideo() {
        playerView.playerLayer.player?.pause()
    }
}

