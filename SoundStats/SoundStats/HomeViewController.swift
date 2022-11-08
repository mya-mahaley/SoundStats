//
//  HomeViewController.swift
//  SoundStats
//
//  Created by Mya Mahaley on 11/7/22.
//

import UIKit
import Placid
import CoreData

class HomeViewController: UIViewController {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var segVC: UISegmentedControl!
    var currentColor: String!
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    var mainTemplate = PlacidSDK.template(withIdentifier: "qlmhe8hvu")
    var moodTemplate = PlacidSDK.template(withIdentifier: "wf1xyvyhu")
    var topSongsTemplate = PlacidSDK.template(withIdentifier: "1jrtyolls")
    //rgba(130,99,255,255)
    let purple = UIColor(red: 0.51, green: 0.39, blue: 1.00, alpha: 1.00)
    //rgba(125,205,98,255)
    let green = UIColor(red: 0.49, green: 0.80, blue: 0.38, alpha: 1.00)
    //rgba(255,99,98,255)
    let salmon = UIColor(red: 1.00, green: 0.39, blue: 0.38, alpha: 1.00)
    //rgba(47,175,183,255)
    let teal = UIColor(red: 0.18, green: 0.69, blue: 0.72, alpha: 1.00)
    
    var preferences: NSManagedObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*mainTemplate?.preload()
         moodTemplate?.preload()
         topSongsTemplate?.preload()*/
        setColorScheme()
        loadMainImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getPreferences()
        currentColor = preferences.value(forKey: "color") as? String
        setColorScheme()
        
        switch segVC.selectedSegmentIndex {
            case 0:
                loadMainImage()
            case 1:
                loadMoodImage()
            case 2:
                loadTopSongsImage()
            default:
                print("Error")
        }
    }
    
    private func mainImageBackground(color: UIColor) {
        let background1 = mainTemplate?.rectangleLayer(named: "Song1Background")
        background1?.backgroundColor = color
        
        let background2 = mainTemplate?.rectangleLayer(named: "Song2Background")
        background2?.backgroundColor = color
        
        let background3 = mainTemplate?.rectangleLayer(named: "Song3Background")
        background3?.backgroundColor = color
        
        let background4 = mainTemplate?.rectangleLayer(named: "Soung4Background")
        background4?.backgroundColor = color
        
        let background5 = mainTemplate?.rectangleLayer(named: "Song5Background")
        background5?.backgroundColor = color
        
        let mainstream = mainTemplate?.rectangleLayer(named: "MainstreamBackground")
        mainstream?.backgroundColor = color
        
        let rotation = mainTemplate?.rectangleLayer(named: "RotationBackground")
        rotation?.backgroundColor = color
    }
    
    private func topSongsBackground(color: UIColor) {
        let background = topSongsTemplate?.rectangleLayer(named: "SongBackground")
        background?.backgroundColor = color
    }
    private func moodBackground(color: UIColor) {
        let background = moodTemplate?.rectangleLayer(named: "MainstreamBackground")
        background?.backgroundColor = color
    }
    private func setColorScheme() {
        switch currentColor {
            case "Teal":
                mainImageBackground(color: teal)
                moodBackground(color: teal)
                topSongsBackground(color: teal)
            case "Salmon":
                mainImageBackground(color: salmon)
                moodBackground(color: salmon)
                topSongsBackground(color: salmon)
            case "Green":
                mainImageBackground(color: green)
                moodBackground(color: green)
                topSongsBackground(color: green)
            case "Purple":
                mainImageBackground(color: purple)
                moodBackground(color: purple)
                topSongsBackground(color: purple)
            default:
                mainTemplate = PlacidSDK.template(withIdentifier: "qlmhe8hvu")
                moodTemplate = PlacidSDK.template(withIdentifier: "wf1xyvyhu")
                topSongsTemplate = PlacidSDK.template(withIdentifier: "1jrtyolls")
        }
    }
    func loadMainImage() {
        imageView.isHidden = true
        loading.startAnimating()
        mainTemplate!.renderImage(completion: { [weak self] mainImage in
            self?.imageView.image = mainImage
            self?.loading.stopAnimating()
            self?.imageView.isHidden = false
        })
    }
    
    func loadMoodImage() {
        imageView.isHidden = true
        loading.startAnimating()
        moodTemplate!.renderImage(completion: { [weak self] moodImage in
            self?.imageView.image = moodImage
            self?.loading.stopAnimating()
            self?.imageView.isHidden = false
        })
    }
    
    func loadTopSongsImage() {
        imageView.isHidden = true
        loading.startAnimating()
        topSongsTemplate!.renderImage(completion: { [weak self] topSongsImage in
            self?.imageView.image = topSongsImage
            self?.loading.stopAnimating()
            self?.imageView.isHidden = false
        })
        
    }
    
    @IBAction func segChanged(_ sender: Any) {
        setColorScheme()
        switch segVC.selectedSegmentIndex {
            case 0:
                loadMainImage()
            case 1:
                loadMoodImage()
            case 2:
                loadTopSongsImage()
            default:
                print("Unknown Error")
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
