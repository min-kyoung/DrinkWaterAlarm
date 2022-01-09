//
//  AlertListCell.swift
//  DrinkWaterAlarm
//
//  Created by 노민경 on 2022/01/08.
//

import UIKit
import UserNotifications

class AlertListCell: UITableViewCell {

    let userNotificationCenter = UNUserNotificationCenter.current()
    
    @IBOutlet weak var lblMeridiem: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var switchAlert: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func switchAlertActionChange(_ sender: UISwitch) {
        guard let data = UserDefaults.standard.value(forKey: "alerts") as? Data,
              var alerts = try? PropertyListDecoder().decode([Alert].self, from: data) else { return }
        
        // 변경되는 스위치의 on/off 값을 해당하는 alert의 isOn 값으로 변경
        alerts[sender.tag].isOn = sender.isOn
        // 변경된 값을 다시 UserDefaults에 반영
        UserDefaults.standard.set(try? PropertyListEncoder().encode(alerts), forKey: "alerts")
        
        if sender.isOn {
            userNotificationCenter.addNotificationRequest(by: alerts[sender.tag])
        } else {
            userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [alerts[sender.tag].id])
        }
    }
}
