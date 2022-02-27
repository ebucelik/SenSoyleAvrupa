//
//  RangeReplaceableCollection+Extension.swift
//  SenSoyleAvrupa
//
//  Created by Ing. Ebu Celik on 27.02.22.
//

import Foundation
import AVFoundation

extension RangeReplaceableCollection {
    mutating func appendIfNotContains(key: String, value: Element) {
        var tempKey: String = key

        forEach { _ = ($0 as? [String: AVPlayer])?.map {
            if $0.key == key {
                tempKey = ""
            }
        }}

        if !tempKey.isEmpty {
            append(value)
        }
    }
}
