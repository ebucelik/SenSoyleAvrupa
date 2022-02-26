//
//  VideoController.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 26.02.22.
//

import Foundation
import UIKit

class VideoController: UIViewController {

    private let homeView: HomeView
    private let model: VideoDataModel

    init(model: VideoDataModel) {
        self.homeView = HomeView(frame: .zero)
        self.model = model

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        checkInternetConnection()
    }

    override func viewDidDisappear(_ animated: Bool) {
        homeView.resetViewsForReuse()
    }

    override func viewDidLoad() {
        view.addSubview(homeView)

        homeView.addToSuperViewAnchors()
        homeView.configure(with: model)
        homeView.playerView.player?.play()
    }
}
