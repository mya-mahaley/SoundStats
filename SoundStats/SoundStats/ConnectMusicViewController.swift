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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func connectWithSpotifyPressed(_ sender: Any) {
        guard let sessionManager = sessionManager else { return }
        sessionManager.initiateSession(with: scopes, options: .default)
        performSegue(withIdentifier: "homePageSegueID", sender: nil)
    }
    
    func getUserTopTracks(completionHandler: @escaping(TrackItem?, Error?) -> Void) {
        print("calling spotify web api")
        guard let url = URL(string: "https://api.spotify.com/v1/me/top/tracks?time_range=medium_term&limit=50") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.accessToken!)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            guard error == nil else {
                print("ERROR: ", error!)
                completionHandler(nil, error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("NO RESPONSE")
                return
            }
            
            guard response.statusCode == 200 else {
                print("BAD RESPONSE: ", response.statusCode)
                print("BAD RESPONSE: ", String(decoding: data!, as: UTF8.self))
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
                completionHandler(tracks, nil)
            } catch {
                print("CATCH: ", error)
                completionHandler(nil, error)
            }
        })
        
        task.resume()
    }
    
    func retrieveTrackItems(completionHandler: ([NSManagedObject]?, Error?) -> Void) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackItem")
        var fetchedResults:[NSManagedObject]? = nil
        
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        completionHandler(fetchedResults, nil)
    }
    
    func loadTracksToCoreData(tracks: TrackItem, collectionName: String) {
        DispatchQueue.main.async {
            if tracks.items.count > 0 {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let trackItem = NSEntityDescription.insertNewObject(forEntityName: "TrackItem", into: context)
                trackItem.setValue(collectionName, forKey: "collectionName")
                
                if collectionName == "userTopTracks" {
                    var valences : [Double] = []
                    for track in tracks.items {
                        self.getCurrentTrackInfo(id: track.id, completionHandler: {
                            track, error in
                            guard let trackInfo = track else {
                                return
                            }
                            valences.append(trackInfo.valence)
                        })
                    }
                    
                    let valenceAvg = valences.reduce(0.0, {
                        return $0 + $1 / Double(tracks.items.count)
                    })
                    let audioFeature = NSEntityDescription.insertNewObject(forEntityName: "AudioFeature", into: context)
                    audioFeature.setValue(valenceAvg, forKey: "valence")
                }
                
                for track in tracks.items {
                    let oneTrack = NSEntityDescription.insertNewObject(forEntityName: "Track", into: context)
                    oneTrack.setValue(track.name, forKey: "name")
                    oneTrack.setValue(track.id, forKey: "id")
                    oneTrack.setValue(trackItem, forKey: "trackItem")
                    
                    for artist in track.artists {
                        let oneArtist = NSEntityDescription.insertNewObject(forEntityName: "Artist", into: context)
                        oneArtist.setValue(artist.name, forKey: "name")
                        oneArtist.setValue(artist.followers, forKey: "followers")
                        oneArtist.setValue(artist.externalUrls?.spotify, forKey: "externalUrl")
                        oneArtist.setValue(artist.id, forKey: "id")
                        oneArtist.setValue(oneTrack, forKey: "onTrack")
                    }
                }
                appDelegate.saveContext()
            }
        }
    }
    
    func getChartTracks(completionHandler: @escaping(Playlist?, Error?) -> Void) {
        print("calling spotify web api")
        let playlistID = "37i9dQZEVXbMDoHDwVN2tF" // global top 50 chart on Spotify
        guard let url = URL(string: "https://api.spotify.com/v1/playlists/\(playlistID)") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.accessToken!)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            guard error == nil else {
                print("ERROR: ", error!)
                completionHandler(nil, error)
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
                let playlist = try decoder.decode(Playlist.self, from: data)
                completionHandler(playlist, nil)
            } catch {
                print("CATCH: ", error)
                completionHandler(nil, error)
            }
        })
        
        task.resume()
    }
    
    func getCurrentTrackInfo(id: String, completionHandler: @escaping(AudioFeatures?, Error?) -> Void) {
        print("getting current track info")
        guard let url = URL(string: "https://api.spotify.com/v1/audio-features/\(id)") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.accessToken!)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            guard error == nil else {
                print("ERROR: ", error!)
                completionHandler(nil, error)
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
                let audioFeatures = try decoder.decode(AudioFeatures.self, from: data)
                completionHandler(audioFeatures, nil)
            } catch {
                print("CATCH: ", error)
                completionHandler(nil, error)
            }
        })
        
        task.resume()
    }
    
    func clearCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        var request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackItem")
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
        
        
        request = NSFetchRequest<NSFetchRequestResult>(entityName: "AudioFeature")
        fetchedResults = []
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
        print("app remote did establish connection")
        DispatchQueue.main.async {
            self.clearCoreData()
            self.getUserTopTracks(completionHandler: {
                tracks, error in
                guard error == nil else {
                    print("received error")
                    return
                }
                if(tracks != nil) {
                    print("loading user top tracks to core data")
                    self.loadTracksToCoreData(tracks: tracks!, collectionName: "userTopTracks")
                }
            })
            
            self.getChartTracks(completionHandler: {
                playlist, error in
                guard error == nil else {
                    print("error", error!)
                    return
                }

                var trackArray:[Track] = []
                for playlistTrackItem in playlist!.tracks.items {
                    trackArray.append(playlistTrackItem.track)
                }

                let globalChartTrackItem = TrackItem(items: trackArray)
                self.loadTracksToCoreData(tracks: globalChartTrackItem, collectionName: "globalChartTracks")
            })

            self.retrieveTrackItems(completionHandler: {
                nsManagedObjects, error in
                guard error == nil else {
                    print(error!)
                    return
                }

                for obj in nsManagedObjects! {
                    let collectionName = obj.value(forKey: "collectionName") as! String
                        var trackArray:[Track] = []

                    let tracks = obj.value(forKey: "tracks") as! NSSet
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
            })
        }
        
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        lastPlayerState = nil
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        lastPlayerState = nil
        print("FAILED TO CONNECT TO SPOTIFY")
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
