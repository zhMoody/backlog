//
//  SceneDelegate.swift
//  backlog
//
//  Created by 张浩 on 2025/4/30.
//
import RxSwift
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  let viewModel = GlobalViewModel()
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let sc = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: sc)
    let controller = TabBarController()
    window?.rootViewController = controller
    window?.makeKeyAndVisible()
  }

  func sceneDidDisconnect(_ scene: UIScene) {}

  func sceneDidBecomeActive(_ scene: UIScene) {}

  func sceneWillResignActive(_ scene: UIScene) {}

  func sceneWillEnterForeground(_ scene: UIScene) {}

  func sceneDidEnterBackground(_ scene: UIScene) {
    (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
  }
}
