

import UIKit

public extension UIColor {
    
    convenience init(rgb: Int) {
        let blue = rgb & 0xFF
        let green = (rgb >> 8) & 0xFF
        let red = (rgb >> 16) & 0xFF
        self.init(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: 1.0
        )
    }
    
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        self.init(
            red: CGFloat(int >> 16) / 255,
            green: CGFloat(int >> 8 & 0xFF) / 255,
            blue: CGFloat(int & 0xFF) / 255,
            alpha: 1.0
        )
    }
    
    var hexString: String {
        let components = cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        
        let hexString = String.init(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )
        return hexString
    }
}
