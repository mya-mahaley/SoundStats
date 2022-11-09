//
//  SettingsViewController.swift
//  SoundStats
//
//  Created by Sonya Pieklik on 11/8/22.
//

import UIKit
import FirebaseAuth


struct darkMode {
    static var darkMode = true
}

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var logoutButton: UIButton!
  
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        

        UNUserNotificationCenter.current().requestAuthorization(options:[.alert,.badge,.sound]){
            pass, error in
            if pass {
                print("Passed.")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        
    }
    


    @IBAction func loadImageButtonTapped(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
            
        present(imagePicker, animated: true, completion: nil)    }
    
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                imageView.contentMode = .scaleAspectFit
                imageView.image = pickedImage
            }
            
            dismiss(animated: true, completion: nil)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
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
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    @IBAction func darkModeSwitch(_ sender: Any) {
        if darkModeSwitch.isOn {
            darkMode.darkMode = true
            view.backgroundColor = UIColor(red: 0.102, green: 0.1098, blue: 0.1294, alpha: 1.0)
        } else{
            darkMode.darkMode = false
            view.backgroundColor = UIColor.lightGray
            
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
