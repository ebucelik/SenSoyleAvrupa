//
//  CustomTextField.swift
//  FuFi
//
//  Created by Ilyas Abiyev on 12.12.2020.
//

import UIKit

class CustomTextField : UITextField {
    override var intrinsicContentSize: CGSize {
        return .init(width: 0, height: 45)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 25, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 25, dy: 0)
    }
}

class CustomTextView : UITextView  {
    
    override var intrinsicContentSize: CGSize {
        return .init(width: 0, height: 150)
    }
    
}

