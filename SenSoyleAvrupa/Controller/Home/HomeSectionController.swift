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

    private let service = Services.sharedService
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

            cell.homeView.downloadVideo()

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
                let alert = UIAlertController(title: "Bildiri", message: "Bir sebep seçin", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Spam veya kötüye kullanım", style: .default, handler: { (_) in
                    viewController.spamPost(type: 1, id: id)
                }))
                alert.addAction(UIAlertAction(title: "Yanıltıcı bilgi", style: .default, handler: { (_) in
                    viewController.spamPost(type: 2, id: id)
                }))
                alert.addAction(UIAlertAction(title: "Tehlikeli kuruluşlar ve kişiler", style: .default, handler: { (_) in
                    viewController.spamPost(type: 3, id: id)
                }))
                alert.addAction(UIAlertAction(title: "Yasadışı faaliyetler", style: .default, handler: { (_) in
                    viewController.spamPost(type: 4, id: id)
                }))
                alert.addAction(UIAlertAction(title: "Dolandırıcılık", style: .default, handler: { (_) in
                    viewController.spamPost(type: 5, id: id)
                }))
                alert.addAction(UIAlertAction(title: "Şiddet içeren ve sansürlenmemiş içerik", style: .default, handler: { (_) in
                    viewController.spamPost(type: 6, id: id)
                }))
                alert.addAction(UIAlertAction(title: "Hayvan zulümü", style: .default, handler: { (_) in
                    viewController.spamPost(type: 7, id: id)
                }))
                alert.addAction(UIAlertAction(title: "Nefret söylemi", style: .default, handler: { (_) in
                    viewController.spamPost(type: 8, id: id)
                }))
                alert.addAction(UIAlertAction(title: "İptal et", style: .cancel))

                viewController.present(alert, animated: true, completion: nil)
            }
        }

        return cell
    }
}

extension HomeSectionController: ListDisplayDelegate {
    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        if let cell = cell as? HomeCell {
            cell.homeView.playerView.player?.play()
        }
    }

    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        if let cell = cell as? HomeCell {
            cell.homeView.playerView.player?.pause()
        }

        if (section % 5 == 0 && section != 0 && !adShowed) {
            let number = Int.random(in: 0...1)

            if number == 0 {
                let vc = ReklamController()
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

    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController) {}

    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController) {}
}
