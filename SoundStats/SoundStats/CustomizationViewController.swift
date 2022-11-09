//
//  CustomizationViewController.swift
//  SoundStats
//
//  Created by Mya Mahaley on 11/7/22.
//

import UIKit
import CoreData

class CustomizationViewController: UIViewController {

    @IBOutlet weak var gradientButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var purpleButton: UIButton!
    @IBOutlet weak var salmonButton: UIButton!
    @IBOutlet weak var tealButton: UIButton!
    var preferences: NSManagedObject!
    var currentColor: String!
    var darkMode: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getPreferences()
        currentColor = preferences.value(forKey: "color") as? String
        darkMode = preferences.value(forKey: "darkMode") as? Bool
        if (darkMode){
            view.backgroundColor = UIColor(red: 0.102, green: 0.1098, blue: 0.1294, alpha: 1.0)
        } else {
            self.view.backgroundColor = UIColor.lightGray
        }
        
        switch currentColor {
            case "Gradient":
                changeButtonShadows(newButton: gradientButton)
            case "Teal":
                changeButtonShadows(newButton: tealButton)
            case "Salmon":
                changeButtonShadows(newButton: salmonButton)
            case "Green":
                changeButtonShadows(newButton: greenButton)
            case "Purple":
                changeButtonShadows(newButton: purpleButton)
            default:
                changeButtonShadows(newButton: gradientButton)
        }
        
    }
    
    @IBAction func tealPressed(_ sender: Any) {
        updateColorPreference(color: "Teal")
        changeButtonShadows(newButton: tealButton)
        currentColor = "Teal"
    }
    @IBAction func salmonPressed(_ sender: Any) {
        updateColorPreference(color: "Salmon")
        changeButtonShadows(newButton: salmonButton)
        currentColor = "Salmon"
    }
    @IBAction func purplePressed(_ sender: Any) {
        updateColorPreference(color: "Purple")
        changeButtonShadows(newButton: purpleButton)
        currentColor = "Purple"
    }
    @IBAction func gradientPressed(_ sender: Any) {
        updateColorPreference(color: "Gradient")
        changeButtonShadows(newButton: gradientButton)
        currentColor = "Gradient"
    }
    @IBAction func greenPressed(_ sender: Any) {
        updateColorPreference(color: "Green")
        changeButtonShadows(newButton: greenButton)
        currentColor = "Green"
    }
    
    private func updateColorPreference(color: String){
        preferences.setValue(color, forKey: "color")
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
    
    private func changeButtonShadows(newButton: UIButton){
        var curButton: UIButton!
        switch currentColor {
            case "Gradient":
                curButton = gradientButton
            case "Teal":
                curButton = tealButton
            case "Salmon":
                curButton = salmonButton
            case "Green":
                curButton = greenButton
            case "Purple":
                curButton = purpleButton
            default:
                curButton = gradientButton
        }
        
        curButton.layer.borderWidth = 0
        
        newButton.layer.borderWidth = 5
        newButton.layer.borderColor = UIColor.blue.cgColor
            
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
