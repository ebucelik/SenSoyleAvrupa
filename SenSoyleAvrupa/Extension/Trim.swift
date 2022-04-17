//
//  Trim.swift
//  Avukapp
//
//  Created by Ilyas Abiyev on 10/5/20.
//

import UIKit

extension String
{
    func trim() -> String
    {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}
