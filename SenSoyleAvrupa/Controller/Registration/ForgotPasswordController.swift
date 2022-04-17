//
//  ForgotPasswordController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 13.04.21.
//

import UIKit

import SwiftHelper

class ForgotPasswordController: UITableViewController {

    // MARK: Views
    let allView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let loadingView = LoadingView()
    
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
    
    let labelTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "Parolanızı mı\nunuttunuz?"
        lbl.textColor = .customLabelColor()
        lbl.textAlignment = .left
        lbl.font = .systemFont(ofSize: 30, weight: .heavy)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    
    let labelEmail: UILabel = {
        let lbl = UILabel()
        lbl.text = "Mail adresiniz"
        lbl.textColor = .black
        lbl.font = .boldSystemFont(ofSize: 15)
        return lbl
    }()
    
    let textFieldEmail: UITextField = {
       let textField = CustomTextField()
        textField.backgroundColor = .customBackgroundColor()
        textField.placeholder = ""
        textField.layer.cornerRadius = 5
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.textColor = .black
        return textField
    }()
    
    let buttonForgotPassword : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Gönder", for: .normal)
        btn.backgroundColor = .customTintColor()
        btn.titleLabel?.tintColor = .white
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .heavy)
        btn.layer.cornerRadius = 15
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.addTarget(self, action: #selector(actionForgotPssword), for: .touchUpInside)
        return btn
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        
        checkInternetConnection(completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        editLayout()
        
        editTableView()
    }
    
    func editLayout() {
        tableView.backgroundColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [labelTitle,
                                                       labelEmail,
                                                       textFieldEmail,
                                                       buttonForgotPassword])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.setCustomSpacing(25, after: textFieldEmail)

        allView.addSubview(buttonDismiss)
        allView.addSubview(stackView)
        allView.addSubview(loadingView)

        buttonDismiss.anchor(top: allView.safeAreaLayoutGuide.topAnchor,
                             leading: allView.leadingAnchor,
                             padding: .init(top: 20, left: 20, bottom: 0, right: 0))

        stackView.anchor(top: buttonDismiss.bottomAnchor,
                         leading: allView.leadingAnchor,
                         trailing: allView.trailingAnchor,
                         padding: .init(all: 20))


        loadingView.addToSuperViewAnchors()
        loadingView.isHidden = true
    }

    func editTableView() {
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        tableView.allowsMultipleSelection = false
    }

    @objc func actionForgotPssword() {
        guard let url = URL(string: "https://sensoyleavrupa.com/login/yeni-sifre.php") else { return }
        let webViewController = WebViewController(url: url)
        present(webViewController, animated: true, completion: nil)
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
