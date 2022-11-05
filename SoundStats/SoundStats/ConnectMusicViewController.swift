// Connect to Spotify logic taken
// from Spotify's public repo for their iOS SDK
// at https://github.com/spotify/ios-sdk 

import UIKit
import CoreData

class ConnectMusicViewController: UIViewController {

    // MARK: - Spotify Authorization & Configuration
    var responseCode: String? {
        didSet {
            fetchAccessToken { (dictionary, error) in
                if let error = error {
                    print("Fetching token request error \(error)")
                    return
                }
                let accessToken = dictionary!["access_token"] as! String
                DispatchQueue.main.async {
                    self.appRemote.connectionParameters.accessToken = accessToken
                    print("CONNECTING TO APP REMOTE")
                    self.appRemote.connect()
                    self.accessToken = accessToken
                }
            }
        }
    }

    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()

    var accessToken = UserDefaults.standard.string(forKey: accessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: accessTokenKey)
        }
    }

    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: spotifyClientId, redirectURL: redirectUri)
        // Set the playURI to a non-nil value so that Spotify plays music after authenticating
        // otherwise another app switch will be required
        configuration.playURI = ""
        // Set these url's to your backend which contains the secret to exchange for an access token
        // You can use the provided ruby script spotify_token_swap.rb for testing purposes
        configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
        configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
        return configuration
    }()

    lazy var sessionManager: SPTSessionManager? = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
    }()

    private var lastPlayerState: SPTAppRemotePlayerState?

    // MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        style()
//        layout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        updateViewBasedOnConnected()
    }
    
    @IBAction func connectWithSpotifyPressed(_ sender: Any) {
        guard let sessionManager = sessionManager else { return }
        sessionManager.initiateSession(with: scopes, options: .default)
        performSegue(withIdentifier: "homePageSegueID", sender: nil)
        
        // info dump user stats
//        getTopArtists()
        
        DispatchQueue.main.async {
            self.getTopTracks()
            self.readTopTracks()
            self.clearCoreData()
        }
    }
    
    func readTopTracks() {
        let fetchedResults = retrieveTracks()
        for ob in fetchedResults {
            let name = ob.value(forKey: "name") as! String
            print(name)
            let set = ob.value(forKey: "artists") as! NSSet
            for ob2 in set {
                let artist = ob2 as! NSManagedObject
                let artistName = artist.value(forKey: "name") as! String
                print(artistName)
            }
        }
    }
    
    func getTopArtists() {
        guard let url = URL(string: "https://api.spotify.com/v1/me/top/artists?time_range=medium_term&limit=5") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.accessToken!)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            guard error == nil else {
                print("ERROR: ", error!)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("NO RESPONSE")
                return
            }
            
            guard response.statusCode == 200 else {
                print("BAD RESPONSE: ", response.statusCode)
                return
            }
            
            guard let data = data else {
                print("NO DATA")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let artists = try decoder.decode(ArtistItem.self, from: data)
                for artist in artists.items {
                    print("ARTIST:", artist.name)
                }
            } catch {
                print("CATCH: ", error)
            }
        }).resume()
    }
    
    func getTopTracks() {
        print("calling spotify web api")
        guard let url = URL(string: "https://api.spotify.com/v1/me/top/tracks?time_range=medium_term&limit=50") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.accessToken!)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            guard error == nil else {
                print("ERROR: ", error!)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("NO RESPONSE")
                return
            }
            
            guard response.statusCode == 200 else {
                print("BAD RESPONSE: ", response.statusCode)
                return
            }
            
            guard let data = data else {
                print("NO DATA")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let tracks = try decoder.decode(TrackItem.self, from: data)
                if tracks.items.count > 0 {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appDelegate.persistentContainer.viewContext
                    
                    for track in tracks.items {
                        let oneTrack = NSEntityDescription.insertNewObject(forEntityName: "Track", into: context)
                        oneTrack.setValue(track.name, forKey: "name")
                        
                        for artist in track.artists {
                            print(artist.name, terminator: ", ")
                            let oneArtist = NSEntityDescription.insertNewObject(forEntityName: "Artist", into: context)
                            oneArtist.setValue(artist.name, forKey: "name")
                            oneArtist.setValue(artist.followers, forKey: "followers")
                            oneArtist.setValue(artist.externalUrls?.spotify, forKey: "externalUrl")
                            
//                            for image in artist.images! {
//                                var imageObj = NSEntityDescription.insertNewObject(forEntityName: "Image", into: context)
//                                imageObj.setValue(image.width, forKey: "width")
//                                imageObj.setValue(image.height, forKey: "height")
//                                imageObj.setValue(image.url, forKey: "url")
//                                imageObj.setValue(oneArtist, forKey: "artist")
//
//                            }
                            
                            oneArtist.setValue(oneTrack, forKey: "onTrack")
                        }
                    }
                }
            } catch {
                print("CATCH: ", error)
            }
        }).resume()
    }
    
    func retrieveTracks() -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Track")
        var fetchedResults:[NSManagedObject]? = nil
        
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        return (fetchedResults)!
    }
    
    func clearCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Track")
        var fetchedResults:[NSManagedObject]
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            if fetchedResults.count > 0 {
                for result:AnyObject in fetchedResults {
                    context.delete(result as! NSManagedObject)
                }
            }
            
            try context.save()
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    // MARK: - Private Helpers
    private func presentAlertController(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
            controller.addAction(action)
            self.present(controller, animated: true)
        }
    }
}

// MARK: - SPTAppRemoteDelegate
extension ConnectMusicViewController: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
//        updateViewBasedOnConnected()
//        appRemote.playerAPI?.delegate = self
//        appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
//            if let error = error {
//                print("Error subscribing to player state:" + error.localizedDescription)
//            }
//        })
//        fetchPlayerState()
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
//        updateViewBasedOnConnected()
        lastPlayerState = nil
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
//        updateViewBasedOnConnected()
        lastPlayerState = nil
    }
}


// MARK: - SPTSessionManagerDelegate
extension ConnectMusicViewController: SPTSessionManagerDelegate {
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        if error.localizedDescription == "The operation couldn’t be completed. (com.spotify.sdk.login error 1.)" {
        } else {
            presentAlertController(title: "Authorization Failed", message: error.localizedDescription, buttonTitle: "Bummer")
        }
    }

    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        presentAlertController(title: "Session Renewed", message: session.description, buttonTitle: "Sweet")
    }

    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        appRemote.connectionParameters.accessToken = session.accessToken
        appRemote.connect()
    }
}

// MARK: - Networking
extension ConnectMusicViewController {

    func fetchAccessToken(completion: @escaping ([String: Any]?, Error?) -> Void) {
        let url = URL(string: "https://accounts.spotify.com/api/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let spotifyAuthKey = "Basic \((spotifyClientId + ":" + spotifyClientSecretKey).data(using: .utf8)!.base64EncodedString())"
        request.allHTTPHeaderFields = ["Authorization": spotifyAuthKey,
                                       "Content-Type": "application/x-www-form-urlencoded"]

        var requestBodyComponents = URLComponents()
        let scopeAsString = stringScopes.joined(separator: " ")

        requestBodyComponents.queryItems = [
            URLQueryItem(name: "client_id", value: spotifyClientId),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: responseCode!),
            URLQueryItem(name: "redirect_uri", value: redirectUri.absoluteString),
            URLQueryItem(name: "code_verifier", value: ""), // not currently used
            URLQueryItem(name: "scope", value: scopeAsString),
        ]

        request.httpBody = requestBodyComponents.query?.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,                              // is there data
                  let response = response as? HTTPURLResponse,  // is there HTTP response
                  (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                  error == nil else {                           // was there no error, otherwise ...
                      print("Error fetching token \(error?.localizedDescription ?? "")")
                      return completion(nil, error)
                  }
            let responseObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            print("Access Token Dictionary=", responseObject ?? "")
            completion(responseObject, nil)
        }
        task.resume()
    }
}
