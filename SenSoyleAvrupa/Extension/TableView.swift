//
//  TableView.swift
//  SenSoyleAvrupa
//
//  Created by ilyas abiyev on 30.04.21.
//

import UIKit

extension UITableView {
    func scrollToNextItem() {
        let contentOffset = CGFloat(floor(self.contentOffset.x + self.bounds.size.width))
        self.moveToFrame(contentOffset: contentOffset)
    }
    func moveToFrame(contentOffset : CGFloat) {
            self.setContentOffset(CGPoint(x: contentOffset, y: self.contentOffset.y), animated: true)
        }
}
