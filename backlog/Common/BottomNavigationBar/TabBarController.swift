//
//  TabBarController.swift
//  backlog
//
//  Created by 张浩 on 2025/4/30.
//
import UIKit

class TabBarController: UITabBarController {
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
}

extension TabBarController {
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    .portrait
  }

  func setup() {
    let homeVC = HomeMainScreen()
    homeVC.viewModel = HomeViewModel()

    let statisticsVC = StatisticsMainScreen()
    statisticsVC.viewModel = StatisticsViewModel()

    let settingsVC = SettingMainScreen()
    settingsVC.viewModel = SettingViewModel()

    homeVC.tabBarItem = UITabBarItem(title: .none, image: UIImage(systemName: "house"), tag: 0)
    statisticsVC.tabBarItem = UITabBarItem(title: .none, image: UIImage(systemName: "chart.bar"), tag: 1)
    settingsVC.tabBarItem = UITabBarItem(title: .none, image: UIImage(systemName: "gear"), tag: 2)

    let appearance = UITabBarAppearance()
    appearance.backgroundColor = .white
    appearance.backgroundEffect = .none
    tabBar.isTranslucent = false
    if #available(iOS 17.0, *) {
      tabBar.scrollEdgeAppearance = appearance
    }
    tabBar.standardAppearance = appearance
    viewControllers = [homeVC, statisticsVC, settingsVC]
  }
}
