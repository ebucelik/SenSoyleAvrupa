//
//  ProfileVideoController.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 26.02.22.
//

import UIKit
import AVFoundation
import Alamofire

class ProfileVideoController: UIViewController {

    // MARK: Properties
    private let homeView: HomeView
    private let model: VideoDataModel
    private let service: SharedServiceProtocol
    private var modelDidChanged: Bool = false

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

        homeView.downloadVideo()
        homeView.playerView.playerLayer.player?.play()
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
                    self.pullData()
                }
            }

            self.presentPanModal(commentController)
        }
    }

    func configureSpamButtonAction() {
        homeView.buttonSpamAction = {
            let id = self.model.id ?? 0
            let alert = UIAlertController(title: "Bildiri", message: "Bir sebep se??in", preferredStyle: .actionSheet)

            alert.addAction(UIAlertAction(title: "Spam veya k??t??ye kullan??m", style: .default, handler: { (_) in
                self.spamPost(type: 1, id: id)
            }))
            alert.addAction(UIAlertAction(title: "Yan??lt??c?? bilgi", style: .default, handler: { (_) in
                self.spamPost(type: 2, id: id)
            }))
            alert.addAction(UIAlertAction(title: "Tehlikeli kurulu??lar ve ki??iler", style: .default, handler: { (_) in
                self.spamPost(type: 3, id: id)
            }))
            alert.addAction(UIAlertAction(title: "Yasad?????? faaliyetler", style: .default, handler: { (_) in
                self.spamPost(type: 4, id: id)
            }))
            alert.addAction(UIAlertAction(title: "Doland??r??c??l??k", style: .default, handler: { (_) in
                self.spamPost(type: 5, id: id)
            }))
            alert.addAction(UIAlertAction(title: "??iddet i??eren ve sans??rlenmemi?? i??erik", style: .default, handler: { (_) in
                self.spamPost(type: 6, id: id)
            }))
            alert.addAction(UIAlertAction(title: "Hayvan zul??m??", style: .default, handler: { (_) in
                self.spamPost(type: 7, id: id)
            }))
            alert.addAction(UIAlertAction(title: "Nefret s??ylemi", style: .default, handler: { (_) in
                self.spamPost(type: 8, id: id)
            }))
            alert.addAction(UIAlertAction(title: "??ptal et", style: .cancel))

            self.present(alert, animated: true)
        }
    }

    func spamPost(type: Int, id: Int) {
        service.spamPost(type: type, id: id) { [self] in
            if let status = $0.status, status {
                makeAlert(title: "Ba??ar??l??", message: "Bildiriniz bizim i??in ??ok ??nemli. Te??ekk??rler") { _ in
                    self.modelDidChanged = true
                    self.dismiss(animated: true)
                }
            } else {
                makeAlert(title: "Hata", message: $0.message ?? "")
            }
        }
    }

    func sendPoints(email: String, videoId: Int, point: Int) {
        service.sendPoints(email: email, videoId: videoId, point: point) { [self] in
            if let status = $0.status, status {
                makeAlert(title: "Ba??ar??l??", message: "Puan verdi??iniz i??in te??ekk??rler")
                pullData()
            }else{
                makeAlert(title: "Hata", message: $0.message ?? "")
            }
        }
    }

    func pullData() {
        service.pullUserData(email: model.email ?? "") { [self] userModel in
            service.pullProfileData(email: model.email ?? "", userId: userModel.id ?? 0) { [self] videoDataModels in
                videoDataModels.forEach {
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
