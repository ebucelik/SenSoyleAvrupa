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
    
    let activityIndicator : NVActivityIndicatorView = {
        let view = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30), type: .ballClipRotatePulse, color: .customTintColor(), padding: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let profilImage : UIImageView = {
        let btn = UIImageView(image: UIImage(named: "emojiman"))
        btn.tintColor = .customTintColor()
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 50).isActive = true
        //btn.addTarget(self, action: #selector(actionLeft), for: .touchUpInside)
        btn.layer.cornerRadius = 25
        btn.backgroundColor = .customBackgorund()
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.customTintColor().cgColor
        btn.clipsToBounds = true
        btn.isUserInteractionEnabled = true
        return btn
    }()
    
    let btnStar : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "star"), for: .normal)
        btn.tintColor = .customTintColor()
        btn.heightAnchor.constraint(equalToConstant: 36).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 36).isActive = true
        //btn.addTarget(self, action: #selector(actionLeft), for: .touchUpInside)
        btn.layer.cornerRadius = 18
        btn.backgroundColor = .customBackgorundButton()
        return btn
    }()
    
    let lblStar : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .customLabelColor()
        lbl.text = ""
        lbl.textAlignment = .center
        lbl.textColor = .black
        return lbl
    }()
    
    let btnComment : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "message"), for: .normal)
        btn.tintColor = .customTintColor()
        btn.heightAnchor.constraint(equalToConstant: 36).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 36).isActive = true
        //btn.addTarget(self, action: #selector(actionLeft), for: .touchUpInside)
        btn.layer.cornerRadius = 18
        btn.backgroundColor = .customBackgorundButton()
        return btn
    }()
    
    let lblComment : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .customLabelColor()
        lbl.text = ""
        lbl.textAlignment = .center
        return lbl
    }()
    
    let btnSpam : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "arrow.uturn.right"), for: .normal)
        btn.tintColor = .customTintColor()
        btn.heightAnchor.constraint(equalToConstant: 36).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 36).isActive = true
        //btn.addTarget(self, action: #selector(actionLeft), for: .touchUpInside)
        btn.layer.cornerRadius = 18
        btn.backgroundColor = .customBackgorundButton()
        return btn
    }()
    
    let lblName : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .customLabelColor()
        lbl.text = ""
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.font = .boldSystemFont(ofSize: 18)
        return lbl
    }()
    
    let lblStatus : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .customLabelColor()
        lbl.text = ""
        lbl.numberOfLines = 0
        lbl.textAlignment = .left
        return lbl
    }()
    
    let imgPause : UIImageView = {
        let img = UIImageView(image: UIImage(systemName: "play.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.white))
        img.heightAnchor.constraint(equalToConstant: 150).isActive = true
        img.widthAnchor.constraint(equalToConstant: 150).isActive = true
        img.alpha = 0
        return img
    }()
    
    var player: AVPlayer?
    
    private var model : Home?
    
    private(set) var isPlaying = false
    
    
    //Action
    var btnProfileImageAction : (()->())?
    var btnCommentAction : (()->())?
    var btnSpamAction : (()->())?
    var btnSendPoint : (()->())?
    var userid = 0
    
    let ratingView = RatingView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .white
        
        selectionStyle = .none
        
        let stackViewStar = UIStackView(arrangedSubviews: [btnStar,lblStar])
        stackViewStar.axis = .vertical
        stackViewStar.spacing = 1
        
        let stackViewComment = UIStackView(arrangedSubviews: [btnComment,lblComment])
        stackViewComment.axis = .vertical
        stackViewComment.spacing = 1
        
        let stackView = UIStackView(arrangedSubviews: [stackViewStar,stackViewComment,btnSpam])
        stackView.axis = .vertical
        stackView.spacing = 15
        
        let stackViewLbl = UIStackView(arrangedSubviews: [lblName,lblStatus])
        stackViewLbl.axis = .vertical
        stackViewLbl.spacing = 10
        
        addSubview(profilImage)
        addSubview(stackView)
        addSubview(stackViewLbl)
        
        addSubview(imgPause)
        
        addSubview(activityIndicator)
        
        addSubview(ratingView)
        
        activityIndicator.merkezKonumlamdirmaSuperView()

        profilImage.anchor(top: nil, bottom: stackView.topAnchor, leading: nil, trailing: trailingAnchor,padding: .init(top: 0, left: 0, bottom: 15, right: 14))
        
        
        stackView.anchor(top: nil, bottom: bottomAnchor, leading: nil, trailing: trailingAnchor,padding: .init(top: 0, left: 0, bottom: 50, right: 20))
        
        stackViewLbl.anchor(top: nil, bottom: safeAreaLayoutGuide.bottomAnchor, leading: leadingAnchor, trailing: stackView.leadingAnchor,padding: .init(top: 0, left: 20, bottom: 20, right: 0))
        
        imgPause.merkezKonumlamdirmaSuperView()
     
        let gesture = UITapGestureRecognizer(target: self, action: #selector(actionPlayPause))
        addGestureRecognizer(gesture)
        
        //Action
        //profilImage.addTarget(self, action: #selector(profileImageAction), for: .touchUpInside)
        
        let gestureImage = UITapGestureRecognizer(target: self, action: #selector(profileImageAction))
        profilImage.addGestureRecognizer(gestureImage)
        btnStar.addTarget(self, action: #selector(starAction), for: .touchUpInside)
        btnComment.addTarget(self, action: #selector(commentAction), for: .touchUpInside)
        btnSpam.addTarget(self, action: #selector(spamAction), for: .touchUpInside)
        
        ratingView.doldurSuperView()
        editRatingView()
    }
    
    func editRatingView() {
        ratingView.isHidden = true
        
        ratingView.btnLeft.addTarget(self, action: #selector(actionRatingViewLeft), for: .touchUpInside)
        
        ratingView.btnSend.addTarget(self, action: #selector(actionRatingViewSend), for: .touchUpInside)
        
        ratingView.ratingView.didTouchCosmos = { Rating in
            self.ratingView.lblTop.text = String(Int(Rating))
        }
    }
    
    @objc func actionRatingViewSend() {
        btnSendPoint?()
    }
    
    @objc func actionRatingViewLeft() {
        ratingView.isHidden = true
    }
    
    @objc func profileImageAction() {
        btnProfileImageAction?()
    }
    
    @objc func starAction() {
        ratingView.isHidden = false
    }
    
    @objc func commentAction() {
        btnCommentAction?()
    }
    
    @objc func spamAction() {
        btnSpamAction?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //player.cancelAllLoadingRequest()
        resetViewsForReuse()
    }
    
    @objc func actionPlayPause() {
        
        if !isPlaying {
            UIView.animate(withDuration: 0.075, delay: 0, options: .curveEaseIn, animations: { [weak self] in
                guard let self = self else { return }
                self.imgPause.alpha = 0.50
                self.imgPause.transform = CGAffineTransform.init(scaleX: 0.45, y: 0.45)
            }, completion: { [weak self] _ in
                self?.player?.pause()
                self?.isPlaying = true
                return
            })
            
        }
        
        if isPlaying {
            
            UIView.animate(withDuration: 0.075, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                guard let self = self else { return }
                self.imgPause.alpha = 0
            }, completion: { [weak self] _ in
                self?.player?.play()
                self?.isPlaying = false
                self?.imgPause.transform = .identity
                return
                
            })
            
        }
    }
    
    func resetViewsForReuse(){
        imgPause.alpha = 0
    }
    
    
    public func configure(with model:Home) {
        self.model = model
        confugireVideo()
        
    }
    
    func confugireVideo() {
        profilImage.sd_setImage(with: URL(string: "\(NetworkManager.url)/pp/\(model?.pp ?? "")"), completed: nil)
        lblStar.text = "\(model?.likes ?? 0)"
        lblComment.text = "\(model?.comment ?? 0)"
        lblName.text = model?.username
        lblStatus.text = model?.status
        
        lblStatus.text = model?.status
        
        guard let url = URL(string: "\(NetworkManager.url)/video/\(model?.video ?? "")") else {
            return
        }
        
        player = AVPlayer(url: url)
    
        let playerView = AVPlayerLayer()
        playerView.backgroundColor = UIColor.customBackgorund().cgColor
        playerView.player = player
        playerView.frame = contentView.bounds
        playerView.videoGravity = .resize
        contentView.layer.addSublayer(playerView)
        //player?.volume = 0
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        player?.play()
    }
    
    
   @objc func playerDidFinishPlaying(note: NSNotification){
        player?.seek(to: CMTime.zero)
        player?.play()
        //confugireVideo()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}


