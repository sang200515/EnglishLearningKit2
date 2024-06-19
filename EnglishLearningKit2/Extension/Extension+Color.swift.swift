//
//  Extension+Color.swift.swift
//  EnglishLearningKit2
//
//  Created by Em bé cute on 6/13/24.
//

import Foundation
import SwiftUI

extension Color {
    init(hexString: String) {
        var formattedHexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if formattedHexString.hasPrefix("#") {
            formattedHexString.remove(at: formattedHexString.startIndex)
        }
        
        var rgb: UInt64 = 0
        Scanner(string: formattedHexString).scanHexInt64(&rgb)

        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
}
