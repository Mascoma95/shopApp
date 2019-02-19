

import UIKit
import FirebaseAuth

class SignupViewController: UIViewController {
    
    @IBOutlet var tf_email: UITextField!
    @IBOutlet var tf_password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func signup_clicked(_ sender: UIButton) {
        guard let email = self.tf_email.text, !email.isEmpty else {
            print("\n [Error] Write Username \n")
            return
        }
        
        guard let password = self.tf_password.text, !password.isEmpty else {
            print("\n [Error] Write Password \n")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            guard error == nil else {
                print(" \n [ERROR] Can't Sign In \n   withError: \(error!._code, error!.localizedDescription) \n")
                return
            }
            
            // print("\n Welcome \(user!.email!)")
            print("\n Welcome \(user!)")
            self.performSegue(withIdentifier: "SignUpToHome", sender: nil)
            
        }
        
    }
    
    @IBAction func backToLogin_clicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
