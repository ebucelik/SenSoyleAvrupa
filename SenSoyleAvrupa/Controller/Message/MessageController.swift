//
//  MessageController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 22.04.21.
//

import UIKit
import Alamofire

class MessageController: UITableViewController {

    // MARK: Properties
    var messageModels = [MessageModel]()

    // MARK: Views
    private var pullControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        pullData()

        tableView.backgroundColor = .white
        tableView.register(UINib(nibName: "EmptyCell", bundle: nil), forCellReuseIdentifier: "EmptyCell")
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        tableView.separatorColor = .clear
        tableView.backgroundColor = .customBackground()
        
        pullControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(pullControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        pullData()
        pullControl.endRefreshing()
    }

    func pullData() {
        let parameters: Parameters = ["email": CacheUser.email]

        NetworkManager.call(endpoint: "/api/messages", method: .post, parameters: parameters) { (result: Result<MessagesModel, Error>) in
            switch result {
            case let .failure(error):
                print("Network request error: \(error)")

            case let .success(messagesModel):
                if let messages = messagesModel.data {
                    self.messageModels = messages
                }

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = "Adminden Gelen Mesajlar"
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Geri", style: .plain, target: self, action: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageModels.isEmpty ? 1 : messageModels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if messageModels.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell") as! EmptyCell
            let tableViewFrame = CGRect(origin: .zero,
                                        size: CGSize(width: tableView.frame.width,
                                                     height: (tableView.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)))
            cell.tableViewFrame = tableViewFrame
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        cell.labelMessage.text = messageModels[indexPath.row].message
        return cell
    }
}
