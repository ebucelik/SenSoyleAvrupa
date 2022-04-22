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

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .customBackground()
        layer.masksToBounds = false
        layer.cornerRadius = 10
        clipsToBounds = true

        addSubview(imageView)

        imageView.addToSuperViewAnchors()
    }

    func configureVideo(model: VideoDataModel) {
        guard let url = URL(string: "\(NetworkManager.url)/video/\(model.video ?? "")") else {
            return
        }

        let videoAsset = AVAsset(url: url)
        let cmTime = CMTime(value: 1, timescale: 1)

        let assetImageGenerator = AVAssetImageGenerator(asset: videoAsset)
        assetImageGenerator.appliesPreferredTrackTransform = true
        assetImageGenerator.requestedTimeToleranceBefore = .zero
        assetImageGenerator.requestedTimeToleranceAfter = .zero

        assetImageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: cmTime)]) {
            requestedTime, image, actualTime, result, error in

            if let image = image {
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(cgImage: image)
                }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
    }
}
