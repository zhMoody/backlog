//
//  HomeMainView.swift
//  backlog
//
//  Created by 张浩 on 2025/4/30.
//

import QMapKit
import UIKit

class HomeMainView: UIStackView {
  @available(*, unavailable)
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    axis = .vertical
    spacing = 16
    setup()
  }

  func setup() {
    spacing = 16
    addArrangedSubview(b1)
    addArrangedSubview(bottomSheetView)
//    addArrangedSubview(nowLocal)
//    addArrangedSubview(nowState)
//    addArrangedSubview(presetSelector)
//    addArrangedSubview(stackView)
//    addArrangedSubview(countdownView)
    [nowLocal,nowState,presetSelector,stackView,countdownView].forEach(bottomSheetView.addSubview)

    // 地图容器样式
    b1.backgroundColor = .gray
    b1.clipsToBounds = true
    b1.addSubview(mapView)

    b1.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(500)
    }
    mapView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    mapView.showsUserLocation = true
    mapView.userTrackingMode = .follow
    mapView.isOverlookingEnabled = false
    mapView.setLogoScale(0.7)
    
    
    bottomSheetView.attach(to: self)
    presetSelector.selectedSegmentIndex = 10
    presetSelector.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.height.equalTo(30)
    }
    nowLocal.text = "- \n-"
    nowLocal.numberOfLines = 2
    nowLocal.textAlignment = .center
    nowLocal.font = .systemFont(ofSize: 16)
    nowLocal.snp.makeConstraints {
      $0.top.equalTo(presetSelector.snp.bottom)
      $0.height.equalTo(50)
    }

    nowState.text = "当前状态：未开始记录"
    nowState.textAlignment = .center
    nowState.font = .systemFont(ofSize: 16)
    nowState.snp.makeConstraints {
      $0.top.equalTo(nowLocal.snp.bottom)
      $0.height.equalTo(40)
    }

    // 按钮布局优化
    stackView.axis = .horizontal
    stackView.spacing = 12
    stackView.distribution = .fillEqually
    stackView.snp.makeConstraints {
      $0.top.equalTo(nowState.snp.bottom)
      $0.width.equalToSuperview()
      $0.height.equalTo(44)
    }

    for item in [button, stopBtn, endButton] {
      item.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
      item.layer.cornerRadius = 8
      item.backgroundColor = UIColor(hex: 0xB983F9)
      item.setTitleColor(.white, for: .normal)
    }

    button.setTitle("开始", for: .normal)
    stopBtn.setTitle("暂停", for: .normal)
    endButton.setTitle("结束", for: .normal)

    stackView.addArrangedSubview(button)
    stackView.addArrangedSubview(stopBtn)
    stackView.addArrangedSubview(endButton)
    countdownView.snp.makeConstraints {
      $0.top.equalTo(stackView.snp.bottom)
      $0.height.equalTo(40)
    }
  }

  lazy var b1 = UIView()
  lazy var mapView = QMapView(frame: self.bounds)
  lazy var nowLocal = UILabel()
  lazy var stackView = UIStackView()
  lazy var button = UIButton(type: .system)
  lazy var stopBtn = UIButton(type: .system)
  lazy var endButton = UIButton(type: .system)
  lazy var nowState = UILabel()
  lazy var countdownView = CountdownView()
  lazy var presetSelector = UISegmentedControl(items: ["10", "20", "30", "100", "1000", "10000"])
  lazy var bottomSheetView = BottomSheetView()
}
