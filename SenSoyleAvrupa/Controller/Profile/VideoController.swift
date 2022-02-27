//
//  VideoController.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 26.02.22.
//

import Foundation
import UIKit
import AVFoundation

class VideoController: UIViewController {

    private let homeView: HomeView
    private let model: VideoDataModel
    private var player: AVPlayer?

    init(model: VideoDataModel) {
        self.homeView = HomeView(frame: .zero)
        self.model = model

        super.init(nibName: nil, bundle: nil)

        self.configureCommentButtonAction()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        checkInternetConnection()

        homeView.setPlayerView(player: player)
        homeView.playerView.player?.play()
    }

    override func viewDidDisappear(_ animated: Bool) {
        homeView.resetViewsForReuse()
    }

    override func viewDidLoad() {
        view.addSubview(homeView)

        homeView.addToSuperViewAnchors()
        homeView.configure(with: model)
        homeView.downloadVideo()
        homeView.playerView.player?.play()
        player = homeView.playerView.player
    }

    func configureCommentButtonAction() {
        homeView.buttonCommentAction = { [self] in
            print("Comment")
            let vc = CommentController()
            vc.videoid = model.id ?? 0
            vc.email = model.email ?? ""
            self.presentPanModal(vc)
        }
    }
}
