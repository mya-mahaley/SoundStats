//
//  LoginViewController.swift
//  SoundStats
//
//  Created by Mya Mahaley on 10/15/22.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import CoreData

class LoginViewController: UIViewController {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    var preferences: NSManagedObject!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.passwordField.isSecureTextEntry = true
        getPreferences()
        if(preferences != nil ){
            let autoLogin = preferences.value(forKey: "autoLogin") as? Bool
            if (autoLogin != nil && autoLogin == false) {
                let firebaseAuth = Auth.auth()
                do {
                    try firebaseAuth.signOut()
                } catch let signOutError as NSError {
                    print("Error signing out: %@", signOutError)
                }
            }
        }
        
        Auth.auth().addStateDidChangeListener() {
            auth, user in
            if user != nil {
                self.performSegue(withIdentifier: "signInSegueID", sender: nil)
                self.emailField.text = nil
                self.passwordField.text = nil
                self.passwordField.isSecureTextEntry = true
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {

    }
    
    @IBAction func signInButtonPressed(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!) {
            authResult, error in
            if let error = error as NSError? {
                let alert = UIAlertController(
                    title: "Issue Signing In",
                    message: "\(error.localizedDescription)",
                    preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)

            }
        }
    }
    @IBAction func registerButtonPressed(_ sender: Any) {
        let alert = UIAlertController(
            title: "Register",
            message: "Register",
            preferredStyle: .alert)
        alert.addTextField {
            tfName in
            tfName.placeholder = "Enter your name"
        }
        alert.addTextField {
            tfEmail in
            tfEmail.placeholder = "Enter your email"
        }
        alert.addTextField {
            tfPassword in
            tfPassword.isSecureTextEntry = true
            tfPassword.placeholder = "Enter your password"
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            _ in
            let nameField = alert.textFields![0]
            let emailField = alert.textFields![1]
            let passwordField = alert.textFields![2]
            
            if nameField.text == "" || emailField.text == "" || passwordField.text == "" {
                let alert = UIAlertController(
                    title: "Missing Information",
                    message: "Please fill in every field!",
                    preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            } else {
                Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) {
                    authResult, error in
                    if let error = error as NSError? {
                        let alert = UIAlertController(
                            title: "Issue Signing In",
                            message: "\(error.localizedDescription)",
                            preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    } else {
                        let user = Auth.auth().currentUser
                        let changeRequest = user?.createProfileChangeRequest()
                        changeRequest?.displayName = nameField.text!
                        changeRequest?.commitChanges { error in
                          if let error = error {
                            print(error)
                          } else {
                          }
                        }
                    }
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    //Code Adapted from https://stackoverflow.com/questions/68520136/how-to-pass-the-presenting-view-controller-and-client-id-for-your-app-to-the-goo
    @IBAction func googleButtonPressed(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting:self) { user, error in

          if let error = error {
              let alert = UIAlertController(
                  title: "Issue Signing In",
                  message: "\(error.localizedDescription)",
                  preferredStyle: .alert)
              
              alert.addAction(UIAlertAction(title: "OK", style: .default))
              self.present(alert, animated: true)
            return
          }

          guard
            let authentication = user?.authentication,
            let idToken = authentication.idToken
          else {
            return
          }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                            accessToken: authentication.accessToken)

            // Authenticate with Firebase using the credential object
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    let alert = UIAlertController(
                        title: "Issue Signing In",
                        message: "\(error.localizedDescription)",
                        preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }

    }
    private func getPreferences() {
        let fetchedPreferences = retrievePreferences()
        if(!fetchedPreferences.isEmpty) {
            preferences = fetchedPreferences[0]
        } else {
            preferences = nil
        }
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
