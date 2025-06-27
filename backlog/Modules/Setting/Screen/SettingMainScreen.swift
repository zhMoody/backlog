//
//  SettingMainScreen.swift
//  backlog
//
//  Created by 张浩 on 2025/4/30.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class SettingMainScreen: SettingViewController<SettingViewModel> {
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    setup()
    bindData()
  }

  func setup() {
    view.addSubview(box)
    box.addSubview(text)
    box.backgroundColor = .green
    box.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(100)
    }
    text.font = .systemFont(ofSize: 20)
    text.snp.makeConstraints {
      $0.top.equalToSuperview().offset(20)
      $0.bottom.leading.trailing.equalToSuperview()
    }
  }
  let box = UIView()
  let text = UILabel()
}

extension SettingMainScreen {
  func bindData() {
    let a = BehaviorRelay<Int>(value: 100)
    a.map { v in v.description }
      .bind(to: text.rx.text)
      .disposed(by: bag)
  }
}
