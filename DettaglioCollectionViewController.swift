//
//  DettaglioCollectionViewController.swift
//  ShopApp
//
//  Created by Federico Mascoma on 18/02/2019.
//  Copyright © 2019 Federico Mascoma. All rights reserved.
//

import UIKit

import FirebaseDatabase
import Firebase
import FirebaseStorage
import Foundation
import CoreLocation
import MapKit

private let reuseIdentifier = ["immagineCell","descrizioneCell","addReviewCell","recensioneCell"]

class DettaglioCollectionViewController: UICollectionViewController {
    var nomeShop:String = ""
    var ref = Database.database().reference()
    var snapshot:DataSnapshot?
    var miaArray:[String] = []
    var reviews:[String: DataSnapshot] = [:]

    override func viewDidLoad() {
        print("Im into dettaglio")
        super.viewDidLoad()
        retriveData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.miaArray.count)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //let userDict = self.miaArray!.value as! [String: Any]
        print("indexPath.row = ",indexPath.row)
        switch(indexPath.row){
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier[0], for: indexPath) as! immagineCell
            let userDict = self.snapshot!.value as! [String: Any]
            let review = (userDict["review"]) as? String ?? ""
            let description = (userDict["description"]) as? String ?? ""
            let name = (userDict["name"]) as? String ?? ""
            let path = (userDict["pictures"]) as! [String: Any]
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
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier[1], for: indexPath) as! descrizioneCell
            let element = self.miaArray[1].components(separatedBy: ",,")
            cell.Nome.text = element[0] as? String
            cell.Nome.font = UIFont.boldSystemFont(ofSize: 16.0)
            cell.Nome.textAlignment = NSTextAlignment.center

            cell.descrizione.text = element[1] as? String
            cell.descrizione.isEditable = false
            cell.addReview.setTitle("scrivi Recensione", for: UIControl.State.normal)
            cell.review.text = "Reviews"
            cell.review.font = UIFont.boldSystemFont(ofSize: 16.0)
            
            cell.address.text = element[2]
            self.nomeShop = element[0] as? String ?? ""
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier[3], for: indexPath) as! recensioneCell
            let e = self.miaArray[indexPath.row]
            let snap = self.reviews[e]
            let element = snap!.value as! [String: Any]
            cell.valoreVoto.text = "voto "+(element["voto"] as! String)
            cell.titolo.text = (element["title"] as! String)
            cell.commento.text = (element["review"] as! String)
            cell.user.text = (element["name"] as! String)

            return cell
        }
    }
    
    func retriveData(){
        let userDict = self.snapshot!.value as! [String: Any]
        let review = (userDict["review"]) as? String ?? ""
        let description = (userDict["description"]) as? String ?? ""
        let name = (userDict["name"]) as? String ?? ""
        self.miaArray.append("immagine")
        let address = (userDict["address"]) as? String ?? ""
        self.miaArray.append(name+",,"+description+",,"+address+",,Reviews,,Scrivi una recensione")
        if (review.count > 0){
            let lista = review.lowercased().components(separatedBy: ",")
            
            ref.child("reviews").queryOrdered(byChild: "code").observe(.childAdded) { (snap) in
                let review = (snap.value as! [String: Any])
                let code = (review["code"] as! String).lowercased()
                if lista.contains(code) {
                    self.miaArray.append(code)
                    self.reviews[code] = snap
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    @IBAction func addToFavorite(_ sender: UIButton) {
        print("sono in addToFavorite")
        let userID = Auth.auth().currentUser?.uid
        self.ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let favorite = value?["favorite"] as? String ?? ""
            print("sono in prima if")

            if (favorite == ""){
                self.ref.child("users").child(userID!).updateChildValues(["favorite": self.nomeShop])
            }
            else{
                let lista = favorite.lowercased().components(separatedBy: ",")
                if(!lista.contains(self.nomeShop.lowercased())){
                    let newFavorite = favorite+","+self.nomeShop
                    self.ref.child("users").child(userID!).updateChildValues(["favorite": newFavorite])
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ReviewCollectionViewController
        {
            //print(segue.destination)
            let vc = segue.destination as? ReviewCollectionViewController
            vc!.snapshot = self.snapshot
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
/*
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier1, for: indexPath)
        
        // Configure the cell
        
        return cell
    }
 */
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
