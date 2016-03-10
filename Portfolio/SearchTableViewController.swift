//
//  SearchTableViewController.swift
//  Portfolio
//
//  Created by Daniel on 1/5/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate{
  
    
    var searchArray = [StockItem]()
    var filterArray = [StockItem]()
    
    //used to pass data between views
    var nameToPass:String!
    var symbolToPass:String!
    var exchangeToPass:String!
    
    var resultSearchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        //set up search controller
        self.resultSearchController.loadViewIfNeeded()
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.delegate = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        self.resultSearchController.searchBar.placeholder = "Search"
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
        self.resultSearchController.searchBar.setValue("X", forKey: "_cancelButtonText")
        
        insertJSONToSearchArray("TSX", exchange: "TSE")
        insertJSONToSearchArray("NASDAQ", exchange: "NASDAQ")
        
        //hide search bar when push to detail view
        self.definesPresentationContext = true
        /*
        //added items
        self.searchArray += [StockItem(name: "TD Canada Trust", symbol:  "TD", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "Apple Inc", symbol: "AAPL", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "Google", symbol:  "GOOG", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "General Motors", symbol:  "GM", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "Facebook", symbol:  "FB", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "Tesla Motors", symbol:  "TSLA", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "Microsoft", symbol:  "MSFT", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "LinkedIn Corp", symbol:  "LNKD", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "Intel", symbol:  "INTC", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "Nike", symbol:  "NKE", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "NVIDIA", symbol:  "NVDA", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "TD Canada Trust", symbol:  "TD", exchange: "TSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "Magna", symbol:  "MG", exchange: "TSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "Celestica", symbol:  "CLS", exchange: "TSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "Royal Bank Of Canada", symbol:  "RY", exchange: "TSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "Air Canada", symbol:  "AC", exchange: "TSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        */
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //to make the table reload data first to avoid seeing "flashing" when navigating back from next view
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.resultSearchController.active = true
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
    
    //go back to home view when press X on search bar
    func didDismissSearchController(searchController: UISearchController) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    //Mark table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.resultSearchController.active{
            return self.filterArray.count
        }
        else{
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SearchCell
        
        
        if self.resultSearchController.active && filterArray.isEmpty == false{
            
            cell.nameLabel.text =  self.filterArray[indexPath.row].name
            cell.symbolLabel.text =  self.filterArray[indexPath.row].symbol
            cell.exchangeLabel.text = self.filterArray[indexPath.row].exchange
            
            if(cell.exchangeLabel.text == "NYSE"){
                cell.exchangeLabel.backgroundColor = UIColor.blueColor()
            }
            else if(cell.exchangeLabel.text == "TSE"){
                cell.exchangeLabel.backgroundColor = UIColor.magentaColor()
            } 
            
        }
        else
        {
            //cell!.textLabel?.text = self.myportfolio.stockArray[indexPath.row].name
        }
        
        return cell
    }
    

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.filterArray.removeAll(keepCapacity: false)
        
        //let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        //let array = (self.searchArray as [StockItem]).filteredArrayUsingPredicate(searchPredicate)
    
        let searchText:String = searchController.searchBar.text!.lowercaseString
        filterArray = self.searchArray.filter(){
            ($0.symbol.lowercaseString).containsString(searchText)
        }
        
        self.tableView.reloadData()
    }
    
    func insertJSONToSearchArray(file: String, exchange: String){
        //parsing in the json file
        
        guard let path = NSBundle.mainBundle().pathForResource(file, ofType: "json") else {
            print("Error finding file")
            return
        }
        
        let jsonData = NSData(contentsOfFile: path)
        do {
            let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            guard let stocks = jsonResult["stocks"] as? [[String: AnyObject]] else {return}
            for stock in stocks {
                guard let ticker = stock["Ticker"] as? String,
                    let name = stock["Stock Name"] as? String,
                    let sector = stock["Sector"] as? String
                    else {return}
                self.searchArray += [StockItem(name: name, symbol:  ticker, exchange: exchange, sector: sector, numShare: 0, purchaseDate: NSDate(), price: 0)]
                
            }
            
        } catch {print("Error")}
    }
    
    //for passing name, symbol to next view
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let stockManager:StockManagerSingleton = StockManagerSingleton.sharedInstance
        stockManager.printTest()
        
        
        // Get cell name and symbol
        let indexPath = tableView.indexPathForSelectedRow
        let cell = tableView.cellForRowAtIndexPath(indexPath!) as! SearchCell
    
        nameToPass = cell.nameLabel.text
        symbolToPass = cell.symbolLabel.text
        exchangeToPass = cell.exchangeLabel.text
        
        performSegueWithIdentifier("searchToDetail", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "searchToAddToPortfolio"){
            if let button = sender as? UIButton {
                let destController = segue.destinationViewController as! AddToPortfolioViewController
                let cell = button.superview?.superview as! SearchCell
                destController.nameToPass = cell.nameLabel.text
                destController.symbolToPass = cell.symbolLabel.text
                destController.exchangeToPass = cell.exchangeLabel.text
            }
        }
        else if(segue.identifier == "searchToDetail"){
            let destController = segue.destinationViewController as! DetailViewController
            destController.nameToPass = nameToPass
            destController.symbolToPass = symbolToPass
            destController.exchangeToPass = exchangeToPass
        }
    }
    
    
}
