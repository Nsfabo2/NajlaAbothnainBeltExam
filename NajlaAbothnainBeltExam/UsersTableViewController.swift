//
//  UsersTableViewController.swift
//  NajlaAbothnainBeltExam
//
//  Created by Najla on 13/01/2022.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

struct User{
    var email:String = ""
}

//this achieves these requirements:
//8#Monitor online users (.5)
//9#Optional (Extra Feature) - Application data is available offline (offline support)
class UsersTableViewController: UITableViewController {
    //outlets:
    
    //variables:
    let userCell = "UserCell"
    var currentUsers: [User] = []
    //DB refrences
    let database = Database.database().reference()
    let currentUser = FirebaseAuth.Auth.auth().currentUser!.email
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 100
        fetchAllUsers()
    }
    
    @IBAction func SingOutBarButtonClicked(_ sender: Any) {
        guard let user = Auth.auth().currentUser, let userid = FirebaseAuth.Auth.auth().currentUser?.uid as? String
 else { return }
        let onlineRef = Database.database().reference(withPath: "online/\(user.uid)")
        onlineRef.removeValue { error, _ in
          if let error = error {
            print("Removing online failed: \(error)")
            return
          }
        let UserOut = UIAlertController(title: "Sing out ", message: "Are you sure you want logout? ", preferredStyle: .alert)
        let OutActionItem = UIAlertAction(title: "Yes", style: .default)
            {_ in
                               do {
                                 try Auth.auth().signOut()
                                 self.navigationController?.popToRootViewController(animated: true)
                                let CurrentuserList = self.database.child("Online-Users").child(userid)
                                   CurrentuserList.removeValue() 
                               } catch let error {
                                 print("Auth sign out failed: \(error)")
                               }
                        
                           }
                    
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            UserOut.addAction(OutActionItem)
            UserOut.addAction(cancelAction)
            self.present(UserOut, animated: true, completion: nil)
        }
    }//end SingOutBarButtonClicked
    
    func fetchAllUsers(){
        self.currentUsers.removeAll()
        database.child("Online-Users").observeSingleEvent(of: .value, with: {snapshot in
       guard let tasksData = snapshot.value as? [String: AnyObject] else{return }
            var fetchdata = User()
            for (_,value) in tasksData
            {
                fetchdata.email = value["email"] as! String
                self.currentUsers.append(fetchdata)
                self.tableView.reloadData()
            }
        })
    }//end fetchitem
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currentUsers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UsersCell", for: indexPath)
        let onlineUserEmail = currentUsers[indexPath.row]
        cell.textLabel?.text = onlineUserEmail.email
        return cell
        
    }//end cellForRowAt

}//end class
