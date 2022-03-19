//
//  ShareController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 17.04.21.
//

import UIKit
import Alamofire
import AVFoundation

class ShareVideoController: UITableViewController {

    // MARK: Variables
    private let service: SharedServiceProtocol
    private var urlLocal : URL?
    private var coin = 0

    // MARK: Views
    var videoPicker: VideoPicker!
    
    let buttonDismiss: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        btn.tintColor = .customTintColor()
        btn.heightAnchor.constraint(equalToConstant: 36).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 36).isActive = true
        btn.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        btn.layer.cornerRadius = 18
        btn.backgroundColor = .customBackgroundColor()
        return btn
    }()
    
    let allView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let labelCoinTitle: UILabel = {
        let lbl = UILabel()
        lbl.font = .boldSystemFont(ofSize: 15)
        lbl.textAlignment = .left
        lbl.text = "Coin Bakiyeniz:"
        lbl.textColor = .black
        return lbl
    }()
    
    let labelCoinCount: UILabel = {
        let lbl = UILabel()
        lbl.text = ""
        lbl.textColor = .customTintColor()
        lbl.font = .systemFont(ofSize: 30, weight: .heavy)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    let labelCoinInfo: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.textColor = .gray
        lbl.font = .systemFont(ofSize: 12)
        return lbl
    }()
    
    let labelTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "Video"
        lbl.textColor = .black
        lbl.font = .boldSystemFont(ofSize: 15)
        return lbl
    }()
    
    let playerView: PlayerView = {
        let view = PlayerView()
        view.backgroundColor = .customBackgroundColor()
        view.layer.cornerRadius = 10
        view.heightAnchor.constraint(equalToConstant: 200).isActive = true
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        view.playerLayer.videoGravity = .resizeAspectFill
        return view
    }()
    
    let labelVideoTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "Yorumunuz"
        lbl.textColor = .black
        lbl.font = .boldSystemFont(ofSize: 15)
        return lbl
    }()

    let textFieldVideoTitle : CustomTextField = {
        let view = CustomTextField()
        view.backgroundColor = .customBackgroundColor()
        view.layer.cornerRadius = 5
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        view.placeholder = "Video ile ilgili bir yorum yaz"
        view.textColor = .black
        return view
    }()
    
    let buttonSelectVideo : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("  Video seç", for: .normal)
        btn.backgroundColor = .white
        btn.titleLabel?.tintColor = .customTintColor()
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .heavy)
        btn.layer.cornerRadius = 15
        btn.layer.borderWidth = 2
        btn.layer.borderColor = UIColor.customTintColor().cgColor
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.addTarget(self, action: #selector(actionVideoView), for: .touchUpInside)
        return btn
    }()
    
    let buttonShareVideo : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("  Paylaş", for: .normal)
        btn.setImage(UIImage(systemName: "hand.point.up.braille")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        btn.backgroundColor = .customTintColor()
        btn.titleLabel?.tintColor = .white
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .heavy)
        btn.layer.cornerRadius = 15
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.addTarget(self, action: #selector(actionShareVideo), for: .touchUpInside)
        return btn
    }()

    let loadingView = LoadingView()

    init(service: SharedServiceProtocol) {
        self.service = service

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pullDataUser()
        
        pullDataCoinCount()

        editLayout()
        
        editTableView()
    }
    
    func editLayout() {
        tableView.backgroundColor = .white
        
        let btnStackView = UIStackView(arrangedSubviews: [buttonSelectVideo,buttonShareVideo])
        btnStackView.axis = .horizontal
        btnStackView.spacing = 15
        btnStackView.distribution = .fillEqually
        
        let stackView = UIStackView(arrangedSubviews: [labelCoinTitle,
                                                       labelCoinCount,
                                                       labelCoinInfo,
                                                       labelVideoTitle,
                                                       textFieldVideoTitle,
                                                       labelTitle,
                                                       playerView,
                                                       btnStackView])
        stackView.axis = .vertical
        stackView.spacing = 10
        
        allView.addSubview(buttonDismiss)
        allView.addSubview(stackView)

        buttonDismiss.anchor(top: allView.topAnchor, leading: allView.leadingAnchor, trailing: nil,padding: .init(top: 20, left: 20, bottom: 0, right: 0))
        
        stackView.anchor(top: buttonDismiss.bottomAnchor, leading: allView.leadingAnchor, trailing: allView.trailingAnchor,padding: .init(top: 20, left: 20, bottom: 0, right: 20))

        allView.addSubview(loadingView)
        loadingView.addToSuperViewAnchors()
        loadingView.isHidden = true
    }

    func editTableView() {
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        tableView.allowsMultipleSelection = false
        
        //Video View
        self.playerView.contentMode = .scaleAspectFill
        self.playerView.player?.isMuted = true
        
        labelTitle.text = "Video: (Seçilmedi)"
        playerView.isHidden = true
    }
    
    func pullDataUser() {
        service.pullUserData(email: CacheUser.email) {
            self.labelCoinCount.text = "\($0.coin ?? 0)"
        }
    }

    func pullDataCoinCount() {
        NetworkManager.call(endpoint: "/api/coin-settings", method: .get, parameters: .init()) { [self] (result: Result<CoinSettingsModel, Error>) in
            switch result {
            case let .failure(error):
                print("Network request error: \(error)")
            case let .success(coinSettingsModel):
                coin = coinSettingsModel.first_coin ?? 0

                labelCoinInfo.text = "İlk video paylaşımı için video başına \(coinSettingsModel.first_coin ?? 0) coin, diğer videolar için ise video başına \(coinSettingsModel.coin ?? 0) coin bakiyenizden çıkılıcaktır"
            }
        }
    }

    override func dismissViewController() {
        dismiss(animated: true)
    }

    @objc func actionVideoView(sender:UIButton) {
        self.videoPicker = VideoPicker(presentationController: self, delegate: self)
        self.videoPicker.present(from: sender)
    }
    
    @objc func actionShareVideo() {
        if Int(labelCoinCount.text!) ?? 0 < coin {
            let alert = UIAlertController(title: "Uyarı", message: "Video paylaşmanız için yeterli Coin e sahib değilsiniz", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Coin Satın Al", style: .default, handler: { (_) in
                self.navigationController?.pushViewController(PurchaseCoinController(service: Services.sharedService), animated: true)
            }))

            alert.addAction(UIAlertAction(title: "İptal et", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            if let comment = textFieldVideoTitle.text, comment.isEmpty {
                makeAlert(title: "Uyarı", message: "Paylaşımınız için yorum yazınız lütfen")
            } else if let comment = textFieldVideoTitle.text, urlLocal != nil {
                loadingView.isHidden = false

                let parameters = ["email": CacheUser.email,
                                  "status": comment]

                AF.upload(multipartFormData: { multipartFormData in
                    for (key, value) in parameters {
                        multipartFormData.append(value.data(using: .utf8)!, withName: key)
                    }

                    if let URL = self.urlLocal {
                        print(URL)
                        multipartFormData.append(URL, withName: "file", fileName: "file", mimeType: "video/mp4")
                    }
                }, to: "\(NetworkManager.url)/api/upload-vid").response { [self] response in
                    print(response)
                    if response.response?.statusCode == 200 {
                        print("OK. Done")
                        loadingView.isHidden = true
                        dismiss(animated: true)
                    }
                }
            } else {
                loadingView.isHidden = true
                makeAlert(title: "Uyarı", message: "Video Seçilmedi")
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return allView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return view.frame.size.height
    }
}

extension ShareVideoController: VideoPickerDelegate {
    func didSelect(url: URL?) {
        guard let url = url else { return }

        urlLocal = url
        
        labelTitle.text = "Video"
        playerView.isHidden = false
        playerView.player = AVPlayer(url: url)
    }
}

