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

class CollectionViewController: UICollectionViewController, UISearchBarDelegate,CLLocationManagerDelegate  {
    let searchController = UISearchController(searchResultsController: nil)
    var miaArray: [DataSnapshot] = [] //[String] = []
   // @IBOutlet weak var CollectionViewCell1: UICollectionViewCell!
    var keyPhrase:String?
    var locationManager: CLLocationManager! //add for location
    var coordinations: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuraSearchBar()
        //retriveLocation()
        loadData()
    }
    //Configurazione ricerca searchbar
    func configuraSearchBar(){
        //searchController.searchBar.scopeButtonTitles = ["Where","Filter"]
        searchController.searchBar.delegate = self
        searchController.searchBar.text = keyPhrase
        //searchController.searchBar.showsScopeBar = true
        searchController.searchBar.barTintColor = #colorLiteral(red: 0.2108683288, green: 0.629958272, blue: 0.3803263903, alpha: 1)
        //searchController.searchBar.selectedScopeButtonIndex = 0
        searchController.searchBar.showsCancelButton = true
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        self.navigationItem.titleView = searchController.searchBar
        self.definesPresentationContext = true
        searchController.searchBar.sizeToFit()
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print("New scope index is now \(selectedScope)")
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    }
    //Configurazione localizzazione
    func retriveLocation(){
        print("RetriveLocationnnn")
        if (CLLocationManager.locationServicesEnabled())
        {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("retrieve coordinations")
        let userLocation:CLLocation = locations[0] as CLLocation // note that locations is same as the one in the function declaration
        manager.stopUpdatingLocation()// this prevents your device from constantly changing the Window to center
        self.coordinations = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,longitude: userLocation.coordinate.longitude)
        locationManager.requestWhenInUseAuthorization()
    }
    
    //caricamento dei dati nella collectionView
    func loadData(){
        print("trigger loadData")
        let ref = Database.database().reference()
        var names = [String]()
        var filtered = [String]()
        print("keyphrase : "+self.keyPhrase!+"\nLista : ")
        if(self.keyPhrase! == "all shops"){
            self.keyPhrase = " "
        }
        ref.child("shops").queryOrdered(byChild: "name").observe(.childAdded) { (snap) in
            let shop = (snap.value as! [String: Any])
            let name = (shop["name"] as! String).lowercased()
            filtered = []
            names = []
            let description = (shop["description"] as! String).lowercased()
            names.append(name+" "+description)
            filtered = names.filter{($0 as AnyObject).contains(self.keyPhrase!)}
            if filtered != []{
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        let userDict = miaArray[indexPath.row].value as! [String: Any]
        //cell.immagine.image = UIImage(named: "profilo")
        cell.nome.text = (userDict["name"] as! String)
        cell.nome.font = UIFont.boldSystemFont(ofSize: 16.0)

        cell.address.text = (userDict["address"] as! String)
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
    /*
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("indexpath = ")
        print(indexPath)
        performSegue(withIdentifier: "SearcCollectionToDettaglio", sender: indexPath.row)
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = collectionView.indexPathsForSelectedItems
        let row = (indexPath?.first?.row) as! Int
        let element = miaArray[row]
        if segue.destination is DettaglioCollectionViewController
        {
            //print(segue.destination)
            let vc = segue.destination as? DettaglioCollectionViewController
            vc!.snapshot = element
        }
    }
    
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
