//
//  AddAlertViewController.swift
//  DrinkWaterAlarm
//
//  Created by 노민경 on 2022/01/08.
//

import UIKit

class AddAlertViewController: UIViewController {
    var pickedData: ((_ date: Date) -> Void)?
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func btnDissmiss(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func btnSave(_ sender: UIBarButtonItem) {
        pickedData?(datePicker.date) // datePicker에 설정된 date 전달
        self.dismiss(animated: true, completion: nil)
    }
}
