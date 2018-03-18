//
//  ViewController.swift
//  test
//
//  Created by Asim Ahmed on 02/22/18.
//  Copyright © 2018 Asim Ahmed. All rights reserved.
//

import UIKit
import Foundation
import MessageUI
import UserNotifications

class ViewController: UIViewController, MFMailComposeViewControllerDelegate,  UIPickerViewDelegate, UIPickerViewDataSource {
    
    var timeIntervalPicker = UIPickerView()
    let timeIntervalOptions = [TimeInterval](arrayLiteral: 15, 60, 300, 600, 1800, 3600)
   
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var starTaskButton: UIButton!
    @IBOutlet weak var stopTaskButton: UIButton!
    @IBOutlet weak var theTextfield: UITextField!
    @IBOutlet weak var BatteryLevelView: UITextView!
    @IBOutlet weak var mailCSVButton: UIButton!
    
    var csvText = "Time, BatteryLevel\n"
    
    
    var timer = Timer()
    var backgroundTask = BackgroundTask()
    
    var defaultTimeInterval : Double = 30.0
    
    
    //The ViewController as delegate of picker must adopt the UIPickerViewDelegate protocol and implement the required methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeIntervalOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let pickeritem = String(timeIntervalOptions[row])
        return pickeritem
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        theTextfield.text = String(timeIntervalOptions[row])
        defaultTimeInterval = timeIntervalOptions[row]
        self.timeIntervalPicker.endEditing(true)
        
        //thePicker.isHidden = true;
    }
 
    
   
    
    @IBAction func mailCSV(_ sender: Any) {
        do {
            let DeviceName = UIDevice.current.name
            let fileName = "batterylog.csv"
            let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            try csvText.write(to: path!, atomically: true, encoding: .utf8)
            
            if MFMailComposeViewController.canSendMail() {
                let emailController = MFMailComposeViewController()
                emailController.mailComposeDelegate = self
                emailController.setToRecipients([])
                emailController.setSubject("Battery charge log for \(DeviceName)")
                emailController.setMessageBody("Hi,\n\nThe .csv data export is attached\n\n\nSent from the batteryprofiling app", isHTML: false)
                
                emailController.addAttachmentData(NSData(contentsOf: path!)! as Data, mimeType: "text/csv", fileName: "batterylog.csv")
                
                present(emailController, animated: true, completion: nil)
                
            }
            else{
                 self.showSendMailErrorAlert()
            }
            timer.invalidate()
            backgroundTask.stopBackgroundTask()
        } catch {
            
            print("Failed to create file")
            print("\(error)")
        }
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send Email.  Please check Email configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
   
    
    @IBAction func startBackgroundTask(_ sender: AnyObject) {
        backgroundTask.startBackgroundTask()
        timer = Timer.scheduledTimer(timeInterval: defaultTimeInterval, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
        starTaskButton.alpha = 0.5
        starTaskButton.isUserInteractionEnabled = false
        
        stopTaskButton.alpha = 1
        stopTaskButton.isUserInteractionEnabled = true
        
       
     
    }
    
    @IBAction func stopBackgroundTask(_ sender: AnyObject) {
        starTaskButton.alpha = 1
        starTaskButton.isUserInteractionEnabled = true
        stopTaskButton.alpha = 0.5
        stopTaskButton.isUserInteractionEnabled = false
        
        timer.invalidate()
        backgroundTask.stopBackgroundTask()
        label.text = ""
        
        mailCSVButton.isEnabled = true
        mailCSVButton.setTitleColor(.blue, for: .normal)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIDevice.current.isBatteryMonitoringEnabled = true
        stopTaskButton.alpha = 0.5
        stopTaskButton.isUserInteractionEnabled = false
        theTextfield.inputView = timeIntervalPicker
        timeIntervalPicker.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        //toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelPicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
       
        theTextfield.inputAccessoryView = toolBar
        
        if #available(iOS 10.0, *){
        initNotificationSetupCheck()
        }
        else{
            
        }
        
    }
    //The notification interact with the user, user taps and brings the app in the foreground, but first you must
    //call this method to request authorization for that interaction
    func initNotificationSetupCheck() {
        if #available(iOS 10.0, *){
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (success, error) in
                if success {
                    print("success")
                } else {
                    print("error")
                }
            }
        }
            else {
            
        }
    }
    
    
    @objc func donePicker()
    {
        theTextfield.resignFirstResponder()
    }
    
    @objc func cancelPicker()
    {
        defaultTimeInterval = 30.0
        theTextfield.text = String(defaultTimeInterval)
        theTextfield.resignFirstResponder()
    }

    
    /** the user has opted to send the email created by this interface and after mail composition
    and send, the natural thing to do is to dismisses the mail composition view **/
    internal func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        controller.dismiss(animated: true, completion: nil)
    }
    
    //after data compilation, enable the mailer button, and stop the timer.
    fileprivate func postdatacompilation() {
        mailCSVButton.isEnabled = true
        mailCSVButton.setTitleColor(.blue, for: .normal)
        timer.invalidate()
    }
    
    func timerAction() {
        if( UIDevice.current.batteryLevel < 1.0){
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([ .hour, .minute, .second], from: date)
        let hour = components.hour
        let minutes = components.minute
        let seconds = components.second
        label.text = "\(hour ?? 0):\(minutes ?? 0) \(seconds ?? 0)"
      
        let batteryLevel = UIDevice.current.batteryLevel
        
        //print("Batttery level= \(batteryLevel)")
        let date1 = Date()
        let calendar1 = Calendar.current
        let hour1 = calendar1.component(.hour, from: date1)
        let minutes1 = calendar1.component(.minute, from: date1)
        //print("\(hour1) : \(minutes1) ")
            BatteryLevelView.text = BatteryLevelView.text + "\(hour1):\(minutes1)     |     Batttery level= \(batteryLevel) \n"
             csvText.append("\(hour1):\(minutes1), \(batteryLevel) \n")
        }
        else{
            let batteryLevel = UIDevice.current.batteryLevel
            let date1 = Date()
            let calendar1 = Calendar.current
            let hour1 = calendar1.component(.hour, from: date1)
            let minutes1 = calendar1.component(.minute, from: date1)
            BatteryLevelView .text = BatteryLevelView.text + "\(hour1):\(minutes1)     |     Batttery level= \(batteryLevel) \n"
            csvText.append("\(hour1):\(minutes1), \(batteryLevel) \n")
            createnotification()
            postdatacompilation()
        }
    }
    
    fileprivate func createnotification()
    {
        if #available(iOS 10.0, *) {
        
        let notification = UNMutableNotificationContent()
        notification.title = "Battery Charge Profile Completed"
        notification.subtitle = "100% Charged"
        notification.body = "Battery Log Created."
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "notification", content: notification, trigger: notificationTrigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
        } else {
            // Fallback on earlier versions
        }
    }
    
}


