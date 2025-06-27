//
//  HomeMainScreen.swift
//  backlog
//
//  Created by 张浩 on 2025/4/30.
//

import CoreLocation
import Foundation
import QMapKit
import RxCocoa
import RxSwift
import SnapKit
import UIKit
import ActivityKit

class HomeMainScreen: HomeViewController<HomeViewModel> {
  var activity: Activity<SportTimerAttributes>?
  let locationManager = CLLocationManager()
  var routeCoordinates: [CLLocationCoordinate2D] = []
  var routePolyline: QPolyline?
  var hasCenteredMap = false
  var startPointCircle: QCircle?
  // 轨迹统计相关
  var totalDistance: Double = 0
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bindData()
    bindScrollEffect()

  }

  func setup() {
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)

    scrollView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    contentView.snp.makeConstraints {
      $0.top.leading.trailing.bottom.equalToSuperview()
      $0.width.equalTo(scrollView)
    }
    contentView.mapView.delegate = self
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.allowsBackgroundLocationUpdates = true
    locationManager.pausesLocationUpdatesAutomatically = false
  }

  let contentView = HomeMainView()
  let scrollView = UIScrollView()
  var isCheck = false
}

extension HomeMainScreen {
  func bindData() {
    // "开始"
    contentView.button.rx.tap
      .subscribe(onNext: { [unowned self] in
        let selectedIndex = contentView.presetSelector.selectedSegmentIndex
        guard selectedIndex != UISegmentedControl.noSegment,
              let selectedTitle = contentView.presetSelector.titleForSegment(at: selectedIndex),
              let seconds = Int(selectedTitle) else {
          return
        }
        let str = "当前状态：▶️ 已开启实时定位"
        isCheck = true
        contentView.button.isEnabled = false
        contentView.button.backgroundColor = .gray
        routeCoordinates.removeAll()
        hasCenteredMap = false
        totalDistance = 0
        contentView.nowState.text = str
        global.stportType.accept(str)
        global.startAt.accept(.now)

        global.endAt.accept(.now)
        global.distance.accept(0.0)
        global.avgPace.accept(0.0)
        locationManager.startUpdatingLocation()
        contentView.stopBtn.isEnabled = true
        contentView.stopBtn.backgroundColor = UIColor(hex: 0xB983F9)
        contentView.countdownView.start(seconds: seconds, onComplete: endAction)
        PersistentNotificationManager.shared.startCountdown(minutes: seconds / 60)
      }).disposed(by: bag)
    // "暂停"
    contentView.stopBtn.rx.tap
      .subscribe(onNext: { [unowned self] in
        if isCheck {
          isCheck = false
          let str = "当前状态：⏸ 已暂停"
          contentView.stopBtn.setTitle("重新开始", for: .normal)
          locationManager.stopUpdatingLocation()
          contentView.countdownView.pause()
          contentView.nowState.text = str
          global.stportType.accept(str)
        } else {
          isCheck = true
          let str = "当前状态：⏸ 已开始"
          contentView.stopBtn.setTitle("已开始", for: .normal)
          locationManager.startUpdatingLocation()
          contentView.countdownView.resume()
          contentView.nowState.text = str
          global.stportType.accept(str)
        }
      }).disposed(by: bag)
    // "结束"
    contentView.endButton.rx.tap
      .subscribe(onNext: endAction).disposed(by: bag)
  }

  func endAction() {
    let str = "当前状态：🏁 结束"
    locationManager.stopUpdatingLocation()
    hasCenteredMap = false
    updateRouteOverlay()
    contentView.nowState.text = str
    let duration = (Date().timeIntervalSince(global.startAt.value))
    let pace = totalDistance / duration
    global.endAt.accept(.now)
    global.stportType.accept(str)
    global.distance.accept(totalDistance)
    global.avgPace.accept(pace)

    isCheck = false
    contentView.stopBtn.isEnabled = false
    contentView.stopBtn.backgroundColor = .gray
    contentView.button.isEnabled = true
    contentView.button.backgroundColor = UIColor(hex: 0xB983F9)
    contentView.stopBtn.setTitle("暂停", for: .normal)
    contentView.countdownView.cancel()
  }
  func bindScrollEffect() {}
}

extension HomeMainScreen: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .authorizedWhenInUse, .authorizedAlways:
      print("✅ 已授权，但未开始定位")
    default:
      print("⚠️ 定位权限未授权或被拒绝：\(status.rawValue)")
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let loc = locations.last, loc.horizontalAccuracy > 0, loc.horizontalAccuracy < 100 else { return }

    let currentCoord = contentView.mapView.userLocation.location?.coordinate ?? loc.coordinate
    routeCoordinates.append(currentCoord)

    // 距离累加
    if routeCoordinates.count > 1 {
      let last = routeCoordinates[routeCoordinates.count - 2]
      let prevLoc = CLLocation(latitude: last.latitude, longitude: last.longitude)
      let currLoc = CLLocation(latitude: currentCoord.latitude, longitude: currentCoord.longitude)
      let distance = currLoc.distance(from: prevLoc)
      totalDistance += distance
    }

    if !hasCenteredMap {
      hasCenteredMap = true
      contentView.mapView.setCenter(currentCoord, animated: true)
      contentView.mapView.userTrackingMode = .follow
    }

    contentView.nowLocal.text = "经度：\(currentCoord.longitude)\n纬度：\(currentCoord.latitude)"
    debugPrint("经度：\(currentCoord.longitude) 纬度：\(currentCoord.latitude)")
    updateRouteOverlay()
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("定位失败：\(error.localizedDescription)")
  }
}

extension HomeMainScreen: QMapViewDelegate {
  func updateRouteOverlay() {
    // 移除旧折线
    if let polyline = routePolyline {
      contentView.mapView.remove(polyline)
    }

    guard !routeCoordinates.isEmpty else { return }

    routeCoordinates.withUnsafeMutableBufferPointer { buffer in
      let ptr = buffer.baseAddress!
      let poly = QPolyline(coordinates: ptr, count: UInt(buffer.count))
      routePolyline = poly
      contentView.mapView.add(poly)
    }
    if let start = routeCoordinates.first {
      // 移除旧圆
      if let circle = startPointCircle {
        contentView.mapView.remove(circle)
      }
      // 添加新圆
      let circle = QCircle(center: start, radius: 6)
      startPointCircle = circle
      contentView.mapView.add(circle)
    }
  }

  func mapView(_ mapView: QMapView!, viewFor overlay: QOverlay!) -> QOverlayView! {
    if let polyline = overlay as? QPolyline {
      let lineView = QPolylineView(polyline: polyline)
      lineView?.strokeColor = UIColor(hex: 0xB983F9)
      lineView?.lineWidth = 6
      return lineView
    }
    if let circle = overlay as? QCircle {
      let circleView = QCircleView(circle: circle)
      circleView?.fillColor = UIColor(hex: 0xB983F9)
      circleView?.strokeColor = UIColor.white
      circleView?.lineWidth = 2
      return circleView
    }
    return nil
  }
}
