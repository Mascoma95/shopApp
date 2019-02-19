//
//  ReviewCollectionViewController.swift
//  ShopApp
//
//  Created by Federico Mascoma on 18/02/2019.
//  Copyright © 2019 Federico Mascoma. All rights reserved.
//

import UIKit
import CommonCrypto

import FirebaseDatabase
import Firebase
import FirebaseStorage
import Foundation
import CoreLocation
import MapKit

private let reuseIdentifier = "newReviewCell"

class ReviewCollectionViewController: UICollectionViewController {
    
    @IBOutlet var textV: UITextView!
    var titleValue = ""
    var commentValue = ""
    let ref = Database.database().reference()
    var snapshot:DataSnapshot?
    @IBOutlet var slider: UISlider!
    @IBOutlet var valueValue: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! newReviewCell
        cell.title.text = "Title"
        cell.comment.text = "Comment"
        cell.value.text = "Value(1,10)"
        cell.send.setTitle("Send", for: UIControl.State.normal)
        self.slider = cell.sliderValue
        self.valueValue = cell.valueValue
        self.textV = cell.commentValue
        return cell
    }
    func MD5(_ string: String) -> String? {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        
        if let d = string.data(using: String.Encoding.utf8) {
            _ = d.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
                CC_MD5(body, CC_LONG(d.count), &digest)
            }
        }
        
        return (0..<length).reduce("") {
            $0 + String(format: "%02x", digest[$1])
        }
    }
    
    @IBAction func sendAction(_ sender: UIButton) {
        let sliderValue = self.valueValue.text ?? ""
        if(self.titleValue.count > 0) && (self.textV.text.count > 0) && (self.valueValue.text != "1-10") && (sliderValue.count > 0){
            self.commentValue = self.textV.text
            let userID = (Auth.auth().currentUser?.uid)!
            let date = NSDate(timeIntervalSince1970: 1415637900)
            let dateFormatter = DateFormatter()
            let localDate = dateFormatter.string(from: date as Date)
            let input = MD5(String(localDate+userID+self.titleValue+self.textV.text))
            let hashedValue = input!
            
            let shopDict = self.snapshot!.value as! [String: Any]
            let nameShop = shopDict["name"]
            let snapkey = self.snapshot?.key

            ref.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let review = value?["review"] as? String ?? ""
                if (review != ""){
                    let newReview = review+","+hashedValue
                    self.ref.child("users").child(userID).updateChildValues(["review": newReview])
                }
                else{
                    self.ref.child("users").child(userID).updateChildValues(["review": hashedValue])
                }
                let userName = value?["name"] as? String ?? ""
                self.ref.child("reviews").child(hashedValue).setValue(["code" : hashedValue,"name" :userName, "title" : self.titleValue,"review" : self.commentValue,"voto" : self.valueValue.text!+"/10","shop" : snapkey])
            }) { (error) in
                print(error.localizedDescription)
            }
            
            
            ref.child("shops").child(snapkey!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let review = value?["review"] as? String ?? ""
                if (review != ""){
                    let newReview = review+","+hashedValue
                    self.ref.child("shops").child(snapkey!).updateChildValues(["review": newReview])
                }
                else{
                    self.ref.child("shops").child(snapkey!).updateChildValues(["review": hashedValue])
                }
                
            }) { (error) in
                print(error.localizedDescription)
            }
            
            
            _ = navigationController?.popViewController(animated: true)
            print("added Review")
        }
        else{
                print("sono nell'else\n")
            let alert = UIAlertController(title: "Error Data", message: "You should write correct data", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            print("Inserisci dati")
        }
            
        
    }
    @IBAction func changeValue(_ sender: UISlider) {
        self.valueValue.text = String(Int(self.slider.value * 10))
    }
    @IBAction func updateTitle(_ sender: UITextField) {
        self.titleValue = sender.text ?? ""
    }
    
    
}
