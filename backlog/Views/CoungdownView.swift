//
//  CoungdownView.swift
//  backlog
//
//  Created by 张浩 on 2025/6/9.
//

import SnapKit
import UIKit

/// 倒计时视图，支持开始、暂停、恢复、取消操作。
class CountdownView: UIView {
  public let label = UILabel()
  private var timer: Timer?
  private var remaining: Int = 0
  private var completion: (() -> Void)?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// 开始倒计时
  /// - Parameters:
  ///   - seconds: 倒计时总秒数
  ///   - onComplete: 倒计时结束回调
  public func start(seconds: Int, onComplete: @escaping () -> Void) {
    timer?.invalidate()
    remaining = seconds
    completion = onComplete
    updateLabel()
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      self?.tick()
    }
  }

  /// 暂停倒计时（保留剩余时间）
  public func pause() {
    timer?.invalidate()
  }

  /// 继续倒计时（从上次剩余时间继续）
  public func resume() {
    guard remaining > 0 else { return }
    start(seconds: remaining, onComplete: completion ?? {})
  }

  /// 取消倒计时
  public func cancel() {
    timer?.invalidate()
    remaining = 0
    label.text = "时间：00:00:00"
  }

  /// 当前倒计时是否激活
  public var isActive: Bool {
    timer != nil
  }

  // MARK: - Private

  private func setupView() {
    label.font = .monospacedDigitSystemFont(ofSize: 20, weight: .medium)
    label.textAlignment = .center
    label.textColor = .systemRed
    label.text = "时间：00:00:00"
    addSubview(label)
    label.snp.makeConstraints { $0.edges.equalToSuperview() }
  }

  private func tick() {
    remaining -= 1
    updateLabel()
    if remaining <= 0 {
      timer?.invalidate()
      label.text = "时间到！"
      completion?()
    }
  }

  private func updateLabel() {
    let hours = remaining / 3600
    let minutes = (remaining % 3600) / 60
    let seconds = remaining % 60
    label.text = String(format: "倒计时：%02d:%02d:%02d", hours, minutes, seconds)
  }
}
