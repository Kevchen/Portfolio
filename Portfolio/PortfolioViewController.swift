//
//  PortfolioViewController.swift
//  Portfolio
//
//  Created by Daniel on 1/6/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import UIKit
import Charts

class PortfolioViewController: UITableViewController{
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var lineChartView: LineChartView!
    
    var searchArray = [StockItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0]
        
        setChart(months, values: unitsSold)
        
        
        //stuff for portfolio table view
        self.searchArray += [StockItem(name: "TD Canada Trust", symbol:  "TD", exchange: "NYSE" ,numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "Apple Inc", symbol: "APPL", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "Google", symbol:  "GOOG", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "General Motors", symbol:  "GM", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "Facebook", symbol:  "FB", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "Tesla Motors", symbol:  "TSLA", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "Microsoft", symbol:  "MSFT", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "LinkedIn Corp", symbol:  "LNKD", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "Intel", symbol:  "INTC", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "Nike", symbol:  "NKE", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "NVIDIA", symbol:  "NVDA", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "1", symbol:  "MSFT", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "2", symbol:  "LNKD", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "3", symbol:  "INTC", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "4", symbol:  "NKE", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "5", symbol:  "INTC", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "6", symbol:  "INTC", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "7", symbol:  "INTC", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "8", symbol:  "INTC", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "9", symbol:  "INTC", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "10", symbol:  "INTC", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        self.searchArray += [StockItem(name: "11", symbol:  "INTC", exchange: "NYSE" , numShare: 0, purchaseDate: NSDate(), price: 0)]
        
        
        self.tableView.reloadData()
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
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell?
        cell!.textLabel?.text = self.searchArray[indexPath.row].name
        return cell!
    }
    
    
}
