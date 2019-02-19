//
//  CollectionViewController.swift
//  ShopApp
//
//  Created by Federico Mascoma on 04/10/18.
//  Copyright © 2018 Federico Mascoma. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

import FirebaseDatabase
import Firebase
import FirebaseStorage
import Foundation
import CoreLocation
import MapKit

class FavoriteCollectionViewController: UICollectionViewController {
    var miaArray: [DataSnapshot] = [] //[String] = []
    var lista: [String] = []
    
    override func viewDidAppear(_ animated: Bool) {
        self.miaArray = []
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
            let element = ((shop["favorite"] as? String)?.lowercased())?.components(separatedBy: ",")
            self.lista = element ?? []//element.components(separatedBy: ",")
            self.collectionView.reloadData()
            self.loadSnaps()
        })
    }
    func loadSnaps(){
        let ref = Database.database().reference()
        ref.child("shops").queryOrdered(byChild: "name").observe(.childAdded) { (snap) in
            let shop = (snap.value as! [String: Any])
            let name = (shop["name"] as! String).lowercased()
            print("name = ",name," lista = ",self.lista)
            if(self.lista.contains(name)){
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
        
        print("sono dentro collectionviewFAVORITE")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        let userDict = miaArray[indexPath.row].value as! [String: Any]
        //cell.immagine.image = UIImage(named: "profilo")
        cell.nome.text = (userDict["name"] as! String)
        cell.nome.font = UIFont.boldSystemFont(ofSize: 16.0)

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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = collectionView.indexPathsForSelectedItems
        let row = (indexPath?.first?.row) as? Int
        let element = miaArray[row ?? 0]
        if segue.destination is DettaglioCollectionViewController
        {
            let vc = segue.destination as? DettaglioCollectionViewController
            vc!.snapshot = element
        }
    }
    @IBAction func removeFromFavorite(_ sender: UIButton) {
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: buttonPosition)
        let userDict = self.miaArray[indexPath!.row].value as! [String: Any]
        let toremove = (userDict["name"] as! String).lowercased()
        
        let userID = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let favorite = value?["favorite"] as? String ?? ""
            if (favorite != ""){
                let lista = favorite.lowercased().components(separatedBy: ",")
                var newFavorite = ""
                for elem in lista {
                    if elem != toremove{
                        if newFavorite.count > 0{
                            newFavorite += ","
                        }
                        newFavorite+=elem
                    }
                }
                ref.child("users").child(userID!).updateChildValues(["favorite": newFavorite])
            }

        }) { (error) in
            print(error.localizedDescription)
        }
        print("eliminato ",toremove," dai favoriti")
        self.miaArray.remove(at: indexPath!.row)
        self.collectionView.reloadData()
    }
    
    
    
}
