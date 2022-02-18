//
//  ShoppingListTableViewController.swift
//  NajlaAbothnainBeltExam
//
//  Created by Najla on 13/01/2022.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
//this achieves these requirements:
//2#Table View has been implemented for the grocery Items (2)
//3#Sync grocery list items to table view (2)
//4#Users can create, edit, and delete items to the grocery list (2)
class ShoppingListTableViewController: UITableViewController {
    //outlets:
    
    //variables:
    let ToUsers = "ToUsers" //this for segue ShoppingList -> Users
    var ItemsList: [ShoppingListItem] = []
    var CurrentOnlineUsers = UIBarButtonItem()
    
    //DB refrences
    let database = Database.database().reference()
    let currentUser = FirebaseAuth.Auth.auth().currentUser!.email

    override func viewDidLoad() {
        super.viewDidLoad()
        //Welcome Alert!
        let alert = UIAlertController(
         title: "Welcome",
         message: "Hello!\(currentUser ?? "")",//\(user!.email)
          preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
        
        tableView.allowsMultipleSelectionDuringEditing = false
        
        //nav bar edits:
        CurrentOnlineUsers = UIBarButtonItem(
          title: "1",
          style: .plain,
          target: self,
          action: #selector(UsersBarButtonClicked))
        CurrentOnlineUsers.tintColor = .white
        navigationItem.leftBarButtonItem = CurrentOnlineUsers
        
        //load them in Tableview
        fetchAllItems()
        
        tableView.rowHeight = 100
    }//endviewDidLoad
    
    //to access the current online users -> segue preoare
    @objc func UsersBarButtonClicked() {
      performSegue(withIdentifier: ToUsers, sender: nil)
    }
    
    
    //4.1 Users can create items to the grocery list (2)
    @IBAction func AddButtonClicked(_ sender: AnyObject) {
        //alert -> DB
    let addItem = UIAlertController(title: "Shooping List",
                                    message: "What do you wanna buy?",
                                    preferredStyle: .alert)
    addItem.addTextField(configurationHandler: nil)
    let Items =  addItem.textFields![0]
    Items.placeholder = "Enter item"
     //Save clicked
    let saveAction = UIAlertAction(title: "Save", style: .default)
                          {
                              _ in
                              self.addItems(Item:Items.text!,user: self.currentUser!)
                              self.fetchAllItems()
                          }
     //cancel clicked
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    addItem.addAction(saveAction)
    addItem.addAction(cancelAction)
    present(addItem, animated: true, completion: nil)
    }//end Add Button
    
    //add functions that deals w DB
    func addItems (Item: String , user: String){
        let itemId = UUID().uuidString
        var items: ShoppingListItem = ShoppingListItem()
        items.ItemName = Item
        items.addedBy = user
        let groceryList =  ["ItemID":itemId ,"item": items.ItemName ,"Addedby": items.addedBy,"Completed": items.complete] as [String : Any]
        database.child("grocery-list-items").child(itemId).setValue(groceryList)
    }//end addItems

    // Function to retrieve all data from firebase
    func fetchAllItems(){
        self.ItemsList.removeAll()
        database.child("grocery-list-items").observeSingleEvent(of: .value, with: {snapshot in
       guard let tasksData = snapshot.value as? [String: AnyObject] else{return }
            var fetchitem = ShoppingListItem()
            for (_,value) in tasksData
            {
                fetchitem.ItemName = (value["item"] as! String)
                fetchitem.addedBy = (value["Addedby"] as! String)
                fetchitem.ItemID = (value["ItemID"] as! String)
                fetchitem.complete = (value["Completed"] as! Bool)
                self.ItemsList.append(fetchitem)
                self.tableView.reloadData()
            }
        })
    }//end fetchitem

    // MARK: - Table view data source
    /*override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }*/

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ItemsList.count
    }

    //4.2 Users can edit items to the grocery list (2) (change item name , complete item)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //to display the items and users added them in lables
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ShoppingListCell
        cell.ItemTitle.text = ItemsList[indexPath.row].ItemName
        cell.ItemSubTitle.text = ItemsList[indexPath.row].addedBy
        cell.ItemCompleted.isHidden = !ItemsList[indexPath.row].complete
        return cell
    }
    //when you buy the item you check it out from the list
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ShoppingListCell
        let itemEdit = ItemsList[indexPath.row].ItemName
        let email = ItemsList[indexPath.row].addedBy
        let editItem = UIAlertController(title: "Edit item ", message: "You will update this item  ", preferredStyle: .alert)
        editItem.addTextField{(Textfield) in
        Textfield.text = itemEdit
                }
        //update clicked
         let updateAction = UIAlertAction(title: "Update", style: .default)
                       {
                           _ in
        if self.currentUser != email {
        let CantEditiAlert = UIAlertController(title: "Warning ", message: "You are't allowed to edit", preferredStyle: .alert)
        CantEditiAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(CantEditiAlert, animated: true, completion: nil)
                               
            }else{
        let update = editItem.textFields![0].text
        let ID = self.ItemsList[indexPath.row].ItemID
        self.editItems(path: ID, Item: "\(String(describing: update!))", user: "\(String(describing: self.currentUser!))")
        self.fetchAllItems()
                           }

                       }//end save
        let CheckAction = UIAlertAction(title: "Check", style: .default)
        {_ in
        if self.currentUser != email {
        let CantCheckAlert = UIAlertController(title: "Warning ", message: "You are't allowed to checkout this item", preferredStyle: .alert)
            CantCheckAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(CantCheckAlert, animated: true, completion: nil)
                                   
                }else{
                          print("11")
            let data = ["Completed": true ]
            self.database.child("grocery-list-items").child(self.ItemsList[indexPath.row].ItemID).updateChildValues(data)
            self.fetchAllItems()
                      }
        }
        //cancel clicked
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                tableView.reloadData()
                editItem.addAction(CheckAction)
                editItem.addAction(updateAction)
                editItem.addAction(cancelAction)
                present(editItem, animated: true, completion: nil)
        
    }//end tableView -> didselcetrowat

    //edit functions that deals w DB
    func editItems (path:String,Item: String , user: String ){
        //Function to edite item in realtime database
        var items: ShoppingListItem = ShoppingListItem()
        items.ItemName = Item
        items.addedBy = user
        let groceryTasks = ["ItemID": path,"item": items.ItemName , "Addedby": items.addedBy , "Completed": items.complete] as [String : Any]
        database.child("grocery-list-items").child(path).setValue(groceryTasks)
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    //4.3 Users can delete items to the grocery list (2)
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let email = ItemsList[indexPath.row].addedBy
        let ItemToDelete = ItemsList[indexPath.row]
        if self.currentUser != email {
        let CantDeleteAlert = UIAlertController(title: "Warning ", message: "You are't allowed to delete this item ", preferredStyle: .alert)

            CantDeleteAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(CantDeleteAlert, animated: true, completion: nil)
        } else{
            if editingStyle == .delete {
                self.deleteItems(path: ItemToDelete.ItemID)
                self.fetchAllItems()
            }
        }
    }//end tableView -> editingStyle
    
    //delete functions that deals w DB
    func deleteItems (path:String){
        database.child("grocery-list-items/\(path)").setValue(nil)
    }//end deleteItems
    

}//end class
