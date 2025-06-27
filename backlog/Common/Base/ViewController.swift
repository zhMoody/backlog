//
//  ViewController.swift
//  backlog
//
//  Created by 张浩 on 2025/4/30.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class ViewController<VM: viewModel, C>: UIViewController {
  let bag = DisposeBag()
  var viewModel: VM!
  var coordinator: C { (navigationController as! NormalNavigationController).coordinator! }
  lazy var global = (UIApplication.sceneDelegate)!.viewModel

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if navigationController?.isNavigationBarHidden == true {
      navigationController?.isNavigationBarHidden = false
    }
  }
}

class HomeViewController<VM: viewModel>: ViewController<VM, HomeCoordinatorProtocol> {}
class StatisticsViewController<VM: viewModel>: ViewController<VM, HomeCoordinatorProtocol> {}
class SettingViewController<VM: viewModel>: ViewController<VM, SettingCoordinatorProtocol> {}
