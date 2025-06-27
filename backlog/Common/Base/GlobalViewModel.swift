//
//  GlobalViewModel.swift
//  backlog
//
//  Created by 张浩 on 2025/4/30.
//

import Foundation
import RxRelay

class GlobalViewModel: viewModel {
  var stportType: BehaviorRelay<String> = BehaviorRelay(value: "")
  var startAt: BehaviorRelay<Date> = BehaviorRelay(value: Date())
  var endAt: BehaviorRelay<Date> = BehaviorRelay(value: Date())
  var distance: BehaviorRelay<Double> = BehaviorRelay(value: 0.0)
  var avgPace: BehaviorRelay<Double> = BehaviorRelay(value: 0.0)
}
