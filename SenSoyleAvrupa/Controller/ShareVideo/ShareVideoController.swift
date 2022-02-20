//
//  ShareController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 17.04.21.
//

import UIKit
import Alamofire

class ShareVideoController: UITableViewController {
    
    var videoPicker: VideoPicker!
    
    let btnLeft : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        btn.tintColor = .customTintColor()
        btn.heightAnchor.constraint(equalToConstant: 36).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 36).isActive = true
        btn.addTarget(self, action: #selector(actionLeft), for: .touchUpInside)
        btn.layer.cornerRadius = 18
        btn.backgroundColor = .customBackgorundButton()
        return btn
    }()
    
     let allView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let lblMyCoin : UILabel = {
        let lbl = UILabel()
        lbl.font = .boldSystemFont(ofSize: 15)
        lbl.textAlignment = .left
        lbl.text = "Coin Bakiyeniz:"
        lbl.textColor = .black
        return lbl
    }()
    
    let lblMyCoinCount : UILabel = {
        let lbl = UILabel()
        lbl.text = ""
        lbl.textColor = .customTintColor()
        lbl.font = .systemFont(ofSize: 30, weight: .heavy)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    let lblVideoCoinCount : UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.textColor = .gray
        lbl.font = .systemFont(ofSize: 12)
        return lbl
    }()
    
    let lblVideo : UILabel = {
        let lbl = UILabel()
        lbl.text = "Video"
        lbl.textColor = .black
        lbl.font = .boldSystemFont(ofSize: 15)
        return lbl
    }()
    
      let videoView : VideoView = {
       let view = VideoView()
        view.backgroundColor = .customBackgorundButton()
        view.layer.cornerRadius = 10
        view.heightAnchor.constraint(equalToConstant: 200).isActive = true
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let lblComment : UILabel = {
        let lbl = UILabel()
        lbl.text = "Yorumunuz"
        lbl.textColor = .black
        lbl.font = .boldSystemFont(ofSize: 15)
        return lbl
    }()

    let txtComment : CustomTextField = {
       let view = CustomTextField()
        view.backgroundColor = .customBackgorundButton()
        view.layer.cornerRadius = 5
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        view.placeholder = "Video ile ilgili bir yorum yaz"
        view.textColor = .black
        return view
    }()
    
    let btnVideoView : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("  Video seç", for: .normal)
        //btn.setImage(UIImage(systemName: "video.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.customTintColor()), for: .normal)
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
    
    let btnShareVideo : UIButton = {
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
    
    var controlVideo = "0"
    
    var urlLocal : URL?
    
    
    var coin = 0
    
    let loadingView = LoadingView()
    
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
        
        let btnStackView = UIStackView(arrangedSubviews: [btnVideoView,btnShareVideo])
        btnStackView.axis = .horizontal
        btnStackView.spacing = 15
        btnStackView.distribution = .fillEqually
        
        let stackView = UIStackView(arrangedSubviews: [lblMyCoin,lblMyCoinCount,lblVideoCoinCount,lblComment,txtComment,lblVideo,videoView,btnStackView])
        stackView.axis = .vertical
        stackView.spacing = 10
        
        allView.addSubview(btnLeft)
        
        
        allView.addSubview(stackView)
        
        
        btnLeft.anchor(top: allView.topAnchor, bottom: nil, leading: allView.leadingAnchor, trailing: nil,padding: .init(top: 20, left: 20, bottom: 0, right: 0))
        
        stackView.anchor(top: btnLeft.bottomAnchor, bottom: nil, leading: allView.leadingAnchor, trailing: allView.trailingAnchor,padding: .init(top: 20, left: 20, bottom: 0, right: 20))
        
        let gestureVideoView = UITapGestureRecognizer(target: self, action: #selector(actionVideoViewPlayPause))
        videoView.addGestureRecognizer(gestureVideoView)
        
        allView.addSubview(loadingView)
        loadingView.addToSuperViewAnchors()
        loadingView.isHidden = true
    }
    
    
    func editTableView() {
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        tableView.allowsMultipleSelection = false
        
        //Video View
        self.videoView.contentMode = .scaleAspectFill
        self.videoView.player?.isMuted = true
        self.videoView.repeat = .loop
        
        lblVideo.text = "Video: (Seçilmedi)"
        videoView.isHidden = true
    }
    
    func pullDataUser() {
        let parameters : Parameters = ["email":CacheUser.email]
        
        AF.request("\(NetworkManager.url)/api/user",method: .get,parameters: parameters).responseJSON { [self] response in
            
            print("response: \(response)")
            
            if let data = response.data {
                do {
                    let answer = try JSONDecoder().decode(User.self, from: data)
                    
                    lblMyCoinCount.text = "\(answer.coin ?? 0)"
                  
                }catch{
                    print("Error Localized Description \(error.localizedDescription)")
                }
            }
            
        }
    }
    
    func pullDataCoinCount() {
        
        AF.request("\(NetworkManager.url)/api/coin-settings",method: .get).responseJSON { [self] response in
            
            print("response: \(response)")
            
            if let data = response.data {
                do {
                    let answer = try JSONDecoder().decode(CointCount.self, from: data)
                    
                    coin = answer.first_coin ?? 0
                    
                    lblVideoCoinCount.text = "İlk video paylaşımı için video başına \(answer.first_coin ?? 0) coin,diğer videolar için ise video başına \(answer.coin ?? 0) coin bakiyenizden çıkılıcaktır"
                }catch{
                    print("Error Localized Description \(error.localizedDescription)")
                }
            }
            
        }
    }
    
    @objc func actionVideoView(sender:UIButton) {
        print("123")
        self.videoPicker = VideoPicker(presentationController: self, delegate: self)
        self.videoPicker.present(from: sender)
    }
    
    @objc func actionShareVideo() {
        print(coin)
        if Int(lblMyCoinCount.text!) ?? 0 < coin {
            let alert = UIAlertController(title: "Uyarı", message: "Video paylaşmanız için yeterli Coin e sahib değilsiniz", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Coin Satın Al", style: .default, handler: { (_) in
                self.navigationController?.pushViewController(PurchaseCoinController(), animated: true)
            }))
            alert.addAction(UIAlertAction(title: "İptal et", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }else{
        
        if txtComment.text == "" {
            makeAlert(tittle: "Uyarı", message: "Paylaşımınız için yorum yazınız lütfen")
            return
        }
        if urlLocal  != nil   {
            
            loadingView.isHidden = false
            
            let parameters = ["email" : CacheUser.email,
                              "status" : txtComment.text!
            ]

            AF.upload(multipartFormData: { multipartFormData in

                for (key, value) in parameters {
                    multipartFormData.append(value.data(using: .utf8)!, withName: key)
                }

                if let URL = self.urlLocal {
                    print(URL)
                    multipartFormData.append(URL, withName: "file", fileName: "file", mimeType: "video/mp4")
                }
            }, to: "\(NetworkManager.url)/api/upload-vid")
            .response { [self] response in
                print(response)
                if response.response?.statusCode == 200 {
                    print("OK. Done")
                    loadingView.isHidden = true
                    let vc = CustomTabbar()
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            }
            return
        }else{
            loadingView.isHidden = true
            makeAlert(tittle: "Uyarı", message: "Video Seçilmedi")
            return
        }
        }
    }
    
    @objc func actionVideoViewPlayPause() {
        
    }
    
    @objc func actionLeft() {
        dismiss(animated: true, completion: nil)
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
        guard let url = url else {
            return
        }
        print("URL- \(url)")
        
        urlLocal = url
        
        lblVideo.text = "Video"
        videoView.isHidden = false
        self.videoView.url = url
        //self.videoView.player?.play()
    }
}

