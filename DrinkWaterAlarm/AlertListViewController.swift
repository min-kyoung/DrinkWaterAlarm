//
//  AlertListViewController.swift
//  DrinkWaterAlarm
//
//  Created by 노민경 on 2022/01/08.
//

import UIKit
import UserNotifications

class AlertListViewController: UITableViewController {
    var alerts: [Alert] = []
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibName = UINib(nibName: "AlertListCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "AlertListCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        alerts = alertList() // UserDefaults에 저장된 값대로 alerts가 반영
    }
    
    // 알람 추가 버튼
    @IBAction func btnAddAlert(_ sender: UIBarButtonItem) {
        guard let addAlertVC = storyboard?.instantiateViewController(identifier: "AddAlertViewController")
                as? AddAlertViewController else { return }
        
        // 생성된 알람이 리스트에 표현되도록
        addAlertVC.pickedData = { [weak self] date in
            guard let self = self else { return }
            
            var alertList = self.alertList() // 현재의 UserDefaults에서 가져온 리스트
            let newAlert = Alert(date: date, isOn: true)
            
            alertList.append(newAlert)
            alertList.sort { $0.date < $1.date } // 저장된 순서에 상관없이 시간이 빠른 순서대로 정렬
            
            self.alerts = alertList
            
            // 새로 만든 alerts를 UserDefaults에 저장
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.alerts), forKey: "alerts")
            
            // notification 추가
            self.userNotificationCenter.addNotificationRequest(by: newAlert)
            
            self.tableView.reloadData()
            
        }
        // 자식뷰에서 전달된 데이터의 핸들링 추가
        self.present(addAlertVC, animated: true, completion: nil)
    }
    
    // Alert 객체의 배열을 UserDefaults에서 내뱉어주는 alertList
    func alertList() -> [Alert] {
        guard let data = UserDefaults.standard.value(forKey: "alerts") as? Data,
              let alerts = try? PropertyListDecoder().decode([Alert].self, from: data) else { return [] }
        // alertList는 property 형태로 저장이 됨 -> 이해할 수 있는 객체로 decoding이 가능함
        // UserDefaults는 임의로 만든 구조체를 이해하지 못하기 때문에 json 처럼 encoding과 decoding 해서 익숙하게 만들 수 있음
        return alerts
    }
}

// UITableView Datasource, Delegate
extension AlertListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alerts.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: // 첫번째 섹션
            return "🚰 물마실 시간"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlertListCell", for: indexPath)
                as? AlertListCell else { return UITableViewCell() }
        
        cell.switchAlert.isOn = alerts[indexPath.row].isOn
        cell.lblTime.text = alerts[indexPath.row].time
        cell.lblMeridiem.text = alerts[indexPath.row].meridiem
        
        // 각 셀이 자신의 index를 알 수 있게 하기 위해 tag 값 부여
        cell.switchAlert.tag = indexPath.row
        
        return cell
    }
    
    // 셀 높이 설정
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // 값 변경 가능하게 delegate 설정
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch  editingStyle {
        case .delete:
            // notification 삭제
            self.alerts.remove(at: indexPath.row)
            // 삭제한 행을 UserDefaults에도 반영
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.alerts), forKey: "alerts")
            // notification 삭제
            userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [alerts[indexPath.row].id])
            
            self.tableView.reloadData()
            return
        default:
            break
        }
    }
}
