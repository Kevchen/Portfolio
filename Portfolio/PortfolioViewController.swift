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

class PortfolioViewController: UITableViewController, NSFetchedResultsControllerDelegate, ChartViewDelegate{
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var netWorthLabel: UILabel!
    @IBOutlet weak var profitLossLabel: UILabel!
    @IBOutlet weak var dailyProfitLossLabel: UILabel!
    
    //let managedContext = DataController().managedObjectContext
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
        
        pieChartView.delegate = self
        
        //set up refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("updatePrice"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        // Do any additional setup after loading the view.
        
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
    
    // MARK: charts
//    func setChart(dataPoints: [String], values: [Double]) {
//        var dataEntries: [ChartDataEntry] = []
//        
//        for i in 0..<dataPoints.count {
//            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
//            dataEntries.append(dataEntry)
//        }
//        
//        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "Units Sold")
//        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
//        pieChartView.data = pieChartData
//        
//        var colors: [UIColor] = []
//        
//        for _ in 0..<dataPoints.count {
//            let red = Double(arc4random_uniform(256))
//            let green = Double(arc4random_uniform(256))
//            let blue = Double(arc4random_uniform(256))
//            
//            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
//            colors.append(color)
//        }
//        
//        pieChartDataSet.colors = colors
//        
//        
//        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Units Sold")
//        let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
//        lineChartView.data = lineChartData
//        
//        pieChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
//    }
    
    func setPieChart(){
        var dataEntries: [ChartDataEntry] = []
        var values = [Double]()
        var dataPoints = [String]()
        let displayCurrency:String = currencyButton.currentTitle!
        
        //get the values and dataPoints for pie chart
        for stock in fetchedResultsController.fetchedObjects! as [AnyObject]{
            let symbol:String = stock.valueForKey("symbol") as! String
            let exchange:String = stock.valueForKey("exchange") as! String
            let price:Double = stock.valueForKey("price") as! Double
            let numShare:Double = stock.valueForKey("numShare") as! Double
            
            var worth:Double = price * numShare
            //convert US stocks to CAD
            if(displayCurrency == "CAD" && exchange != "TSX"){
                worth *= USDCAD
            }
            //convert Canadian stocks to USD
            else if(displayCurrency == "USD" && exchange == "TSX"){
                worth *= CADUSD
            }
            
            //let worth:Double = price * numShare
            dataPoints.append(symbol)
            values.append(worth)
        }
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        
        var colors: [UIColor] = []
        for _ in 0..<dataPoints.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))

            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        pieChartDataSet.colors = colors
        
        pieChartView.descriptionText = "in $\(displayCurrency)"
        pieChartView.centerAttributedText = NSAttributedString(string: "Distribution")
        pieChartView.holeRadiusPercent = 0.35
        pieChartView.transparentCircleRadiusPercent = 0.40
        
        let highlighted: [ChartHighlight] = pieChartView.highlighted
        
        if(highlighted.count > 0){
            pieChartView.usePercentValuesEnabled = false
        }
        else{
            pieChartView.usePercentValuesEnabled = true
        }
        
        //IMPORTANT: set the chart data here since it's dynamic
        //or the legends won't display correctly
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        
        pieChartView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5)
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        //print("\(entry.value) in (months[entry.xIndex])")
        pieChartView.usePercentValuesEnabled = false
    }
    
    func chartValueNothingSelected(chartView: ChartViewBase){
        pieChartView.usePercentValuesEnabled = true
    }
    
    // Mark: table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections!.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = self.fetchedResultsController.sections
        let sectionInfo = sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! PortfolioCell
        
        // Configure Table View Cell
        let stock = fetchedResultsController.objectAtIndexPath(indexPath)
        print(stock)
        if let name = stock.valueForKey("name") as? String {
            cell.nameLabel.text = name
        }
        if let symbol = stock.valueForKey("symbol") as? String{
            cell.symbolLabel.text = symbol
        }
        if let change = stock.valueForKey("change") as? String{
            //set the rise and fall
            
            if(change.characters.first == "+"){
                cell.risefallLabel.textColor = UIColor(red: 0.0, green: 0.78, blue: 0.2, alpha: 1) //green
            }
            else{
                cell.risefallLabel.textColor = UIColor(red: 0.96, green: 0.26, blue: 0.21, alpha: 1) //red
            }
            //just show the percentage
            var changeString = change
            //changeString = String(changeString.characters.dropLast(1))
            //changeString = changeString.substringFromIndex(changeString.rangeOfString("(")!.startIndex)
            cell.risefallLabel.text = changeString
        }
    
        return cell
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
            
            if(exchange == "TSX"){
                initialCADWorth += worth
            }
            else {
                initialUSDWorth += worth
            }
            
            print("initialUSDWorth: \(initialUSDWorth), initialCADWorth: \(initialCADWorth)")
            
            //getting the current price of the portfolio
            stockManager.updateSymbol(symbol, exchangeToSearch: exchange)
        }
    }
    
    func stockUpdated(notification: NSNotification){
        let quote: NSDictionary = notification.userInfo![kNotificationStockUpdated] as! NSDictionary
        print(quote)
        
        //NMS for NASDAQ,
        //TOR for TSX
        //NYQ for NYSE
        //ASE for AMEX in yahoo JSON
        let price = quote.valueForKey("LastTradePriceOnly") as? String
        //let currency = quote.objectForKey("Currency") as? String
        var symbol:String = (quote.valueForKey("symbol") as? String)!
        var exchange:String = (quote.valueForKey("StockExchange") as? String)!
        
        switch(exchange){
        case "NMS":
            exchange = "NASDAQ"
            break
        case "NYQ":
            exchange = "NYSE"
            break
        case "ASE":
            exchange = "AMEX"
            break
        case "TOR":
            exchange = "TSX"
            //remove ".TO" in the symbol that yahoo returns, we don't need that
            symbol = String(symbol.characters.dropLast(3))
            break
        default:
            exchange = "N/A"
            break
        }
        
        //find that particular stock in portfolio
        for stock in fetchedResultsController.fetchedObjects! as [AnyObject]{
            //found matching stock in portfolio
            if(stock.valueForKey("exchange") as? String == exchange &&
                stock.valueForKey("symbol") as? String == symbol){
                    
                let numShare:Double = stock.valueForKey("numShare") as! Double
                let worth:Double = Double(price!)! * numShare
                
                if(exchange == "TSX"){
                    currentCADWorth += worth
                }
                else{
                    currentUSDWorth += worth
                }
                
                print("currentUSDWorth: \(currentUSDWorth), currentCADWorth: \(currentCADWorth)")
                    
                //set the change and percent
                let change: String = quote.objectForKey("Change") as! String
                let changeInPercent: String = quote.objectForKey("ChangeinPercent") as! String
                let changeString = change+" ("+String(changeInPercent.characters.dropFirst())+")"
                stock.setValue(changeString, forKey: "change")
                    
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let managedContext = appDelegate.managedObjectContext
                    
                do {
                    try managedContext.save()
                    
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
                    
                print(stock)
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
        
        //here we have everything, calculate current net worth
        let networth:Double
        if(currencyButton.currentTitle == "CAD"){
            networth = currentCADWorth + (currentUSDWorth * USDCAD)
        }
        else{
            networth = currentUSDWorth + (currentCADWorth * CADUSD)
        }
        
        //calculate daily profit or loss
        let profit:Double
        let profitString:String
        let percentString:String
        let profitLossString:String
        
        //store initial total worth in both CAD & USD
        let initialTotalWorthCAD: Double = initialCADWorth + (initialUSDWorth * USDCAD)
        let initialTotalWorthUSD: Double = initialUSDWorth + (initialCADWorth * CADUSD)
        
        //networth already in displayed currency
        if(currencyButton.currentTitle == "CAD"){
            profit = networth - initialTotalWorthCAD
            profitString = String(format: "%.02f", abs(profit))
            percentString = String(format: "%.02f", abs(profit/initialTotalWorthCAD)*100) + "%"
        }
        else{
            profit = networth - initialTotalWorthUSD
            profitString = String(format: "%.02f", abs(profit))
            percentString = String(format: "%.02f", abs(profit/initialTotalWorthUSD)*100) + "%"
        }
        
        if(profit > 0){
            profitLossString = "+ $\(profitString) (\(percentString))"
            profitLossLabel.textColor = UIColor(red: 0.0, green: 0.78, blue: 0.2, alpha: 1) //green
        }
        else{
            profitLossString = "- $\(profitString) (\(percentString))"
            profitLossLabel.textColor = UIColor(red: 0.96, green: 0.26, blue: 0.21, alpha: 1) //red
            
        }

        netWorthLabel.text = String(format:"%.02f", networth)
        profitLossLabel.text = profitLossString
        
        //update chart
        setPieChart()
    }
    
    func updateEverything(){
        //reset price
        currentCADWorth = 0
        currentUSDWorth = 0
        initialCADWorth = 0
        initialUSDWorth = 0
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
    
    //MARK: Swipe delete
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            
            //delete record
            let selectedObject = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
            managedContext.deleteObject(selectedObject)
            
            //core data save
            do {
                try managedContext.save()
                print("record is deleted")
                
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            updateEverything()
        }
    }

}
