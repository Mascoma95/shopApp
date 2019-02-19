
import UIKit
import Firebase

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
class HomeViewController: UIViewController {
    
    @IBOutlet var lb_helloUsername: UILabel!
    @IBOutlet var tf_updateUsername: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let ref = Database.database().reference()
        
        ref.child("users").child(currentUser.uid).updateChildValues(
            ["display_email" : currentUser.email!]
        )
        
        let name = currentUser.displayName ?? "Nil"
        self.lb_helloUsername.text = "Hello, \(name)"
        
        print("\n___________________\n\n")
        print("Im in HOMEWVIEW")
        print(lb_helloUsername.text)
        print("\n___________________\n\n")
        
    }
    
    @IBAction func updateNow_clicked(sender: UIButton) {
        
        guard let username = self.tf_updateUsername.text, !username.isEmpty else {
            print("\n [Error] Write Username \n")
            return
        }
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let changeRequest = currentUser.createProfileChangeRequest()
        changeRequest.displayName = username
        
        changeRequest.commitChanges { (error) in
            guard error == nil else {
                print(" \n \n Problem with ProfileChangeRequest \n \n   (\(String(describing: error?.localizedDescription)))")
                return
            }
            
            print("\n \n ProfileChangeRequest OK \n\n")
            
            
            self.lb_helloUsername.text = "Hello, \(currentUser.displayName!)"
            
            let ref = Database.database().reference()
            ref.child("users").child(currentUser.uid).updateChildValues(
                ["name" : currentUser.displayName!]
            )
            self.performSegue(withIdentifier: "HomeToProfile", sender: nil)

        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func logout_clicked(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
            self.show(vc, sender: nil)
        } catch let error {
            print("L'ERRORE RIPORTATO E'::\n")
            print(error)
        }

    }
}
