//
//  ReklamController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 28.04.21.
//

import UIKit
import Alamofire
import AVFoundation

class ReklamController: UIViewController {
    
    let buttonLeft : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black
        button.heightAnchor.constraint(equalToConstant: 36).isActive = true
        button.widthAnchor.constraint(equalToConstant: 36).isActive = true
        button.addTarget(self, action: #selector(actionLeft), for: .touchUpInside)
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
    
    @objc func actionLeft() {
        dismiss(animated: true, completion: nil)
    }
    
    func pullData() {
        AF.request("\(NetworkManager.url)/api/get-ad",method: .get).responseString { [self] response in
            
            print("response: \(response)")
            
            switch response.result {
            case .success(let url):
                configureVideo(url: url)
                return
            case .failure(let error):
                print("error**: \(error)")
                return
            }
        }
    }
    
    func configureVideo(url: String) {
        print("url \(url)")
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
        //player?.volume = 0
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        player?.play()
        
        view.addSubview(buttonLeft)
        
        buttonLeft.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                       bottom: nil,
                       leading: view.leadingAnchor,
                       trailing: nil,
                       padding: .init(top: 20, left: 20, bottom: 0, right: 0))
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        player?.seek(to: .zero)
        player?.play()
    }
}

//http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4
