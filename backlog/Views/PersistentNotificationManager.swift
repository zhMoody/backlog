//
//  PersistentNotificationManager.swift
//  backlog
//
//  Created by 张浩 on 2025/6/10.
//

import Foundation
import UserNotifications
import BackgroundTasks

final class PersistentNotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = PersistentNotificationManager()
    
    private let notificationID = "DELIVERY_TIMER"
    private let taskID = "com.coder.backlog"
    private var remainingTime = 0
    
    private override init() {
        super.init()
    }
    
    func setup() {
        UNUserNotificationCenter.current().delegate = self
        registerNotificationCategory()
        requestAuthorization()
        registerBGTask()
        print("✅ PersistentNotificationManager setup 完成")
    }
    
    private func registerNotificationCategory() {
        let closeAction = UNNotificationAction(identifier: "CLOSE_ACTION", title: "关闭", options: [.destructive])
        let category = UNNotificationCategory(identifier: "TIMER_CATEGORY", actions: [closeAction], intentIdentifiers: [], options: .customDismissAction)
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if !granted {
                print("⚠️ 用户未授权通知权限")
            } else {
                print("✅ 用户授权通知权限")
            }
        }
    }
    // MARK: - 前台通知展示
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("📣 App 前台接收到通知")
        completionHandler([.banner, .sound, .list]) // ✅ 明确展示横幅、声音、列表
    }
    private func registerBGTask() {
      BGTaskScheduler.shared.register(forTaskWithIdentifier: taskID, using: nil) { task in
          print("📦 收到后台任务调度：\(task.identifier)")
          // 确保类型转换正确
          guard let processingTask = task as? BGProcessingTask else {
              task.setTaskCompleted(success: false)
              return
          }

          // 在此执行你的倒计时更新逻辑
          PersistentNotificationManager.shared.handleBackgroundTask(task: processingTask)
      }
    }
    
    func startCountdown(minutes: Int) {
        remainingTime = minutes
        updateNotification()
        scheduleNextBackgroundUpdate()
    }
    
  private func updateNotification() {
    print("🔁 更新通知：剩余时间 \(remainingTime) 分钟")
       let content = UNMutableNotificationContent()
       content.title = "🍱 外卖已出发"
       content.body = "骑手正在前往您家，还有 \(remainingTime) 分钟"
       content.sound = .default
       content.threadIdentifier = "FOOD_DELIVERY"
       content.categoryIdentifier = "TIMER_CATEGORY"
       
       if let imageURL = Bundle.main.url(forResource: "rider", withExtension: "jpg"),
          let attachment = try? UNNotificationAttachment(identifier: "image", url: imageURL, options: nil) {
           content.attachments = [attachment]
       }

       if #available(iOS 15.0, *) {
           content.interruptionLevel = .timeSensitive
       }

       let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: nil)
       UNUserNotificationCenter.current().add(request)
  }
    
    private func scheduleNextBackgroundUpdate() {
        guard remainingTime > 0 else { return }

        do {
            let request = BGProcessingTaskRequest(identifier: taskID)
            request.requiresNetworkConnectivity = false
            request.earliestBeginDate = Date(timeIntervalSinceNow: 60) // 1 分钟后触发
            try BGTaskScheduler.shared.submit(request)
          print("⏰ 已提交后台任务，预计触发时间：\(request.earliestBeginDate?.ex.stringify("yyyy.MM.dd HH:mm:ss") ?? "未知")")
        } catch {
            print("❌ 提交后台任务失败: \(error)")
        }
    }
    
    private func handleBackgroundTask(task: BGProcessingTask) {
        print("📲 执行后台任务，剩余时间：\(remainingTime) 分钟")
        updateNotification()
        remainingTime -= 1
        
        if remainingTime > 0 {
            scheduleNextBackgroundUpdate()
        }

        task.setTaskCompleted(success: true)
    }
    
    func stopCountdown() {
        print("🛑 用户关闭倒计时通知")
        remainingTime = 0
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notificationID])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])
    }
    
    // MARK: - 处理关闭按钮操作
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        print("🔴 用户点击关闭通知按钮")
        if response.actionIdentifier == "CLOSE_ACTION" {
            stopCountdown()
        }
    }
}
