//
//  NoInternetController.swift
//  WebiView
//
//  Created by ilyas abiyev on 07.04.21.
//

import UIKit

import SwiftHelper

class NoInternetController: UIViewController {

    // MARK: Properties
    private let completion: (() -> Void)?

    // MARK: Views
    lazy var imageViewEmoji: UIImageView = {
        let img = UIImageView(image: #imageLiteral(resourceName: "logo"))
        img.widthAnchor.constraint(equalToConstant: view.frame.width / 2).isActive = true
        img.heightAnchor.constraint(equalToConstant: view.frame.width / 2).isActive = true
        img.clipsToBounds = false
        return img
    }()
    
    let labelOops: UILabel = {
       let lbl = UILabel()
        lbl.text = "Oops!"
        lbl.textColor = .customTintColor()
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 23, weight: .heavy)
        return lbl
    }()
    
    let labelNoInternet: UILabel = {
        let lbl = UILabel()
        lbl.text = "İnternet bağlantısı yok\nLütfen internet bağlantınızı kontrol edin"
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    
    lazy var buttonTryAgain: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Tekrar deneyin", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 17)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .customTintColor()
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 180).isActive = true
        btn.layer.cornerRadius = 25
        btn.addTarget(self, action: #selector(actionTryAgain), for: .touchUpInside)
        return btn
    }()

    init(completion: (() -> Void)?) {
        self.completion = completion

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        
        if CheckInternet.Connection() {
            dismiss(animated: true, completion: completion)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        editLayout()
    }
    
    func editLayout() {
        let stackView = UIStackView(arrangedSubviews: [labelOops, labelNoInternet])
        stackView.axis = .vertical
        stackView.spacing = 20
        
        view.backgroundColor = .white
        view.addSubview(imageViewEmoji)
        view.addSubview(stackView)
        view.addSubview(buttonTryAgain)

        imageViewEmoji.centerViewAtSuperView()

        stackView.anchor(
            top: imageViewEmoji.bottomAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            padding: .init(top: 20, left: 30, bottom: 0, right: 30)
        )
        
        buttonTryAgain.anchor(
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            padding: .init(top: 20, left: 85, bottom: 30, right: 85)
        )

        buttonTryAgain.centerXAtSuperView()
    }

    @objc func actionTryAgain() {
        if CheckInternet.Connection() {
            dismiss(animated: true, completion: completion)
        }
    }
}
