

import UIKit
import FirebaseAuth
import FacebookLogin
import FacebookCore
import FBSDKLoginKit
import FBSDKShareKit

class LoginViewController: UIViewController,FBSDKLoginButtonDelegate{

    @IBOutlet var tf_email: UITextField!
    @IBOutlet var tf_password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        let loginButton = FBSDKLoginButton()
        loginButton.delegate = self
        loginButton.center = CGPoint(x:UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY+100)
        view.addSubview(loginButton)
        

    }
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("sono al LoginButton\n\n")

        if let error = error {
            print(error.localizedDescription)
            return
        }
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        //fetchFacebookProfile()
        
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if error != nil {
                // ...
                return
            }
            
            //print(credential)
            // User is signed in
            print("^Credential::\nVai al Login\n\n")
            self.performSegue(withIdentifier: "LoginToProfile", sender: nil)
        }
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    //
 
    //
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func classicLogin_clicked(_ sender: UIButton) {
        
        guard let email = self.tf_email.text, !email.isEmpty else {
            print("\n [Error] Write Username \n")
            return
            
        }
        
        guard let password = self.tf_password.text, !password.isEmpty else {
            print("\n [Error] Write Password \n")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            guard error == nil else {
                print(" \n [ERROR] Can't Sign In \n   withError: \(error!._code, error!.localizedDescription) \n")
                
                let alert = ErrorMessageView.createAlert(title: "Can't Sign In!", message: "withError: \(error!._code, error!.localizedDescription)")
                self.show(alert, sender: nil)
                
                return
            }
            
            print("\n Welcome \(user!)")
            self.performSegue(withIdentifier: "LoginToProfile", sender: nil)
            
        })
        
    }
    
    @IBAction func signUp_clicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueToSignup", sender: nil)
    }
    
    
}
