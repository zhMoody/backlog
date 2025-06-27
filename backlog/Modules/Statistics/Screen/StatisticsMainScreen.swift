//
//  StatisticsMainScreen.swift
//  backlog
//
//  Created by 张浩 on 2025/4/30.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class StatisticsMainScreen: StatisticsViewController<StatisticsViewModel> {
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    setup()
    bindData()
  }

  func setup() {
    view.addSubview(box)
    [text, text2, text3, text4, text5].forEach(box.addArrangedSubview)

    box.axis = .vertical
    box.spacing = 20
    box.alignment = .center
    box.distribution = .fillEqually
    box.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(500)
    }

    text.font = .systemFont(ofSize: 20)
    text2.font = .systemFont(ofSize: 20)
    text3.font = .systemFont(ofSize: 20)
    text4.font = .systemFont(ofSize: 20)
    text5.font = .systemFont(ofSize: 20)
  }
  let box = UIStackView()
  let text = UILabel()
  let text2 = UILabel()
  let text3 = UILabel()
  let text4 = UILabel()
  let text5 = UILabel()
}

extension StatisticsMainScreen {
  func bindData() {
    global.stportType.bind(to: text.rx.text).disposed(by: bag)
    global.startAt.map { "开始时间" + $0.ex.stringify("yyyy.MM.dd HH:mm:ss") }.bind(to: text2.rx.text).disposed(by: bag)
    global.endAt.map { "结束时间" + $0.ex.stringify("yyyy.MM.dd HH:mm:ss") }.bind(to: text3.rx.text).disposed(by: bag)
    global.distance.map { "运动距离" + $0.description }.bind(to: text4.rx.text).disposed(by: bag)
    global.avgPace.map { "平均配速" + $0.description }.bind(to: text5.rx.text).disposed(by: bag)
  }
}
