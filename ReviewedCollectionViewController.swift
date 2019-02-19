//
//  ReviewedCollectionViewController.swift
//  ShopApp
//
//  Created by Federico Mascoma on 18/02/2019.
//  Copyright © 2019 Federico Mascoma. All rights reserved.
//

import UIKit

private let reuseIdentifier = "reviewedCell"

import FirebaseDatabase
import Firebase
import FirebaseStorage
import Foundation
import CoreLocation
import MapKit

class ReviewedCollectionViewController: UICollectionViewController {
    var miaArray: [DataSnapshot] = [] //[String] = []
    var lista: [String] = []
    
    override func viewDidAppear(_ animated: Bool) {
        self.miaArray = []
        print("viedidappearREVIEWED")
        loadData()
    }
    /*
     override func viewDidLoad() {
     super.viewDidLoad()
     loadData()
     self.collectionView.reloadData()
     //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
     // Do any additional setup after loading the view.
     }
     */
    func loadData(){
        print("trigger loadData")
        let ref = Database.database().reference()
        let userID : String = (Auth.auth().currentUser?.uid)!
        print("Current user ID is" + userID)
        
        ref.child("users").child(userID).observeSingleEvent(of: .value, with: {(snap) in
            let shop = (snap.value as! [String: Any])
            let element = ((shop["review"] as? String)?.components(separatedBy: ","))
            self.lista = element ?? []//element.components(separatedBy: ",")
            self.collectionView.reloadData()
            self.loadSnaps()
        })
    }
    func loadSnaps(){
        let ref = Database.database().reference()
        ref.child("reviews").queryOrdered(byChild: "code").observe(.childAdded) { (snap) in
            let shop = (snap.value as! [String: Any])
            let code = (shop["code"] as! String)

            if(self.lista.contains(code)){
                print("aggiunto")
                self.miaArray.append(snap)
            }
            self.collectionView.reloadData()
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return miaArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("sono dentro collectionviewREVIEWED ")
        print("self.miaarray.count ",self.miaArray.count)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! reviewedCell
        let userDict = miaArray[indexPath.row].value as! [String: Any]
        
        cell.commento.text = (userDict["review"] as! String)
        cell.titolo.text = (userDict["title"] as! String)
        cell.voto.text = "voto : "+(userDict["voto"] as! String)
        let shopkey = userDict["shop"]!
        let ref = Database.database().reference()
        
        ref.child("shops").child(shopkey as! String).observeSingleEvent(of: .value, with: { (snap) in
            let shop = snap.value as? NSDictionary
            let name = (shop?["name"] as? String)
            cell.nome.text = name
            cell.nome.font = UIFont.boldSystemFont(ofSize: 16.0)

            let path = (shop?["pictures"]) as! [String: Any]
            let imageName = path["pic1"] as! String
            let imageURL = Storage.storage().reference(forURL: "gs://shopapp-f3d3r1c0.appspot.com/").child(imageName)
            imageURL.downloadURL(completion: { (url, error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                    return
                }
                URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    guard let imageData = UIImage(data: data!) else { return }
                    DispatchQueue.main.async {
                        let size = CGSize(width: 100.0, height: 60.0)
                        cell.immagine.image = imageData
                        cell.immagine.sizeThatFits(size)
                    }
                }).resume()
            })
        })
        return cell
    }
    @IBAction func removeReview(_ sender: UIButton) {
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: buttonPosition)
        let userDict = self.miaArray[indexPath!.row].value as! [String: Any]
        let toremove = (userDict["code"] as! String)
        let shopToRemove = (userDict["shop"] as! String)

        let userID = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let review = value?["review"] as? String ?? ""
            if (review != ""){
                let lista = review.components(separatedBy: ",")
                var newReview = ""
                for elem in lista {
                    if elem != toremove{
                        if newReview.count > 0{
                            newReview += ","
                        }
                        newReview+=elem
                    }
                }
                ref.child("users").child(userID!).updateChildValues(["review": newReview])
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        ref.child("shops").child(shopToRemove).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let review = value?["review"] as? String ?? ""
            if (review != ""){
                let lista = review.components(separatedBy: ",")
                var newReview = ""
                for elem in lista {
                    if elem != toremove{
                        if newReview.count > 0{
                            newReview += ","
                        }
                        newReview+=elem
                    }
                }
                ref.child("shops").child(shopToRemove).updateChildValues(["review": newReview])
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        ref.child("reviews").child(toremove).removeValue()
        
        print("eliminato ",toremove," da reviewed")
        self.miaArray.remove(at: indexPath!.row)
        self.collectionView.reloadData()
    }
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = collectionView.indexPathsForSelectedItems
        let row = (indexPath?.first?.row) as! Int
        let element = miaArray[row]
        if segue.destination is DettaglioCollectionViewController
        {
            let vc = segue.destination as? DettaglioCollectionViewController
            vc!.snapshot = element
        }
    }
    */
}
