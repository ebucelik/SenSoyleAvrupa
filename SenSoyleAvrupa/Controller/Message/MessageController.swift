//
//  MessageController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 22.04.21.
//

import UIKit
import Alamofire

class MessageController: UITableViewController {
    
    private var pullControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pullData()

        tableView.backgroundColor = .white
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
    
    var arrayCollectionView = [Message]()
    func pullData() {
        let parameters : Parameters = ["email":CacheUser.email]
        
        AF.request("\(NetworkManager.url)/api/messages",method: .get,parameters: parameters).responseString { [self] response in
            
            print("response: \(response)")
            
            if let data = response.data {
                do {
                    let answer = try JSONDecoder().decode(ArrayMessage.self, from: data)
                    
                    if let comeArray = answer.data {
                        self.arrayCollectionView = comeArray
                    }
                    print("arrayCollectionView\(self.arrayCollectionView)")
                    DispatchQueue.main.async { [self] in
                        self.tableView.reloadData()
                    }
                    
                    
                }catch{
                    print("Error Localized Description \(error.localizedDescription)")
                }
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = "Adminden Gelen Mesajlar"
        navigationController?.navigationBar.isHidden = false
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayCollectionView.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        cell.lblMessage.text = arrayCollectionView[indexPath.row].message
        return cell
    }
    
   

}
