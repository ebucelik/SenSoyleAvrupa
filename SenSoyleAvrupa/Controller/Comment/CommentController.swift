//
//  CommentController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 18.04.21.
//

import UIKit
import PanModal
import Alamofire

import SwiftHelper

class CommentController: UIViewController {

    // MARK: Properties
    var commentModel: CommentModel?
    var email = ""
    var videoid = 0
    private var modelDidChanged = false

    // MARK: Actions
    var onDismiss: ((Bool) -> Void)? = nil

    // MARK: Views
    let labelTitle: UILabel = {
        let lblComment = UILabel()
        lblComment.text = "Yorumlar"
        lblComment.font = .boldSystemFont(ofSize: 19)
        lblComment.textAlignment = .center
        return lblComment
    }()
    
    let tableView: UITableView = {
        let view = UITableView()
        return view
    }()
    
    let customTextField: CustomTextField = {
        let customTextField = CustomTextField()
        customTextField.textColor = .black
        customTextField.attributedPlaceholder = NSAttributedString(string: "Yorum yazin...",
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        return customTextField
    }()
    
    let buttonSend: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Gönder", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        return button
    }()
    
    let containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        return containerView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        editLayout()
        
        editTableView()
        
        pullData()
        
        editTxtandButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        guard let onDismiss = onDismiss else { return }

        onDismiss(modelDidChanged)
    }

    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    func editTxtandButton() {
        containerView.addSubview(buttonSend)
        containerView.addSubview(customTextField)

        buttonSend.addTarget(self, action: #selector(sendComment), for: .touchUpInside)

        buttonSend.anchor(top: containerView.topAnchor,
                          bottom: containerView.safeAreaLayoutGuide.bottomAnchor,
                          trailing: containerView.trailingAnchor,
                          padding: .init(horizontal: 15),
                          size: .init(width: 80, height: 80))

        customTextField.anchor(top: containerView.topAnchor,
                               bottom: containerView.safeAreaLayoutGuide.bottomAnchor,
                               leading: containerView.safeAreaLayoutGuide.leadingAnchor,
                               trailing: buttonSend.leadingAnchor)
    }

    func editLayout() {
        view.backgroundColor = .white
        tableView.backgroundColor = .white

        view.addSubview(labelTitle)
        view.addSubview(tableView)

        labelTitle.anchor(top: view.topAnchor,
                          leading: view.leadingAnchor,
                          trailing: view.trailingAnchor,
                          padding: .init(top: 20))

        tableView.anchor(top: labelTitle.bottomAnchor,
                         bottom: view.safeAreaLayoutGuide.bottomAnchor,
                         leading: view.leadingAnchor,
                         trailing: view.trailingAnchor,
                         padding: .init(bottom: 150))
    }
    
    func editTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorColor = .white
        tableView.register(UINib(nibName: "EmptyCell", bundle: nil), forCellReuseIdentifier: "EmptyCell")
        tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
    }

    func pullData() {
        let parameters: Parameters = ["video": videoid]

        NetworkManager.call(endpoint: "/api/comments", method: .get, parameters: parameters) { (result: Result<CommentModel, Error>) in
            switch result {
            case let .failure(error):
                print("Network request error: \(error)")

            case let .success(commentModel):
                self.commentModel = commentModel

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    @objc func sendComment() {
        let parameters: Parameters = ["email": email,
                                      "video": videoid,
                                      "comment": customTextField.text ?? ""]

        NetworkManager.call(endpoint: "/api/comment-vid", method: .post, parameters: parameters) { [self] (result: Result<SignUpModel, Error>) in
            switch result {
            case let .failure(error):
                print("Network request error: \(error)")

            case let .success(signUpModel):
                if let status = signUpModel.status, status {
                    customTextField.text = ""
                    pullData()
                    modelDidChanged = true

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    makeAlert(title: "Uyarı", message: "Yorum yaparken bir hata oldu")
                }
            }
        }
    }
}

extension CommentController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let commentModel = commentModel, let data = commentModel.data, !data.isEmpty {
            return data.count
        }

        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let commentModel = commentModel, let data = commentModel.data, !data.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
            let commentsModel = data[indexPath.row]

            cell.labelDate.text = "\(commentsModel.date?.replacingOccurrences(of: "-", with: ".") ?? "")"
            cell.labelComment.text = commentsModel.comment ?? ""

            // TODO: Talk with Murat regarding the correct user picture.
            /*if let pp = commentsModel.pp, pp != "\(NetworkManager.url)/public/pp" {
                cell.imageViewProfile.sd_setImage(with: URL(string: "\(NetworkManager.url)/public/pp/" + pp))
            }*/

            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell", for: indexPath) as! EmptyCell
        let tableViewFrame = CGRect(origin: .zero,
                                    size: CGSize(width: tableView.frame.width,
                                                 height: tableView.frame.height - tableView.safeAreaInsets.top - tableView.safeAreaInsets.bottom))
        cell.tableViewFrame = tableViewFrame
        return cell
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
        parameters.visiblePath = UIBezierPath(ovalIn: cell.viewComment.bounds)

        // Return a targeted preview using our cell previewView and parameters
        return UITargetedPreview(view: cell.viewComment, parameters: parameters)
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
