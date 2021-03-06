//
//  DetailViewController.swift
//  Portfolio
//
//  Created by Daniel on 1/6/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController  {
    
    var nameToPass:String!
    var symbolToPass:String!
    var exchangeToPass:String!
    var priceToPass:String!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var exchangeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var risefallLabel: UILabel!
    @IBOutlet weak var openingPriceLabel: UILabel!
    @IBOutlet weak var highPriceLabel: UILabel!
    @IBOutlet weak var lowPriceLabel: UILabel!
    @IBOutlet weak var mrktCapLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        nameLabel.text = nameToPass
        symbolLabel.text = symbolToPass
        exchangeLabel.text = exchangeToPass

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stockUpdated:", name: kNotificationStockUpdated, object: nil)
        self.updateStocks()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateStocks()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func updateStocks() {
        let stockManager:StockManagerSingleton = StockManagerSingleton.sharedInstance
        stockManager.updateSymbol(symbolToPass, exchangeToSearch: exchangeToPass)
        
        //Repeat this method after 15 secs. (For simplicity of the tutorial we are not cancelling it never)
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(900 * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(),
            {
                self.updateStocks()
            }
        )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "detailToAddToPortfolio"){
            let destController = segue.destinationViewController as! AddToPortfolioViewController
            destController.nameToPass = nameToPass
            destController.symbolToPass = symbolToPass
            destController.exchangeToPass = exchangeToPass
            destController.priceToPass = priceLabel.text
        }
    
    }
    
    func stockUpdated(notification: NSNotification){
        let quote: NSDictionary = notification.userInfo![kNotificationStockUpdated] as! NSDictionary
        //print(quote)
        
        //set the price
        priceLabel.text = quote.objectForKey("LastTradePriceOnly") as? String
        openingPriceLabel.text = quote.objectForKey("Open") as? String
        highPriceLabel.text = quote.objectForKey("DaysHigh") as? String
        lowPriceLabel.text = quote.objectForKey("DaysLow") as? String
        mrktCapLabel.text = quote.objectForKey("MarketCapitalization") as? String
        if(mrktCapLabel.text==nil){
            mrktCapLabel.text = "N/A"
        }
        
        //set the change and percent
        let change: String = quote.objectForKey("Change") as! String
        if(change.characters.first == "+"){
            risefallLabel.textColor = UIColor(red: 0.0, green: 0.78, blue: 0.2, alpha: 1) //green
        }
        else{
            risefallLabel.textColor = UIColor(red: 0.96, green: 0.26, blue: 0.21, alpha: 1) //red
        }
        let changeInPercent: String = quote.objectForKey("ChangeinPercent") as! String
        risefallLabel.text = change+" ("+String(changeInPercent.characters.dropFirst())+")"
    }

}
