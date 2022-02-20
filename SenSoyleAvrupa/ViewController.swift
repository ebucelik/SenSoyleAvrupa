//
//  ViewController.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 12.04.21.
//

import UIKit
import Cosmos

class ViewController: UIViewController {
    
    let lbl : UILabel = {
       let lbl = UILabel()
        lbl.text = "Text"
        return lbl
    }()

    let ratingView : CosmosView = {
        let cosmosView = CosmosView()
        //cosmosView.settings.updateOnTouch = false
        cosmosView.settings.fillMode = .full
        cosmosView.settings.starSize = 30
        cosmosView.settings.starMargin = 5
        cosmosView.settings.filledColor = UIColor.orange
        cosmosView.settings.emptyBorderColor = UIColor.orange
        cosmosView.settings.filledBorderColor = UIColor.orange
        cosmosView.settings.filledImage = UIImage(named: "GoldStarFilled")
        cosmosView.settings.emptyImage = UIImage(named: "GoldStarEmpty")
        cosmosView.rating = 0
        return cosmosView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = #colorLiteral(red: 0.3370708823, green: 0.3988061547, blue: 0.9292339683, alpha: 1)
        
       let stackView = UIStackView(arrangedSubviews: [lbl,ratingView])
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        stackView.anchor(top: nil, bottom: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor,padding: .init(top: 0, left: 20, bottom: 0, right: 20))
        stackView.merkezKonumlamdirmaSuperView()
        
        ratingView.didTouchCosmos = { Rating in
            self.lbl.text = String(Int(Rating))
        }
        
        ratingView.didFinishTouchingCosmos = { rating in }
    }


}

