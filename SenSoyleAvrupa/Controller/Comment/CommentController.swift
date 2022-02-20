//
//  CommentController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 18.04.21.
//

import UIKit
import PanModal
import Alamofire

class CommentController: UIViewController {
    
    let topView : UIView = {
       let view = UIView()
        let lblComment = UILabel()
        lblComment.text = "Yorumlar"
        lblComment.font = .boldSystemFont(ofSize: 19)
        view.addSubview(lblComment)
        lblComment.centerViewAtSuperView()
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    let tableView : UITableView = {
        let view = UITableView()
        return view
    }()
    
    var email = ""
    var videoid = 0
    
    let txtYorum = CustomTextField()
    
    let btnYorumGonder = UIButton(type: .system)
    
    let containerView : UIView = {
            let containerView = UIView()
            containerView.backgroundColor = .white
            containerView.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
            return containerView
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editLayot()
        
        editTableView()
        
        pullData()
        
        editTxtandButton()
    
    }
    
    func editTxtandButton() {
        
        containerView.addSubview(btnYorumGonder)
        containerView.addSubview(txtYorum)
        
        btnYorumGonder.setTitle("Gönder", for: .normal)
        btnYorumGonder.setTitleColor(.black, for: .normal)
        btnYorumGonder.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        btnYorumGonder.addTarget(self, action: #selector(actionGonder), for: .touchUpInside)
        
        
        btnYorumGonder.anchor(top: containerView.safeAreaLayoutGuide.topAnchor, bottom: containerView.safeAreaLayoutGuide.bottomAnchor, leading: nil, trailing: containerView.trailingAnchor,padding: .init(top: 0, left: 15, bottom: 0, right: 15),size: .init(width: 80, height: 80))
        
        
        txtYorum.textColor = .black
        txtYorum.attributedPlaceholder = NSAttributedString(string: "Yorumunuzu Girin...",
                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        txtYorum.anchor(top: containerView.safeAreaLayoutGuide.topAnchor, bottom: containerView.bottomAnchor, leading: containerView.safeAreaLayoutGuide.leadingAnchor, trailing: btnYorumGonder.leadingAnchor)
    }
   
    
    func editLayot() {
        view.backgroundColor = .white
        
        tableView.backgroundColor = .white
        
        view.addSubview(topView)
        
        view.addSubview(tableView)
        
        topView.anchor(top: view.topAnchor, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor,padding: .init(top: 0, left: 0, bottom: 0, right: 0))
        
        tableView.anchor(top: topView.bottomAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor,padding: .init(top: 0, left: 0, bottom: 150, right: 0))
    }
    
    func editTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorColor = .white
        tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @objc func actionGonder() {
        saveData()
       }
    
    func saveData() {
        let parameters : Parameters = ["email": email,
                                       "video": videoid,
                                       "comment": txtYorum.text ?? ""]
        
        AF.request("\(NetworkManager.url)/api/comment-vid", method: .post,parameters: parameters,encoding: URLEncoding.default)
            .responseJSON { [self] response in
                print("response comment \(response)")
                if let data = response.data {
                    do {
                        let answer = try JSONDecoder().decode(SignUp.self, from: data)
                        
                        if answer.status == true {
                            txtYorum.text = ""
                            pullData()
                        }else{
                            makeAlert(tittle: "Uyarı", message: "Yorum yaparken bir hata oldu")
                        }
                     
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }catch{
                        print("ErrrorJson \(error.localizedDescription)")
                    }
                    
                }
                
            }
    }
    
    var arrayCollectionView = [NSDictionary]()
    
    var commentArray = [String]()
    func pullData() {
        let parameters : Parameters = ["video":videoid]
        
        AF.request("\(NetworkManager.url)/api/comments", method: .get,parameters: parameters,encoding: URLEncoding.default)
            .responseJSON { [self] response in
                print("response comment \(response)")

                if let data = response.data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                            if let users = json["data"] as? [[String:Any]] {
                                
                                commentArray.removeAll(keepingCapacity: false)
                                for a in users {
                                    commentArray.append(a["comment"] as! String)
                                }
                                
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                         
                            }
                        }
                      
                    }catch{
                        print("error.localizedDescription\(error.localizedDescription)")
                    }
                }
                
            }
        
    }
    
    
}

extension CommentController : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
       let arrayIndex =  commentArray[indexPath.row]
        print(arrayIndex)
        cell.lblComment.text = arrayIndex
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("123")
    }
    @available(iOS 13.0, *)
     func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }


    @available(iOS 13.0, *)
     func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }

    @available(iOS 13.0, *)
    private func makeTargetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        // Get the cell for the index of the model
        guard let cell = tableView.cellForRow(at: indexPath) as? CommentCell else { return nil }
        // Set parameters to a circular mask and clear background
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        parameters.visiblePath = UIBezierPath(ovalIn: cell.commentView.bounds)

        // Return a targeted preview using our cell previewView and parameters
        return UITargetedPreview(view: cell.commentView, parameters: parameters)
    }
}

extension CommentController: PanModalPresentable {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(100)
    }
    
    var anchorModalToLongForm: Bool {
        return false
    }
}
