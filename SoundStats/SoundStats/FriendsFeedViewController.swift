//
//  FriendsFeedViewController.swift
//  SoundStats
//
//  Created by Mya Mahaley on 11/8/22.
//

import UIKit
import CoreData

class FriendsFeedViewController: UIViewController {
    var preferences: NSManagedObject!
    var darkMode: Bool!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getPreferences()
        darkMode = preferences.value(forKey: "darkMode") as? Bool
        if (darkMode){
            view.backgroundColor = UIColor(red: 0.102, green: 0.1098, blue: 0.1294, alpha: 1.0)
        } else {
            self.view.backgroundColor = UIColor.lightGray
        }
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

}
