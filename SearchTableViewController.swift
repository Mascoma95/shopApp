//
//  SearchTableViewController.swift
//  ShopApp
//
//  Created by Federico Mascoma on 05/10/18.
//  Copyright © 2018 Federico Mascoma. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseStorage
import Foundation
import CoreLocation
import MapKit

class SearchTableViewController: UITableViewController, UISearchBarDelegate {
    var userInput:String?
    var filteredData = [String]()
    var data = [String]()
    var miaArray:[String] = []
    var datiArray:[String] = []
    var snapArray: [DataSnapshot] = [] //[String] = []

    let searchController = UISearchController(searchResultsController: nil)
    var parola:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        caricaDati()
        configuroBarra()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
   
    
    func caricaDati(){
        miaArray = ["all shops","nike","rock","adidas","dolce e gabana","gucci","emporio armani jeans","federico mascoma","calvin klain jeans","snowboard","scii","neve"]
        datiArray = miaArray
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datiArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cella", for: indexPath)
        cell.textLabel?.text = datiArray[indexPath.row]
        return cell
    }
    
    func configuroBarra(){
        self.searchController.searchResultsUpdater = self as? UISearchResultsUpdating
        self.searchController.delegate = self as? UISearchControllerDelegate
        self.searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "brand,name or kind of shop..."
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        
        self.navigationItem.titleView = searchController.searchBar
        
        self.definesPresentationContext = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("premutoBottone :\n\n")
        // Here I'm trying catch user input
        self.userInput = self.searchController.searchBar.text?.lowercased()
        performSegue(withIdentifier: "GoToSearch", sender: self)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let text = searchController.searchBar.text?.lowercased(), text != "" {
            self.snapArray = []
            print("trigger loadData")
            let ref = Database.database().reference()
            ref.child("shops").queryOrdered(byChild: "name").observe(.childAdded) { (snap) in
                let shop = (snap.value as! [String: Any])
                let name = (shop["name"] as! String).lowercased()
                self.datiArray.append(name)
                self.snapArray.append(snap)
            }
            self.filteredData = self.datiArray.filter{($0 as AnyObject).contains(text)}
            self.tableView.reloadData()

        } else {
            self.filteredData = self.miaArray
        }
        let uniqueUnordered = Array(Set(self.filteredData))
        self.filteredData = uniqueUnordered
        self.datiArray = self.filteredData
        self.tableView.reloadData()

    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("premutoBottone sono su prepare:\n\n")
        guard segue.identifier != nil else { return }
        // Get the index path from the cell that was tapped
        let indexPath = tableView.indexPathForSelectedRow
        // Get the Row of the Index Path and set as index
        var element:String?
        if(indexPath != nil){
            element = datiArray[(indexPath?.row)!]
        }
        else{
            element = self.userInput
        }
        if let CollectionViewController = segue.destination as? CollectionViewController{
            CollectionViewController.keyPhrase = element
        }
    }

}
