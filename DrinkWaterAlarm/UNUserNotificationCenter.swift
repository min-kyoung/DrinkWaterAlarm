//
//  UNNotificationCenter.swift
//  DrinkWaterAlarm
//
//  Created by 노민경 on 2022/01/09.
//

import Foundation
import UserNotifications

extension UNUserNotificationCenter {
    func addNotificationRequest(by alert: Alert) {
        let content = UNMutableNotificationContent()
        content.title = "물 마실 시간이에요💦"
        content.body = "세계보건기구(WHO)가 권장하는 하루 물 섭취량은 1.5 ~ 2리터 입니다."
        content.sound = .default
        content.badge = 1
        
        // local notification 활성화, 즉 알람을 발송시키는 조건이 되는 trigger 설정
        let component = Calendar.current.dateComponents([.hour, .minute], from: alert.date) // 시간과 분을 가져옴
        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: alert.isOn) // 스위치가 켜져 있을 동안만 알람 반복
        
        // Request
        let request = UNNotificationRequest(identifier: alert.id, content: content, trigger: trigger)
        
        self.add(request, withCompletionHandler: nil)
    }
}
