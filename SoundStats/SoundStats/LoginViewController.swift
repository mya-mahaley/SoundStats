//
//  LoginViewController.swift
//  SoundStats
//
//  Created by Mya Mahaley on 10/15/22.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Auth.auth().addStateDidChangeListener() {
            auth, user in
            if user != nil {
                self.performSegue(withIdentifier: "signInSegueID", sender: nil)
                self.emailField.text = nil
                self.passwordField.text = nil
            }
        }
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
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) {
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
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    @IBAction func googleButtonPressed(_ sender: Any) {
    }
    @IBAction func facebookButtonPressed(_ sender: Any) {
    }
}
