//
//  ViewController.swift
//  NajlaAbothnainBeltExam
//
//  Created by Najla on 12/01/2022.
/*
 Red Belt Requirements (Need 8 or more for Red Belt)
 1#Users can register and login to the application (2)
 2#Table View has been implemented for the grocery Items (2)
 3#Sync grocery list items to table view (2)
 4#Users can create, edit, and delete items to the grocery list (2)
 5#Code is commented and formatted correctly (.5)
 6#Project warnings are kept to a minimum (.5)
 7#Project has zero errors (.5)
 
 Black Belt Requirements (Score above 9.5)
 8#Monitor online users (.5)
 9#Optional (Extra Feature) - Application data is available offline (offline support)
 10#Optional (Extra Feature) - Sign in with Facebook / Google
 */
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

//this achieves the 1st requirement: "Users can register and login to the application (2)"
class LogInViewController: UIViewController {
    
    //outlets:
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    //variables:
    let database = Database.database().reference()
    //let currentUser = FirebaseAuth.Auth.auth().currentUser!.email
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    //validation for password, Example:
    func validateFields() -> String? {
    // Check if the password is secure
    let cleanedPassword = PasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    if Utilities.isPasswordValid(cleanedPassword) == false {
        // Password NOT secure or correct
        let alert = UIAlertController(
          title: "Password NOT secure or correct",
          message: "Password must be 8 long charcter , Capital letter and special charcter ",
          preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
        //return " Password must be 8 long charcter , Capital letter and special charcter "
    }
        return nil
}//end validation
    
    override func viewDidAppear(_ animated: Bool) {
        //to clear text fields when loging out
        EmailTextField.text = ""
        PasswordTextField.text = ""
    }

    @IBAction func LogInButtonClicked(_ sender: UIButton) {
        //read whats in the text fields
        let email = EmailTextField.text!
        let password = PasswordTextField.text!
        
        //log the user w the creditanioal above to firebase
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
          if let error = error {
            let alert = UIAlertController(
              title: "Sign In Failed",
              message: error.localizedDescription,
              preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
          }
         else if (error == nil){
                self.performSegue(withIdentifier: "ToList", sender: Any?.self)
            }
            
            guard let resualt = user else {
                return
            }
            let userid = resualt.user
            self.database.child("Online-Users").child(userid.uid).setValue(["email":email])
        }
        
    }// end log in
    
    @IBAction func SingUpButtonClicked(_ sender: UIButton) {
        //read whats in the text fields
        let email = EmailTextField.text!
        let password = PasswordTextField.text!
        _ = validateFields()
        //sing the user w the creditanioal above to firebase
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
          if error == nil {
            //sends the information to login if there are no issues
            Auth.auth().signIn(withEmail: email, password: password)
          } else {
            print("Error in createUser: \(error?.localizedDescription ?? "")")
          }
        }
    }//end sing up
    
}//end class

