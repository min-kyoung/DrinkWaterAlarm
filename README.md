# DrinkWaterAlarm
## Description
Local Notification을 이용해서 물마시기 알람을 구현하는 프로그램이다. <br>
언제 물을 마실지 시간을 정하고 해당 시간을 알림을 보낼 시간으로 설정한 후, 추가한 알림을 켜고 끌 수 있도록 한다.<br>
<img src="https://user-images.githubusercontent.com/62936197/150624802-a6c8e6d9-a47d-4951-b731-c246317c8aef.png" width="150" height="320"> 　 　
<img src="https://user-images.githubusercontent.com/62936197/150624803-0129880a-178d-459d-bb9f-2fb544384ba2.png" width="150" height="320"> 　 　
<img src="https://user-images.githubusercontent.com/62936197/150624804-859323f0-2e76-4fac-b66e-71f1fe434cda.png" width="150" height="320"> <br>
## Files
>AppDelegate.swift
  * 알림을 어떻게 표시하여 보낼지 설정한다.
    ```swift
    var userNotificationCenter: UNUserNotificationCenter?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        
        let authrizationOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound]) // 사용자의 허락을 구함
        userNotificationCenter?.requestAuthorization(options: authrizationOptions) { _, error in
            if let error = error {
                print("ERROR: notification authrization request \(error.localizedDescription)")
            }
        }
        return true
    }
    ```
    ```swift
    extension AppDelegate: UNUserNotificationCenterDelegate {
        func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([.banner, .list, .badge, .sound]) // 배너, 리스트, 뱃지, 사운드 형태로 알람을 보내도록 설정
        }

        func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
            completionHandler()
        }
    }
    ```
>AlertListViewController.swift
  * 어플을 실행하면 가장 먼저 보여질 메인 화면
  * 알람을 추가한 경우
    ```swift
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
    ```
  * Alert 객체의 배열을 UserDefaults에서 내뱉어주는 alertList 설정
    ```swift
    func alertList() -> [Alert] {
        guard let data = UserDefaults.standard.value(forKey: "alerts") as? Data,
              let alerts = try? PropertyListDecoder().decode([Alert].self, from: data) else { return [] }
        // alertList는 property 형태로 저장이 됨 -> 이해할 수 있는 객체로 decoding이 가능함
        // UserDefaults는 임의로 만든 구조체를 이해하지 못하기 때문에 json 처럼 encoding과 decoding 해서 익숙하게 만들 수 있음
        return alerts
    }
    ```
>AddAlertListViewController.swift
  * 알람 추가 버튼을 클릭하면 넘어가는 화면
  * 사용자가 dataPicket로 선택한 시간을 전달한다.
    ```swift
    var pickedData: ((_ date: Date) -> Void)?

    @IBAction func btnDissmiss(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func btnSave(_ sender: UIBarButtonItem) {
        pickedData?(datePicker.date) // datePicker에 설정된 date 전달
        self.dismiss(animated: true, completion: nil)
    }
    ```
>Alert.swift
  * alert 객체에 대한 entity 설정
    ```swift
    struct Alert: Codable {
        var id: String = UUID().uuidString
        let date: Date
        var isOn: Bool

        var time: String { // 시:분
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm"
            return timeFormatter.string(from: date)
        }

        var meridiem: String { // 오전/오후
            let meridiemFormatter = DateFormatter()
            meridiemFormatter.dateFormat = "a"
            meridiemFormatter.locale = Locale(identifier: "ko") // 한국 시간으로 변환
            return meridiemFormatter.string(from: date)
         }
    }
    ```
>UNUserNoticifationCenter.swift
  * alert 객체를 받아서 request를 만들고 최종적으로 notification center에 추가한다.
    ```swift
    func addNotificationRequest(by alert: Alert) {
        let content = UNMutableNotificationContent()
        content.title = "물 마실 시간이에요💦"
        content.body = "세계보건기구(WHO)가 권장하는 하루 물 섭취량은 1.5~2ℓ입니다."
        content.sound = .default
        content.badge = 1
        
        // local notification 활성화, 즉 알람을 발송시키는 조건이 되는 trigger 설정
        let component = Calendar.current.dateComponents([.hour, .minute], from: alert.date) // 시간과 분을 가져옴
        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: alert.isOn) // 스위치가 켜져 있을 동안만 알람 반복
        
        // Request
        let request = UNNotificationRequest(identifier: alert.id, content: content, trigger: trigger)
        
        self.add(request, withCompletionHandler: nil)
    }
    ```
>AlertListCell.swift
  * AlertListViewController.swift에 등록될 셀을 만든다.
  * Cocoa Touch Class로 생성하고 subclass는 UITableViewCell로 선택하고 XIB 파일도 함께 생성한다.
