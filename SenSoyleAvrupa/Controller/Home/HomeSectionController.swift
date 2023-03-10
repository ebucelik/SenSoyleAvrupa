//
//  HomeSectionController.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 25.03.22.
//

import UIKit
import IGListKit
import AVFoundation

class HomeSectionController: ListSectionController {

    private var videoDataModel: VideoDataModel?
    private var adShowed = false

    override init() {
        super.init()
        displayDelegate = self
    }

    override func numberOfItems() -> Int {
        1
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return viewController?.view.bounds.size ?? .zero
    }

    override func didUpdate(to object: Any) {
        self.videoDataModel = object as? VideoDataModel
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext.dequeueReusableCell(of: HomeCell.self, for: self, at: index)

        if let cell = cell as? HomeCell, let model = videoDataModel, let viewController = viewController as? HomeController {
            cell.homeView.configure(with: model)

            cell.homeView.buttonProfileImageAction = { [self] in
                print("Go to profile account")

                let vc = ProfileController(store: .init(initialState: ProfileState(),
                                                        reducer: profileReducer,
                                                        environment: ProfileEnvironment(service: Services.profileService,
                                                                                        mainQeue: .main)),
                                           userModel: UserModel(coin: 0,
                                                                id: model.id ?? 0,
                                                                points: 0,
                                                                pp: model.pp ?? "",
                                                                username: model.username ?? ""),
                                           email: model.email ?? "")

                self.viewController?.navigationController?.navigationBar.tintColor = .customLabelColor()
                self.viewController?.navigationController?.pushViewController(vc, animated: true)
            }

            cell.homeView.buttonSendPoint = {
                print("Send point")
                viewController.sendPoints(email: model.email ?? "", videoId: model.id ?? 0, point: Int(cell.homeView.ratingView.labelTop.text!) ?? 0)
                cell.homeView.ratingView.ratingView.rating = 0
                cell.homeView.ratingView.labelTop.text = "0"
                cell.homeView.ratingView.isHidden = true
            }

            cell.homeView.buttonCommentAction = {
                print("Comment")
                let vc = CommentController()
                vc.videoid = model.id ?? 0
                vc.email = model.email ?? ""
                self.viewController?.presentPanModal(vc)
            }

            cell.homeView.buttonSpamAction = {
                let id = model.id ?? 0
                let alert = UIAlertController(title: "Bildiri", message: "Bir sebep se??in", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Spam veya k??t??ye kullan??m", style: .default, handler: { (_) in
                    viewController.spamPost(videoId: id, type: 1)
                }))
                alert.addAction(UIAlertAction(title: "Yan??lt??c?? bilgi", style: .default, handler: { (_) in
                    viewController.spamPost(videoId: id, type: 2)
                }))
                alert.addAction(UIAlertAction(title: "Tehlikeli kurulu??lar ve ki??iler", style: .default, handler: { (_) in
                    viewController.spamPost(videoId: id, type: 3)
                }))
                alert.addAction(UIAlertAction(title: "Yasad?????? faaliyetler", style: .default, handler: { (_) in
                    viewController.spamPost(videoId: id, type: 4)
                }))
                alert.addAction(UIAlertAction(title: "Doland??r??c??l??k", style: .default, handler: { (_) in
                    viewController.spamPost(videoId: id, type: 5)
                }))
                alert.addAction(UIAlertAction(title: "??iddet i??eren ve sans??rlenmemi?? i??erik", style: .default, handler: { (_) in
                    viewController.spamPost(videoId: id, type: 6)
                }))
                alert.addAction(UIAlertAction(title: "Hayvan zul??m??", style: .default, handler: { (_) in
                    viewController.spamPost(videoId: id, type: 7)
                }))
                alert.addAction(UIAlertAction(title: "Nefret s??ylemi", style: .default, handler: { (_) in
                    viewController.spamPost(videoId: id, type: 8)
                }))
                alert.addAction(UIAlertAction(title: "??ptal et", style: .cancel))

                viewController.present(alert, animated: true, completion: nil)
            }
        }

        return cell
    }
}

extension HomeSectionController: ListDisplayDelegate {
    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        if let cell = cell as? HomeCell {
            cell.homeView.downloadVideo()
            cell.homeView.playerView.playerLayer.player?.play()
        }
    }

    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        if let cell = cell as? HomeCell {
            cell.homeView.playerView.playerLayer.player?.pause()
            cell.homeView.downloadVideo()
        }
    }

    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController) {}

    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController) {
        if (section % 5 == 0 && section != 0 && !adShowed) {
            let number = Int.random(in: 0...1)

            if number == 0 {
                let vc = AdvertisementController()
                vc.modalPresentationStyle = .fullScreen
                viewController?.present(vc, animated: true)
            } else {
                if let viewController = viewController as? HomeController {
                    viewController.startGoogleAdMob()
                }
            }

            adShowed = true
        } else {
            adShowed = false
        }
    }
}
