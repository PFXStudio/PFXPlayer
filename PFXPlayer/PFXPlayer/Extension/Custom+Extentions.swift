//
//  UILabel+Extention.swift
//  PFXPlayer
//
//  Created by succorer on 02/02/2020.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    var isTruncated: Bool {
        guard let labelText = text else {
            return false
        }

        let labelTextSize = (labelText as NSString).boundingRect(
            with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil).size

        return labelTextSize.height > bounds.size.height
    }
}

extension TimeInterval {
    var minuteSecondString: String {
        return String(format:"02%d:%02d.%03d", minute, second, millisecond)
    }
    var minute: Int {
        return Int((self / 60).truncatingRemainder(dividingBy: 60))
    }
    var second: Int {
        return Int(truncatingRemainder(dividingBy: 60))
    }
    var millisecond: Int {
        return Int((self * 1000).truncatingRemainder(dividingBy: 1000))
    }
}

extension Int {
    var millisecondToString: String {
        let second = self / 1000
        let min = second / 60
        let sec = second % 60
        
        var minString = "\(min):"
        if min < 10 {
            minString = "0\(min):"
        }
        
        var secString = "\(sec)"
        if sec < 10 {
            secString = "0\(sec)"
        }
        
        return minString + secString
    }
}

extension String {
    var millisecond: Int {
        let times = self.components(separatedBy: ":")
        if times.count < 2 {
            return 0
        }
        
        var millisecond = 0
        let minutes = times[0]
        if let value = Int(minutes) {
            millisecond = value * 60 * 1000
        }
        
        let seconds = times[1]
        if let value = Int(seconds) {
            millisecond = millisecond + (value * 1000)
        }
        
        if times.count == 3 {
            let millisec = times[2]
            if let value = Int(millisec) {
                millisecond = millisecond + value
            }
        }
        
        return millisecond
    }
}
