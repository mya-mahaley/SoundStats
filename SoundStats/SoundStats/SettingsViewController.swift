//
//  SettingsViewController.swift
//  SoundStats
//
//  Created by Sonya Pieklik on 11/8/22.
//

import UIKit
import FirebaseAuth




class SettingsViewController: UIViewController {
    
    @IBOutlet weak var logoutButton: UIButton!
  
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        
        UNUserNotificationCenter.current().requestAuthorization(options:[.alert,.badge,.sound]){
            pass, error in
            if pass {
                print("Passed.")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        
    }

    
    @IBAction func notificationSwitch(_ sender: Any) {
        if notificationSwitch.isOn{
            let content = UNMutableNotificationContent()
            content.title = "SoundStats"
            content.body = "Your stats has been on the move!"
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            
            dateComponents.weekday = 3  // Tuesday
            dateComponents.hour = 14    // 14:00 hours
            
            // Create the trigger as a repeating event.
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents, repeats: true)
            
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString,
                                                content: content, trigger: trigger)
            
            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
                if error != nil {
                    // Handle any errors.
                }
            }
            
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }
    
    
    @IBAction func logOutPressed(_ sender: UIButton) {
        
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    
        navigationController?.popToRootViewController(animated: true)
        self.performSegue(withIdentifier: "logOutPressed", sender: self)
        
    }
}
