//
//  SettingsViewController.swift
//  SoundStats
//
//  Created by Sonya Pieklik on 11/8/22.
//

import UIKit
import FirebaseAuth
import CoreData
import FirebaseCore


struct darkMode {
    static var darkMode = true
}

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var logoutButton: UIButton!
  
    @IBOutlet weak var notificationSwitch: UISwitch!
    var preferences: NSManagedObject!
    var darkModeStatus: Bool!
    let user = Auth.auth().currentUser
    //let storage = Storage.storage()
    
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        let image = user?.photoURL
        if(image != nil){
            load(url: image!)
        }

        UNUserNotificationCenter.current().requestAuthorization(options:[.alert,.badge,.sound]){
            pass, error in
            if pass {
                print("Passed.")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getPreferences()
        darkModeStatus = preferences.value(forKey: "darkMode") as? Bool
        if(darkModeStatus){
            view.backgroundColor = UIColor(red: 0.102, green: 0.1098, blue: 0.1294, alpha: 1.0)
            darkModeSwitch.isOn = true
        } else {
            self.view.backgroundColor = UIColor.lightGray
            darkModeSwitch.isOn = false
        }
        
    }
    
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                    }
                }
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
                let photoLocalUrl = (info[UIImagePickerController.InfoKey.imageURL] as? URL)!
                
                let changeRequest = user?.createProfileChangeRequest()
                changeRequest?.photoURL = photoLocalUrl
                print("PICKED:\(photoLocalUrl)")
                changeRequest?.commitChanges { error in
                  if let error = error {
                    print(error)
                  } else {
                  }
                }
                
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
            //darkMode.darkMode = true
            updateDarkMode(mode: true)
            view.backgroundColor = UIColor(red: 0.102, green: 0.1098, blue: 0.1294, alpha: 1.0)
        } else {
            //darkMode.darkMode = false
            updateDarkMode(mode: false)
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
    
    private func getPreferences() {
        let fetchedPreferences = retrievePreferences()
        if(fetchedPreferences.isEmpty) {
            preferences = createPreferences()
        } else {
            preferences = fetchedPreferences[0]
        }
    }
    
    private func createPreferences() -> NSManagedObject {
        print("Creating Preferences")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let preferences = NSEntityDescription.insertNewObject(forEntityName: "Preferences", into: context)
        
        preferences.setValue("Gradient", forKey: "color")
        preferences.setValue(true, forKey: "darkMode")
    
        
        // commit the changes
        do {
            try context.save()
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        return preferences
    }
    
    private func retrievePreferences() -> [NSManagedObject]{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Preferences")
        var fetchedResults:[NSManagedObject]? = nil
        
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        return(fetchedResults)!
    }
    
    private func updateDarkMode(mode: Bool){
        preferences.setValue(mode, forKey: "darkMode")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        do {
            try context.save()
        }
        catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }

}
