import UIKit

public struct UIKitEx<T> {
  public let t: T
  public init(_ t: T) {
    self.t = t
  }
}

public protocol UIKitExCompatible {
  associatedtype E
  static var ex: UIKitEx<E>.Type { get set }
  var ex: UIKitEx<E> { get set }
}

public extension UIKitExCompatible {
  static var ex: UIKitEx<Self>.Type {
    get { UIKitEx<Self>.self }
    set {}
  }
  var ex: UIKitEx<Self> {
    get { UIKitEx(self) }
    set {}
  }
}

extension UIScreen: UIKitExCompatible {}
extension UIView: UIKitExCompatible {}
extension UIImage: UIKitExCompatible {}
extension UIEdgeInsets: UIKitExCompatible {}

private var btnHandle = 10000
extension UIKitEx where T: UIButton {
  var click: (() -> Void)? {
    set {
      objc_setAssociatedObject(self, &btnHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      if let closure = newValue {
//        t.addAction(UIAction { _ in closure() }, for: .touchUpInside)
      }
    }
    get {
      objc_getAssociatedObject(self, &btnHandle) as? () -> Void
    }
  }
}

extension UIKitEx where T: UIScrollView {
  func scroll(to i: Int, animated: Bool = true) {
    let xOffset = CGFloat(i) * t.frame.width
    t.setContentOffset(CGPoint(x: xOffset, y: 0), animated: animated)
  }
}

extension UIKitEx where T: UIImage {
  var base64: String? {
    if let data = t.jpegData(compressionQuality: 1) {
      data.base64EncodedString()
    } else {
      .none
    }
  }
}

extension UIKitEx where T == UIEdgeInsets {
  func copy(
    top: CGFloat? = .none,
    left: CGFloat? = .none,
    bottom: CGFloat? = .none,
    right: CGFloat? = .none
  ) -> UIEdgeInsets {
    UIEdgeInsets(
      top: top ?? t.top,
      left: left ?? t.left,
      bottom: bottom ?? t.bottom,
      right: right ?? t.right
    )
  }
}

extension UIView {
  func toImage() -> UIImage? {
    let renderer = UIGraphicsImageRenderer(bounds: bounds)
    return renderer.image { context in
      layer.render(in: context.cgContext)
    }
  }
}
