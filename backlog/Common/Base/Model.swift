//
//  Model.swift
//  backlog
//
//  Created by 张浩 on 2025/4/30.
//
import Foundation
import Security
import UIKit

protocol viewModel {}

extension UserDefaults {
  enum Key: String {
    case home
    case setting
  }
  private static let homeKey = "home"
  private static let settingKey = "setting"
}

extension UIApplication {
  static var sceneDelegate: SceneDelegate? {
    UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
  }
}
