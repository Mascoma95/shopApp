//
//  ProfileViewController.swift
//  ShopApp
//
//  Created by Federico Mascoma on 20/11/18.
//  Copyright © 2018 Federico Mascoma. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKShareKit

class ProfileViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    var datiArray:[String] = []
    var ref = Database.database().reference()

    @IBOutlet var table: UITableView!
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var Hello: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView(frame: CGRect.zero)
        self.hideKeyboardWhenTappedAround()

        if FBSDKAccessToken.current() != nil {
            fetchFacebookProfile()
        }
        else{
            fetchProfile()
        }
    }
    
    //fetch info from firebase normal login
    func fetchProfile()
    {
        print("Im on fetchProfile\n\n")
        guard let currentUser = Auth.auth().currentUser else { return }
        self.ref.child("users").child(currentUser.uid).updateChildValues(
            ["display_email" : currentUser.email!]
        )
        let name = currentUser.displayName ?? "Nil"
        let email = "email:  "+currentUser.email!
        self.datiArray = ["name:   "+name,email]

        self.Hello.text = "Hello, \(name)"
    }
    
    //fetch info from firebase facebook login
    func fetchFacebookProfile()
    {
        print("im into fetch")
        
        let deviceScale = Int(UIScreen.main.scale)
        let width = 100 * deviceScale
        let height = 100 * deviceScale
        let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"first_name,last_name,email,picture.width(\(width)).height(\(height))"])
        
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(String(describing: error))")
            }
            else
            {
                guard let currentUser = Auth.auth().currentUser else { return }
                
                let data:[String:AnyObject] = result as! [String : AnyObject]
                let name = (data["first_name"]! as! String)
                let last_name = (data["last_name"]! as! String)
                let id = data["id"]! as! String
                let email = (data["email"]! as! String)
                self.datiArray = ["first_name:   "+name,"last_name:   "+last_name,"email:  "+email]
                self.Hello.text = "Hello, \(name)"
                
                let usersDB = Database.database().reference().child("users")
                var taken = true
                
                usersDB.observeSingleEvent(of: .value, with: { (snapshot) in
                    if !(snapshot.hasChild(currentUser.uid)) {
                        
                        taken = false
                        print("Username already taken...")
                        print("secondoTaken")
                        print(taken)
                    }
                    if !taken {
                        // Email registration
                        print("email registration")
                        usersDB.child(currentUser.uid).setValue(["email" : email,"name" : name,"last_name" : last_name])
                    }
                })
                

                print("\n\nTerzoTaken : ")
                print(taken)
                if !taken {
                    // Email registration
                    usersDB.child(currentUser.uid).setValue(["email" : email,"name" : name,"last_name" : last_name])
                }
                
                
                let imgURL: URL = URL(string: "http://graph.facebook.com/"+id+"/picture?type=large")!
                let request: URLRequest = URLRequest(url: imgURL)
                
                let session = URLSession.shared
                let task = session.dataTask(with: request, completionHandler: {
                    (data, response, error) -> Void in
                    if (error == nil && data != nil) {
                        func display_image() {
                            let userImage = UIImage(data: data!)
                            print("\n\nsetto immagine")
                            self.profilePicture.image = userImage
                        }
                        DispatchQueue.main.async(execute: display_image)
                    }
                })
                task.resume()
                self.table.reloadData()
                
            }
        })
    }
    
    @IBAction func logout_clicked(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "profileToLogin", sender: nil)
        } catch let error {
            print("L'ERRORE RIPORTATO E'::\n")
            print(error)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datiArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cella", for: indexPath)
        cell.textLabel?.text = datiArray[indexPath.row]
        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
