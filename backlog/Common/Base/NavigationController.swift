import UIKit

class NavigationController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
  var leftArrow: LeftArrow

  override init(rootViewController: UIViewController) {
    self.leftArrow = LeftArrow(title: "")
    super.init(rootViewController: rootViewController)
    leftArrow.ex.click = { [unowned self] in
      popViewController(animated: true)
    }
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    interactivePopGestureRecognizer?.delegate = self
    delegate = self
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

  func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
    interactivePopGestureRecognizer?.isEnabled = true
    if navigationController.viewControllers.count == 1 {
      interactivePopGestureRecognizer?.isEnabled = false
    }
  }

  override func pushViewController(_ viewController: UIViewController, animated: Bool) {
    if !viewControllers.isEmpty {
      let leftButton = UIBarButtonItem(customView: leftArrow)
      viewController.navigationItem.leftBarButtonItem = leftButton
      viewController.hidesBottomBarWhenPushed = true
    }
    super.pushViewController(viewController, animated: animated)
  }
}

class AuthNavigationController: NavigationController {
  var coordinator: (any AuthCoordinatorProtocol)?

  override init(rootViewController: UIViewController) {
    super.init(rootViewController: rootViewController)
    self.leftArrow = LeftArrow(title: "返回")
    leftArrow.ex.click = { [unowned self] in
      popViewController(animated: true)
    }
  }

  @available(*, unavailable)
  @MainActor required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class ModalNavigationController<T>: NavigationController {
  var coordinator: T?

  override init(rootViewController: UIViewController) {
    super.init(rootViewController: rootViewController)
    self.leftArrow = LeftArrow(title: "返回")
    leftArrow.ex.click = { [unowned self] in
      popViewController(animated: true)
    }
  }

  @available(*, unavailable)
  @MainActor required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class NormalNavigationController<T>: NavigationController {
  var coordinator: T?
}
