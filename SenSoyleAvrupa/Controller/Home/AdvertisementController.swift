//
//  AdvertisementController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 28.04.21.
//

import UIKit
import Alamofire
import AVFoundation

class AdvertisementController: UIViewController {
    
    let buttonDismiss: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black
        button.heightAnchor.constraint(equalToConstant: 36).isActive = true
        button.widthAnchor.constraint(equalToConstant: 36).isActive = true
        button.addTarget(AdvertisementController.self, action: #selector(dismissViewController), for: .touchUpInside)
        button.layer.cornerRadius = 18
        button.backgroundColor = .customBackgroundColor()
        return button
    }()
    
    var player: AVPlayer?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true

        pullData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func pullData() {
        AF.request("\(NetworkManager.url)/api/get-ad", method: .get).responseString { response in
            print("response: \(response)")

            switch response.result {
            case .success(let url):
                self.configureVideo(url: url)
            case .failure(let error):
                print("Network request error: \(error)")
            }
        }
    }
    
    func configureVideo(url: String) {
        guard let url = URL(string: url) else {
            return
        }

        player = AVPlayer(url: url)

        let playerView = AVPlayerLayer()
        playerView.backgroundColor = UIColor.customBackground().cgColor
        playerView.player = player
        playerView.frame = view.bounds
        playerView.videoGravity = .resize
        view.layer.addSublayer(playerView)

        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        player?.play()
        
        view.addSubview(buttonDismiss)
        
        buttonDismiss.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                             leading: view.leadingAnchor,
                             padding: .init(top: 20, left: 20, bottom: 0, right: 0))
    }

    @objc override func dismissViewController() {
        dismiss(animated: true)
    }

    @objc func playerDidFinishPlaying(note: NSNotification){
        player?.seek(to: .zero)
        player?.play()
    }
}

//http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4
