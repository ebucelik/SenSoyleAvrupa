//
//  CustomLabel.swift
//  FuFi
//
//  Created by Ilyas Abiyev on 12.12.2020.
//

import UIKit

class CustomLabel : UILabel {
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.insetBy(dx: 15, dy: 0))
    }
}
