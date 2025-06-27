import UIKit

private let defaultSize = CGSize(width: 18, height: 18)

class LeftClose: UIButton {
  init(iconColor: UIColor = .gray) {
    super.init(frame: .zero)
    setImage(
      UIImage(systemName: "xmark")?.withTintColor(iconColor, renderingMode: .alwaysOriginal),
      for: .normal
    )
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class LeftArrow: UIButton {
  init(title: String? = "", isReverse: Bool = false, iconColor: UIColor = .black, size: CGSize = defaultSize) {
    super.init(frame: .zero)
    if #available(iOS 17.0, *) {
      var config = UIButton.Configuration.tinted()
      config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
      config.title = title
      config.baseBackgroundColor = .clear
      config.baseForegroundColor = .black
      config.imagePadding = 14

      let attributedTitle = AttributedString(config.title ?? "", attributes: AttributeContainer([
        .font: UIFont.preferredFont(forTextStyle: .headline),
      ]))
      config.attributedTitle = attributedTitle

      config.image = UIImage(
        systemName: isReverse ? "chevron.right" : "chevron.left"
      )?.withTintColor(iconColor, renderingMode: .alwaysOriginal)

      self.configuration = config
    } else {
      // iOS 16 或更低版本的兼容处理（如使用 setImage + setTitle 等传统方式）
    }
  }
//
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
