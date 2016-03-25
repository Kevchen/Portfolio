//
//  PortfolioViewController.swift
//  Portfolio
//
//  Created by Daniel on 1/6/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import UIKit
import Charts
import CoreData

class PortfolioViewController: UITableViewController, NSFetchedResultsControllerDelegate{
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var netWorthLabel: UILabel!
    
    //let managedContext = DataController().managedObjectContext
    var itemArray = [AnyObject]()
    var stockArray = [NSManagedObject]()
    var fetchedResultsController: NSFetchedResultsController!
    
    //For calculating networth
    var initialCADWorth: Double = 0
    var initialUSDWorth: Double = 0
    var currentCADWorth: Double = 0
    var currentUSDWorth: Double = 0
    var USDCAD: Double = 0
    var CADUSD: Double = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFetchedResultsController()
        
        //set up refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("updatePrice"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        // Do any additional setup after loading the view.
        
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0]
        setChart(months, values: unitsSold)

        //dont display back button on main view
        self.navigationItem.setHidesBackButton(true, animated: false)

        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stockUpdated:", name: kNotificationStockUpdated, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currencyUpdated:", name: kNotificationCurrencyUpdated, object: nil)
        self.tableView.reloadData()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        
        self.tableView.reloadData()
        
        //get currency & stock price
        updateEverything()
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "Units Sold")
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        
        var colors: [UIColor] = []
        
        for _ in 0..<dataPoints.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        
        pieChartDataSet.colors = colors
        
        
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Units Sold")
        let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
        lineChartView.data = lineChartData
        
    }
    
    //Mark table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections!.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = self.fetchedResultsController.sections
        let sectionInfo = sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell?
        
        // Configure Table View Cell
        let stock = fetchedResultsController.objectAtIndexPath(indexPath)
        
        if let name = stock.valueForKey("name") as? String {
            cell!.textLabel!.text = name
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController.sections{
            let currentSection = sections[section]
            return currentSection.name
        }
        
        return nil
    }
    
    // MARK: Fetched Results Controller Delegate Methods
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Move:
            break
        case .Update:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Insert:
            if let indexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Update:
            //do nothing
            break;
        case .Move:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
            break;
        }
    }
    
    func initializeFetchedResultsController() {
        let request = NSFetchRequest(entityName: "Stock")
        let exchangeSort = NSSortDescriptor(key: "exchange", ascending: true)
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [exchangeSort, nameSort]
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moc = appDelegate.managedObjectContext
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: "exchange", cacheName: "rootCache")
        self.fetchedResultsController.delegate = self
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    // MARK: for passing name, symbol to next view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "portfolioToPortfolioDetail"){
            let destController = segue.destinationViewController as! PortfolioDetailViewController
            let indexPath = tableView.indexPathForSelectedRow!
            let selectedObject = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
            destController.itemToPass = selectedObject
        }

    }
    
    @IBAction func changeCurrency(sender: UIButton) {
        if(currencyButton.currentTitle == "CAD"){
            currencyButton.setTitle("USD", forState: UIControlState.Normal)
        }
        else{
            currencyButton.setTitle("CAD", forState: UIControlState.Normal)
        }
        displayNetWorth()
    }
    
    // MARK: calculate networth
    func calculateNetWorth(){
        let stockManager:StockManagerSingleton = StockManagerSingleton.sharedInstance
        
        for stock in fetchedResultsController.fetchedObjects! as [AnyObject]{
            //getting the purchase price of the portfolio
            let price:Double = stock.valueForKey("price") as! Double
            let numShare:Double = stock.valueForKey("numShare") as! Double
            let worth:Double = price * numShare
            let symbol:String = stock.valueForKey("symbol") as! String
            let exchange:String = stock.valueForKey("exchange") as! String
            
            if(exchange == "NASDAQ"){
                initialUSDWorth += worth
            }
            else if(exchange == "TSX"){
                initialCADWorth += worth
            }
            
            print("initialUSDWorth: \(initialUSDWorth), initialCADWorth: \(initialCADWorth)")
            
            //getting the current price of the portfolio
            stockManager.updateSymbol(symbol, exchangeToSearch: exchange)
        }
    }
    
    func stockUpdated(notification: NSNotification){
        let quote: NSDictionary = notification.userInfo![kNotificationStockUpdated] as! NSDictionary
        //print(quote)
        
        //NCM for NASDAQ, TOR for TSX in yahoo JSON
        let price = quote.objectForKey("LastTradePriceOnly") as? String
        let currency = quote.objectForKey("Currency") as? String
        var symbol:String = (quote.objectForKey("symbol") as? String)!
        
        var exchange:String = "TSX"
        if(currency == "USD"){
            exchange = "NASDAQ"
        }
        else if(currency == "CAD"){
            exchange = "TSX"
            //remove ".TO" in the symbol that yahoo returns, we don't need that
            symbol = String(symbol.characters.dropLast(3))
        }
        
        //find that particular stock in portfolio
        for stock in fetchedResultsController.fetchedObjects! as [AnyObject]{
            //found matching stock in portfolio
            if(stock.valueForKey("exchange") as? String == exchange &&
                stock.valueForKey("symbol") as? String == symbol){
                    
                let numShare:Double = stock.valueForKey("numShare") as! Double
                let worth:Double = Double(price!)! * numShare
                    
                if(exchange == "NASDAQ"){
                    currentUSDWorth += worth
                }
                else if(exchange == "TSX"){
                    currentCADWorth += worth
                }
                    
                //print("currentUSDWorth: \(currentUSDWorth), currentCADWorth: \(currentCADWorth)")
            }
        }
        displayNetWorth()
    }
    
    func currencyUpdated(notification: NSNotification){
        let quote: NSDictionary = notification.userInfo![kNotificationCurrencyUpdated] as! NSDictionary
        print(quote)
        
        let id = quote.valueForKey("id") as! String
        let rate = quote.valueForKey("Rate") as! String
        if(id == "CADUSD"){
            CADUSD = Double(rate)!
        }
        else if(id == "USDCAD"){
            USDCAD = Double(rate)!
        }
        
        print("CADUSD +\(CADUSD)+ USDCAD + \(USDCAD)")
        displayNetWorth()
    }
    
    func displayNetWorth(){
        //don't display when currency rate or current price is not available
        if(USDCAD==0 || CADUSD==0){
            return
        }
        
        //here we have everything
        let networth:Double
        if(currencyButton.currentTitle == "CAD"){
            networth = currentCADWorth + (USDCAD * currentUSDWorth)
        }
        else{
            networth = currentUSDWorth + (CADUSD * currentCADWorth)
        }
        
        netWorthLabel.text = String(format:"%.02f", networth)
    }
    
    func updateEverything(){
        //reset price
        currentCADWorth = 0
        currentUSDWorth = 0
        USDCAD = 0
        CADUSD = 0

        //get currency rate
        let stockManager:StockManagerSingleton = StockManagerSingleton.sharedInstance
        stockManager.updateCurrency("USD", currencyTo: "CAD")
        stockManager.updateCurrency("CAD", currencyTo: "USD")
        
        //calculate net worth
        calculateNetWorth()
    }
    
    func updatePrice(){
        print("refresh")
        updateEverything()
        refreshControl!.endRefreshing()
    }
}
