//
//  PlayerView.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 25.02.22.
//

import UIKit
import AVFoundation

class PlayerView: UIView {

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    func setPlayer() {
        playerLayer.player = SharedPlayer.player
        playerLayer.player?.automaticallyWaitsToMinimizeStalling = false
    }
}
