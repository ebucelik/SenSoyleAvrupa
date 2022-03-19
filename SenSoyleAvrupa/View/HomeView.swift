//
//  HomeView.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 26.02.22.
//

import Foundation
import UIKit
import AVFoundation
import NVActivityIndicatorView
import Alamofire

class HomeView: UIView {

    // MARK: Properties
    private(set) var isPlaying = true

    // MARK: Models
    private var userModel: UserModel? = nil {
        didSet {
            guard let userModel = userModel else {
                return
            }

            model = VideoDataModel(comment: model?.comment ?? 0,
                                   date: model?.date ?? "",
                                   email: model?.email ?? "",
                                   id: model?.id ?? 0,
                                   likes: model?.likes ?? 0,
                                   pp: userModel.pp ?? "",
                                   spam: model?.spam ?? 0,
                                   status: model?.status ?? "",
                                   user: model?.user ?? 0,
                                   username: userModel.username ?? "",
                                   video: model?.video ?? "")
        }
    }
    private var model: VideoDataModel? {
        didSet {
            guard let model = model else {
                return
            }

            let domain: String = (model.pp ?? "").contains(NetworkManager.url) ? "" : "\(NetworkManager.url)/pp/"

            profilImage.sd_setImage(with: URL(string: "\(domain)\(model.pp ?? "")"), completed: nil)
            labelStar.text = "\(model.likes ?? 0)"
            labelComment.text = "\(model.comment ?? 0)"
            labelName.text = "@\(model.username ?? "")"
            labelStatus.text = model.status
        }
    }

    //Action
    var buttonProfileImageAction: (() -> (Void))?
    var buttonCommentAction: (() -> (Void))?
    var buttonSpamAction: (() -> (Void))?
    var buttonSendPoint: (() -> (Void))?

    let alphaBackgroundColor: UIColor = .white.withAlphaComponent(0.3)

    // MARK: Views
    let loadingView: LoadingView = {
        let loadingView = LoadingView()
        loadingView.isHidden = true
        return loadingView
    }()

    let ratingView = RatingView()

    var playerView: PlayerView = {
        let playerView = PlayerView()
        playerView.backgroundColor = UIColor.customBackground()
        playerView.isUserInteractionEnabled = true
        playerView.playerLayer.videoGravity = .resize
        return playerView
    }()

    let profilImage: UIImageView = {
        let imageView = UIImageView(image: UIImage())
        imageView.contentMode = .scaleAspectFill
        imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        imageView.layer.cornerRadius = 20
        imageView.backgroundColor = .customBackground()
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    let buttonStar: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "star"), for: .normal)
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        return button
    }()

    let labelStar: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: UIFont.labelFontSize, weight: .bold)
        label.text = ""
        label.textAlignment = .center
        label.addShadow(opacity: 0.75, radius: 1)
        return label
    }()

    let buttonComment: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "text.bubble.fill"), for: .normal)
        button.tintColor = .white
        button.addShadow(opacity: 0.75, radius: 1)
        return button
    }()

    let labelComment: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: UIFont.labelFontSize, weight: .bold)
        label.text = ""
        label.textAlignment = .center
        label.addShadow(opacity: 0.75, radius: 1)
        return label
    }()

    let buttonSpam: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis.circle.fill"), for: .normal)
        button.tintColor = .white
        button.addShadow(opacity: 0.75, radius: 1)
        return button
    }()

    let labelName: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 12)
        label.text = ""
        label.numberOfLines = 0
        label.textAlignment = .left
        label.addShadow(opacity: 0.75, radius: 1)
        return label
    }()

    let labelStatus: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: UIFont.labelFontSize, weight: .bold)
        label.text = ""
        label.numberOfLines = 0
        label.textAlignment = .left
        label.addShadow(opacity: 0.75, radius: 1)
        return label
    }()

    let imageViewPause: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "play.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.white))
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        imageView.alpha = 0
        imageView.addShadow(opacity: 1, radius: 10)
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        let stackViewStar = UIStackView(arrangedSubviews: [buttonStar, labelStar])
        stackViewStar.axis = .vertical
        stackViewStar.spacing = 1

        let stackViewComment = UIStackView(arrangedSubviews: [buttonComment, labelComment])
        stackViewComment.axis = .vertical
        stackViewComment.spacing = 1

        let stackViewSpam = UIStackView(arrangedSubviews: [buttonSpam])
        stackViewComment.axis = .vertical
        stackViewComment.spacing = 1

        let stackViewButtonComponents = UIStackView(arrangedSubviews: [stackViewStar, stackViewComment, stackViewSpam])
        stackViewButtonComponents.axis = .vertical
        stackViewButtonComponents.spacing = 15
        stackViewButtonComponents.layoutMargins = UIEdgeInsets(all: 5)
        stackViewButtonComponents.isLayoutMarginsRelativeArrangement = true

        let stackView = UIStackView(arrangedSubviews: [profilImage, stackViewButtonComponents])
        stackView.axis = .vertical
        stackView.spacing = 15

        let stackViewLabelComponents = UIStackView(arrangedSubviews: [labelStatus, labelName])
        stackViewLabelComponents.axis = .vertical
        stackViewLabelComponents.spacing = 5
        stackViewLabelComponents.layoutMargins = UIEdgeInsets(all: 5)
        stackViewLabelComponents.isLayoutMarginsRelativeArrangement = true

        let stackViewLabel = UIStackView(arrangedSubviews: [stackViewLabelComponents])
        stackViewLabel.axis = .vertical

        addSubview(playerView)
        addSubview(stackView)
        addSubview(stackViewLabel)
        addSubview(imageViewPause)
        addSubview(ratingView)
        addSubview(loadingView)

        playerView.addToSuperViewAnchors()

        stackView.anchor(bottom: safeAreaLayoutGuide.bottomAnchor,
                         trailing: trailingAnchor,
                         padding: .init(top: 0, left: 0, bottom: 16, right: 16))

        stackViewLabel.anchor(bottom: safeAreaLayoutGuide.bottomAnchor,
                              leading: leadingAnchor,
                              padding: .init(top: 0, left: 16, bottom: 16, right: 0))

        imageViewPause.centerViewAtSuperView()

        let gesture = UITapGestureRecognizer(target: self, action: #selector(actionPlayPause))
        playerView.addGestureRecognizer(gesture)

        let gestureImage = UITapGestureRecognizer(target: self, action: #selector(profileImageAction))
        profilImage.addGestureRecognizer(gestureImage)

        buttonStar.addTarget(self, action: #selector(showRatingView), for: .touchUpInside)
        buttonComment.addTarget(self, action: #selector(commentAction), for: .touchUpInside)
        buttonSpam.addTarget(self, action: #selector(spamAction), for: .touchUpInside)

        ratingView.addToSuperViewAnchors()
        editRatingView()

        loadingView.addToSuperViewAnchors()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func editRatingView() {
        ratingView.isHidden = true

        ratingView.buttonLeft.addTarget(self, action: #selector(hideRatingView), for: .touchUpInside)

        ratingView.buttonSend.addTarget(self, action: #selector(actionRatingViewSend), for: .touchUpInside)

        ratingView.ratingView.didTouchCosmos = { rating in
            self.ratingView.labelTop.text = String(Int(rating))
        }
    }

    func resetViewsForReuse(){
        imageViewPause.alpha = 0
        playerView.player?.pause()
        playerView.player = nil
    }

    func configure(with model: VideoDataModel) {
        self.model = model
        fetchUserDataWhenNeeded()
    }

    func downloadVideo() {
        guard let url = URL(string: "\(NetworkManager.url)/video/\(model?.video ?? "")") else { return }

        setPlayerView(player: AVPlayer(url: url))
    }

    func setPlayerView(player: AVPlayer?) {
        playerView.player = player

        NotificationCenter.default.addObserver(self,
                                               selector:#selector(self.playerDidFinishPlaying(note:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: playerView.player?.currentItem)
    }

    func fetchUserDataWhenNeeded() {
        if model?.pp == nil || model?.username == nil {
            let userParameters: Parameters = ["email": model?.email ?? ""]

            NetworkManager.call(endpoint: "/api/user", method: .get, parameters: userParameters) { (result: Result<UserModel, Error>) in
                switch result {
                case let .failure(error):
                    print("Network request error: \(error)")
                case let .success(userModel):
                    self.userModel = userModel
                }
            }
        }
    }

    func animate(options: UIView.AnimationOptions, animations: @escaping () -> Void, completion: ((Bool) -> (Void))? = nil) {
        UIView.animate(withDuration: 0.075, delay: 0, options: options, animations: animations, completion: completion)
    }

    func setSelected() {
        imageViewPause.alpha = 0
        isPlaying = true
    }

    @objc func actionRatingViewSend() {
        buttonSendPoint?()
    }

    @objc func hideRatingView() {
        ratingView.isHidden = true
    }

    @objc func profileImageAction() {
        buttonProfileImageAction?()
    }

    @objc func showRatingView() {
        ratingView.isHidden = false
    }

    @objc func commentAction() {
        buttonCommentAction?()
    }

    @objc func spamAction() {
        buttonSpamAction?()
    }

    @objc func actionPlayPause() {
        isPlaying = !isPlaying

        if !isPlaying {
            animate(options: .curveEaseIn, animations: { [weak self] in
                guard let self = self else { return }
                self.imageViewPause.alpha = 0.50
                self.imageViewPause.transform = CGAffineTransform.init(scaleX: 0.45, y: 0.45)
            }, completion: { [weak self] _ in
                self?.playerView.player?.pause()
                return
            })
        }

        if isPlaying {
            animate(options: .curveEaseInOut, animations: { [weak self] in
                guard let self = self else { return }
                self.imageViewPause.alpha = 0
            }, completion: { [weak self] _ in
                self?.imageViewPause.transform = .identity
                self?.playerView.player?.play()
                return
            })
        }
    }

    @objc func playerDidFinishPlaying(note: NSNotification){
        DispatchQueue.main.async { [weak self] in
            self?.playerView.player?.seek(to: CMTime.zero)
            self?.playerView.player?.play()
        }
    }
}
