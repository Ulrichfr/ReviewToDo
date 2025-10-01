//
//  NotificationManager.swift
//  ReviewToDoAPp
//
//  Created with Claude Code
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }
    
    func scheduleNotification(for test: ProductTest) async {
        guard let dueDate = test.dueDate else { return }
        
        // Remove existing notification for this test
        await cancelNotification(for: test.id)
        
        // Calculate notification date (1 day before due date at 9 AM)
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: dueDate)
        components.day! -= 1
        components.hour = 9
        components.minute = 0
        
        guard let notificationDate = calendar.date(from: components),
              notificationDate > Date() else {
            return // Don't schedule if date is in the past
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Test à faire demain !"
        content.body = "\(test.name) - \(test.brand)"
        content.sound = .default
        content.badge = 1
        
        let triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: test.id, content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Notification scheduled for \(test.name) on \(notificationDate)")
        } catch {
            print("❌ Error scheduling notification: \(error)")
        }
    }
    
    func cancelNotification(for testId: String) async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [testId])
    }
    
    func cancelAllNotifications() async {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
