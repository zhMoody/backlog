//
//  UI+Color.swift
//  backlog
//
//  Created by 张浩 on 2025/6/9.
//
import UIKit

extension UIColor {
  convenience init(hex: UInt, alpha: CGFloat = 1.0) {
    let red = CGFloat((hex >> 16) & 0xFF) / 255.0
    let green = CGFloat((hex >> 8) & 0xFF) / 255.0
    let blue = CGFloat(hex & 0xFF) / 255.0
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}
