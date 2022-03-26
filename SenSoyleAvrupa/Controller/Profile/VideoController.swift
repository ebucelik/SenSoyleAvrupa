//
//  VideoController.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 26.02.22.
//

import UIKit
import AVFoundation
import Alamofire

class VideoController: UIViewController {

    // MARK: Properties
    private let homeView: HomeView
    private let model: VideoDataModel
    private let service: SharedServiceProtocol
    private var modelDidChanged: Bool = false
    private var player: AVPlayer?

    // MARK: Actions
    var onDismiss: ((Bool) -> Void)? = nil

    init(model: VideoDataModel, service: SharedServiceProtocol) {
        self.homeView = HomeView(frame: .zero)
        self.model = model
        self.service = service

        super.init(nibName: nil, bundle: nil)

        configureRatingButtonAction()
        configureCommentButtonAction()
        configureSpamButtonAction()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        checkInternetConnection(completion: nil)

        if homeView.playerView.player == nil {
            homeView.setPlayerView(player: player)
            homeView.playerView.player?.play()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        homeView.resetViewsForReuse()
    }

    override func viewWillDisappear(_ animated: Bool) {
        guard let onDismiss = onDismiss else { return }

        onDismiss(modelDidChanged)
    }

    override func viewDidLoad() {
        view.addSubview(homeView)

        homeView.addToSuperViewAnchors()
        homeView.configure(with: model)
        homeView.downloadVideo()
        homeView.playerView.player?.play()
        player = homeView.playerView.player
    }

    func configureRatingButtonAction() {
        homeView.buttonSendPoint = { [self] in
            print("Send point")
            sendPoints(email: model.email ?? "", videoId: model.id ?? 0, point: Int(homeView.ratingView.labelTop.text!) ?? 0)
            homeView.ratingView.ratingView.rating = 0
            homeView.ratingView.labelTop.text = "0"
            homeView.ratingView.isHidden = true
        }
    }

    func configureCommentButtonAction() {
        homeView.buttonCommentAction = { [self] in
            print("Comment")
            let commentController = CommentController()
            commentController.videoid = model.id ?? 0
            commentController.email = model.email ?? ""
            commentController.onDismiss = { modelDidChanged in
                if modelDidChanged {
                    pullData()
                }
            }

            self.presentPanModal(commentController)
        }
    }

    func configureSpamButtonAction() {
        homeView.buttonSpamAction = {
            let id = self.model.id ?? 0
            let alert = UIAlertController(title: "Bildiri", message: "Bir sebep seçin", preferredStyle: .actionSheet)

            alert.addAction(UIAlertAction(title: "Spam veya kötüye kullanım", style: .default, handler: { (_) in
                self.spamPost(type: 1, id: id)
            }))
            alert.addAction(UIAlertAction(title: "Yanıltıcı bilgi", style: .default, handler: { (_) in
                self.spamPost(type: 2, id: id)
            }))
            alert.addAction(UIAlertAction(title: "Tehlikeli kuruluşlar ve kişiler", style: .default, handler: { (_) in
                self.spamPost(type: 3, id: id)
            }))
            alert.addAction(UIAlertAction(title: "Yasadışı faaliyetler", style: .default, handler: { (_) in
                self.spamPost(type: 4, id: id)
            }))
            alert.addAction(UIAlertAction(title: "Dolandırıcılık", style: .default, handler: { (_) in
                self.spamPost(type: 5, id: id)
            }))
            alert.addAction(UIAlertAction(title: "Şiddet içeren ve sansürlenmemiş içerik", style: .default, handler: { (_) in
                self.spamPost(type: 6, id: id)
            }))
            alert.addAction(UIAlertAction(title: "Hayvan zulümü", style: .default, handler: { (_) in
                self.spamPost(type: 7, id: id)
            }))
            alert.addAction(UIAlertAction(title: "Nefret söylemi", style: .default, handler: { (_) in
                self.spamPost(type: 8, id: id)
            }))
            alert.addAction(UIAlertAction(title: "İptal et", style: .cancel))

            self.present(alert, animated: true)
        }
    }

    func spamPost(type: Int, id: Int) {
        service.spamPost(type: type, id: id) { [self] in
            if let status = $0.status, status {
                makeAlert(title: "Başarılı", message: "Bildiriniz bizim için çok önemli. Teşekkürler") { _ in
                    self.modelDidChanged = true
                    dismiss(animated: true)
                }
            } else {
                makeAlert(title: "Hata", message: $0.message ?? "")
            }
        }
    }

    func sendPoints(email: String, videoId: Int, point: Int) {
        service.sendPoints(email: email, videoId: videoId, point: point) { [self] in
            if let status = $0.status, status {
                makeAlert(title: "Başarılı", message: "Puan verdiğiniz için teşekkürler")
                pullData()
            }else{
                makeAlert(title: "Hata", message: $0.message ?? "")
            }
        }
    }

    func pullData() {
        service.pullUserData(email: model.email ?? "") { [self] userModel in
            service.pullProfileData(email: model.email ?? "", userId: userModel.id ?? 0) { videoDataModels in
                videoDataModels.forEach { [self] in
                    if $0.id == model.id {
                        model.likes = $0.likes
                        model.comment = $0.comment
                        modelDidChanged = true
                        homeView.configure(with: model)
                    }
                }
            }
        }
    }
}
