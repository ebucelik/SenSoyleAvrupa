//
//  HomeCell.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 16.04.21.
//

import UIKit
import AVFoundation
import AVKit
import NVActivityIndicatorView
import Alamofire

class HomeCell: UITableViewCell {

    // MARK: Variables
    var player: AVPlayer?

    private var model: Home? {
        didSet {
            profilImage.sd_setImage(with: URL(string: "\(NetworkManager.url)/pp/\(model?.pp ?? "")"), completed: nil)
            labelStar.text = "\(model?.likes ?? 0)"
            labelComment.text = "\(model?.comment ?? 0)"
            labelName.text = model?.username
            labelStatus.text = model?.status
        }
    }

    private(set) var isPlaying = true

    //Action
    var buttonProfileImageAction: (() -> (Void))?
    var buttonCommentAction: (() -> (Void))?
    var buttonSpamAction: (() -> (Void))?
    var buttonSendPoint: (() -> (Void))?

    let ratingView = RatingView()

    let alphaBackgroundColor: UIColor = .white.withAlphaComponent(0.3)

    // MARK: Views
    let activityIndicator: NVActivityIndicatorView = {
        let view = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30), type: .ballClipRotatePulse, color: .customTintColor(), padding: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let profilImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "emojiman"))
        imageView.tintColor = .customTintColor()
        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.layer.cornerRadius = 25
        imageView.backgroundColor = .customBackgorund()
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.customTintColor().cgColor
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let buttonStar: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "star"), for: .normal)
        button.tintColor = .customTintColor()
        button.heightAnchor.constraint(equalToConstant: 36).isActive = true
        button.widthAnchor.constraint(equalToConstant: 36).isActive = true
        button.layer.cornerRadius = 18
        button.backgroundColor = .customBackgorundButton()
        return button
    }()
    
    let labelStar: UILabel = {
        let label = UILabel()
        label.textColor = .customLabelColor()
        label.text = ""
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    let buttonComment: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "message"), for: .normal)
        button.tintColor = .customTintColor()
        button.heightAnchor.constraint(equalToConstant: 36).isActive = true
        button.widthAnchor.constraint(equalToConstant: 36).isActive = true
        button.layer.cornerRadius = 18
        button.backgroundColor = .customBackgorundButton()
        return button
    }()
    
    let labelComment: UILabel = {
        let label = UILabel()
        label.textColor = .customLabelColor()
        label.text = ""
        label.textAlignment = .center
        return label
    }()
    
    let buttonSpam: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.uturn.right"), for: .normal)
        button.tintColor = .customTintColor()
        button.heightAnchor.constraint(equalToConstant: 36).isActive = true
        button.widthAnchor.constraint(equalToConstant: 36).isActive = true
        button.layer.cornerRadius = 18
        button.backgroundColor = .customBackgorundButton()
        return button
    }()
    
    let labelName: UILabel = {
        let label = UILabel()
        label.textColor = .customLabelColor()
        label.text = ""
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }()
    
    let labelStatus: UILabel = {
        let label = UILabel()
        label.textColor = .customLabelColor()
        label.text = ""
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    let imageViewPause: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "play.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.white))
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        imageView.alpha = 0
        return imageView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .white
        selectionStyle = .none
        
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

        let stackViewWithBackground = UIStackView(arrangedSubviews: [stackViewButtonComponents])
        stackViewWithBackground.axis = .vertical
        stackViewWithBackground.backgroundColor = alphaBackgroundColor
        stackViewWithBackground.roundCorners(.allCorners, radius: 8)

        let stackView = UIStackView(arrangedSubviews: [profilImage, stackViewWithBackground])
        stackView.axis = .vertical
        stackView.spacing = 15

        let stackViewLabelComponents = UIStackView(arrangedSubviews: [labelName, labelStatus])
        stackViewLabelComponents.axis = .vertical
        stackViewLabelComponents.spacing = 10
        stackViewLabelComponents.layoutMargins = UIEdgeInsets(all: 5)
        stackViewLabelComponents.isLayoutMarginsRelativeArrangement = true

        let stackViewLabelWithBackground = UIStackView(arrangedSubviews: [stackViewLabelComponents])
        stackViewLabelWithBackground.axis = .vertical
        stackViewLabelWithBackground.backgroundColor = alphaBackgroundColor
        stackViewLabelWithBackground.roundCorners(.allCorners, radius: 8)

        let stackViewLabel = UIStackView(arrangedSubviews: [stackViewLabelWithBackground])
        stackViewLabel.axis = .vertical

        addSubview(stackView)
        addSubview(stackViewLabel)
        addSubview(imageViewPause)
        addSubview(activityIndicator)
        addSubview(ratingView)
        
        activityIndicator.centerViewAtSuperView()
        
        stackView.anchor(bottom: safeAreaLayoutGuide.bottomAnchor,
                         trailing: trailingAnchor,
                         padding: .init(top: 0, left: 0, bottom: 16, right: 16))

        stackViewLabel.anchor(bottom: safeAreaLayoutGuide.bottomAnchor,
                              leading: leadingAnchor,
                              padding: .init(top: 0, left: 16, bottom: 16, right: 0))
        
        imageViewPause.centerViewAtSuperView()

        let gesture = UITapGestureRecognizer(target: self, action: #selector(actionPlayPause))
        addGestureRecognizer(gesture)
        
        let gestureImage = UITapGestureRecognizer(target: self, action: #selector(profileImageAction))
        profilImage.addGestureRecognizer(gestureImage)

        buttonStar.addTarget(self, action: #selector(showRatingView), for: .touchUpInside)
        buttonComment.addTarget(self, action: #selector(commentAction), for: .touchUpInside)
        buttonSpam.addTarget(self, action: #selector(spamAction), for: .touchUpInside)
        
        ratingView.addToSuperViewAnchors()
        editRatingView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        resetViewsForReuse()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        imageViewPause.alpha = 0
        isPlaying = true
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
        player?.pause()
        player = nil
    }

    public func configure(with model: Home) {
        self.model = model
        configureVideo()
    }

    func configureVideo() {
        guard let url = URL(string: "\(NetworkManager.url)/video/\(model?.video ?? "")") else { return }
        
        player = AVPlayer(url: url)

        let playerView = AVPlayerLayer()
        playerView.backgroundColor = UIColor.customBackgorund().cgColor
        playerView.player = player
        playerView.frame = contentView.bounds
        playerView.videoGravity = .resize
        contentView.layer.addSublayer(playerView)

        NotificationCenter.default.addObserver(self,
                                               selector:#selector(self.playerDidFinishPlaying(note:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
    }

    func animate(options: UIView.AnimationOptions, animations: @escaping () -> Void, completion: ((Bool) -> (Void))? = nil) {
        UIView.animate(withDuration: 0.075, delay: 0, options: options, animations: animations, completion: completion)
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
                self?.player?.pause()
                return
            })
        }

        if isPlaying {
            animate(options: .curveEaseInOut, animations: { [weak self] in
                guard let self = self else { return }
                self.imageViewPause.alpha = 0
            }, completion: { [weak self] _ in
                self?.imageViewPause.transform = .identity
                self?.player?.play()
                return
            })
        }
    }

    @objc func playerDidFinishPlaying(note: NSNotification){
        player?.seek(to: CMTime.zero)
        player?.play()
    }
}
