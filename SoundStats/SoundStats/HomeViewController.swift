import UIKit
import Placid
import CoreData

class HomeViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var segVC: UISegmentedControl!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    var currentColor: String!
    var mainTemplate = PlacidSDK.template(withIdentifier: "qlmhe8hvu")
    var moodTemplate = PlacidSDK.template(withIdentifier: "wf1xyvyhu")
    var topSongsTemplate = PlacidSDK.template(withIdentifier: "1jrtyolls")
    var trackArray:[Track] = []
    
    
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
        mainTemplate?.preload()
        moodTemplate?.preload()
        topSongsTemplate?.preload()
        populateTopTracks()
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
    
    
    
    private func moodBackground(color: UIColor){
        let background = moodTemplate?.rectangleLayer(named: "MainstreamBackground")
        background?.backgroundColor = color
    }
    
    private func getArtistString(artistList: [Artist]) -> String {
        var result = ""
        var i = 0
        for artist in artistList {
            result.append(artist.name)
            if(i < artistList.count - 1){
                result.append(", ")
            }
            i += 1
        }
        return result
    }
    
    private func loadMainData(){
        let song1 = mainTemplate?.textLayer(named: "Song1Text")
        if(trackArray.count > 0) {
            let song1Artists = getArtistString(artistList: trackArray[0].artists)
            song1?.text = "\(trackArray[0].name) - \(song1Artists)"
        } else {
            song1?.text = "N/A"
        }
        
        
        let song2 = mainTemplate?.textLayer(named: "Song2Text")
        if(trackArray.count > 1) {
            let song2Artists = getArtistString(artistList: trackArray[1].artists)
            song2?.text = "\(trackArray[1].name) - \(song2Artists)"
        } else {
            song2?.text = "N/A"
        }
        
        let song3 = mainTemplate?.textLayer(named: "Song3Text")
        if(trackArray.count > 2) {
            let song3Artists = getArtistString(artistList: trackArray[2].artists)
            print(song3Artists)
            song3?.text = "\(trackArray[2].name) - \(song3Artists)"
        } else {
            song3?.text = "N/A"
        }
        
        let song4 = mainTemplate?.textLayer(named: "Song4Text")
        if(trackArray.count > 3) {
            let song4Artists = getArtistString(artistList: trackArray[3].artists)
            print(song4Artists)
            song4?.text = "\(trackArray[3].name) - \(song4Artists)"
        } else {
            song4?.text = "N/A"
        }
        
        let song5 = mainTemplate?.textLayer(named: "Song5Text")
        if(trackArray.count > 4) {
            let song5Artists = getArtistString(artistList: trackArray[4].artists)
            print(song5Artists)
            song5?.text = "\(trackArray[4].name) - \(song5Artists)"
        } else {
            song5?.text = "N/A"
        }
    }
    private func loadMoodData(){
        
    }
    private func loadTopSongsData(){
        let songTitle = topSongsTemplate?.textLayer(named: "SongTitle")
        let artistName = topSongsTemplate?.textLayer(named: "ArtistName")
        let artistImage = topSongsTemplate?.pictureLayer(named: "ArtistImage")
        if(trackArray.count > 0) {
            let artists = getArtistString(artistList: trackArray[0].artists)
            
            let curArtist = trackArray[0].artists[0]
            
            if(curArtist.images != nil){
                artistImage?.imageURL = URL(string: (curArtist.images?[0].url)!)
            }
            songTitle?.text = "\(trackArray[0].name)"
            artistName?.text = "\(artists)"
        } else {
            songTitle?.text = "N/A"
            artistName?.text = "N/A"
        }
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
        loadMainData()
        imageView.isHidden = true
        loading.startAnimating()
        mainTemplate!.renderImage(completion: { [weak self] mainImage in
            self?.imageView.image = mainImage
            self?.loading.stopAnimating()
            self?.imageView.isHidden = false
        })
    }
    
    func loadMoodImage() {
        loadMoodData()
        imageView.isHidden = true
        loading.startAnimating()
        moodTemplate!.renderImage(completion: { [weak self] moodImage in
            self?.imageView.image = moodImage
            self?.loading.stopAnimating()
            self?.imageView.isHidden = false
        })
    }
    
    func loadTopSongsImage() {
        loadTopSongsData()
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
    
    private func getTrackItem() ->[NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackItem")
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
    
    private func populateTopTracks() {
        let fetchedResults = getTrackItem()
        var trackItems:[NSManagedObject] = []
        print("TRACK ITEMS \(fetchedResults.count)")
        for track in fetchedResults {
            let collectionName = track.value(forKey: "collectionName") as! String
            if (collectionName == "userTopTracks") {
                trackItems.append(track)
            }
        }
        
        if(!trackItems.isEmpty){
            let tracks = trackItems[0].value(forKey: "tracks") as! NSSet
          
            for trackObj in tracks {
                let track = trackObj as! NSManagedObject
                let trackName = track.value(forKey: "name") as! String
                let trackID = track.value(forKey: "id") as! String
                    var artistArray:[Artist] = []
                    let artists = track.value(forKey: "artists") as! NSSet
                    for artistObj in artists {
                        let artist = artistObj as! NSManagedObject
                        let artistName = artist.value(forKey: "name") as! String
                        let artistID = artist.value(forKey: "id") as! String
                        artistArray.append(Artist(name: artistName, id: artistID))
                    }

                    trackArray.append(Track(name: trackName, id: trackID, artists: artistArray))
            }
        }
        }
        
}
