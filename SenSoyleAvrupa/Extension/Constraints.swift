//
//  Constraints.swift
//  Fiind
//
//  Created by İlyas Abiyev on 5/31/20.
//  Copyright © 2020 İlyas Abiyev. All rights reserved.
//

import UIKit

struct AnchorConstraints {
    var top : NSLayoutConstraint?
    var bottom : NSLayoutConstraint?
    var trailing : NSLayoutConstraint?
    var leading : NSLayoutConstraint?
    var width : NSLayoutConstraint?
    var height : NSLayoutConstraint?
}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                leading: NSLayoutXAxisAnchor? = nil,
                trailing: NSLayoutXAxisAnchor? = nil,
                padding: UIEdgeInsets = .zero,
                size: CGSize = .zero) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchorConstraint = AnchorConstraints()
        
        if let top = top {
            anchorConstraint.top = topAnchor.constraint(equalTo: top, constant: padding.top)
        }
        
        if let bottom = bottom {
            anchorConstraint.bottom = bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom)
        }
        
        if let leading = leading {
            anchorConstraint.leading = leadingAnchor.constraint(equalTo: leading, constant: padding.left)
        }
        
        if let trailing = trailing {
            anchorConstraint.trailing = trailingAnchor.constraint(equalTo: trailing, constant: -padding.right)
        }
        
        if size.width != 0 {
            anchorConstraint.width = widthAnchor.constraint(equalToConstant: size.width)
        }
        
        if size.height != 0 {
            anchorConstraint.height = heightAnchor.constraint(equalToConstant: size.height)
        }
        
        [anchorConstraint.top,
         anchorConstraint.bottom,
         anchorConstraint.trailing,
         anchorConstraint.leading,
         anchorConstraint.width,
         anchorConstraint.height]
            .compactMap { $0 }
            .forEach { $0.isActive = true }
    }
    
    func addToSuperViewAnchors(padding: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let superViewTop = superview?.topAnchor {
            topAnchor.constraint(equalTo: superViewTop, constant: padding.top).isActive = true
        }
        
        if let superViewBottom = superview?.bottomAnchor {
            bottomAnchor.constraint(equalTo: superViewBottom, constant: -padding.bottom).isActive = true
            
        }
        
        if let superViewLeading = superview?.leadingAnchor {
            leadingAnchor.constraint(equalTo: superViewLeading, constant: padding.left).isActive = true
        }
        
        if let superViewTrailing = superview?.trailingAnchor {
            trailingAnchor.constraint(equalTo: superViewTrailing, constant: -padding.right).isActive = true
        }
    }
    
    func centerViewAtSuperView(size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false

        if let centerX = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: centerX).isActive = true
        }
        
        if let centerY = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }

        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
    }
    
    func centerY(_ anchor: NSLayoutXAxisAnchor) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: anchor).isActive = true
    }
    
    func centerX(_ anchor: NSLayoutYAxisAnchor) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: anchor).isActive = true
    }
    
    func centerXAtSuperView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let superViewCenterXanchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: superViewCenterXanchor).isActive = true
        }
    }
    
    func centerYAtSuperView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let superViewCenterYanchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: superViewCenterYanchor).isActive = true
        }
    }
    
    @discardableResult
    func constraintHeight(_ height: CGFloat) -> AnchorConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        var constraints = AnchorConstraints()
        
        constraints.height = heightAnchor.constraint(equalToConstant: height)
        constraints.height?.isActive = true
        return constraints
    }
    
    @discardableResult
    func constraintWidth(_ width: CGFloat) -> AnchorConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        var constraints = AnchorConstraints()
        
        constraints.width = heightAnchor.constraint(equalToConstant: width)
        constraints.width?.isActive = true
        return constraints
    }
    
    func addShadow(opacity: Float = 0, radius: CGFloat = 0, offset: CGSize = .zero, color: UIColor = .black) {
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
    }
    
    convenience init(backgroundColor: UIColor = .clear) {
        self.init(frame : .zero)
        self.backgroundColor = backgroundColor
    }
}

