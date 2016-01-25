//
//  StockManagerSingleton.swift
//  Portfolio
//
//  Created by Daniel on 1/8/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import Foundation

let kNotificationStockUpdated = "stockUpdatedNotification"

class StockManagerSingleton {
    
    class var sharedInstance : StockManagerSingleton {
        struct Static {
            static let instance : StockManagerSingleton = StockManagerSingleton()
        }
        return Static.instance
    }
    
    func printTest() {
        NSLog("TEST OK :)")
    }
    
    //http://www.myplacesandme.com/wordpress/swift-app-tutorial-swiftstocks-tuples-switch-singleton-webservices-part-ii/
    
    
    /*!
    * @discussion Function that given an array of symbols, get their stock prizes from yahoo and send them inside a NSNotification UserInfo
    * @param stocks An Array of tuples with the symbols in position 0 of each tuple
    */
    func updateSymbol(symbolToSearch: String, exchangeToSearch: String) {
        
        //1: YAHOO Finance API: Request for a list of symbols example:
        //http://query.yahooapis.com/v1/public/yql?q=select * from yahoo.finance.quotes where symbol IN ("AAPL","GOOG","FB")&format=json&env=http://datatables.org/alltables.env
        
        //2: Build the URL as above with our array of symbols
        let stringQuotes: String
        if(exchangeToSearch == "TSE"){  //Toronto Stock Exchange
            stringQuotes = "(\""+symbolToSearch+".TO\")";
        }
        else{ //NYSE
            stringQuotes = "(\""+symbolToSearch+"\")";
        }
        
        
        let urlString:String = ("https://query.yahooapis.com/v1/public/yql?q=select * from yahoo.finance.quotes where symbol IN "+stringQuotes+"&format=json&env=http://datatables.org/alltables.env").stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = NSURL(string: urlString)
        let request: NSURLRequest = NSURLRequest(URL:url!)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        //3: Completion block/Clousure for the NSURLSessionDataTask
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            //error when requesting data
            guard error == nil else{
                print(error!.localizedDescription)
                return
            }
            
            //4: JSON process
            do {
                let jsonData: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                print(jsonData)
                
                //5: Extract the Quotes and Values and send them inside a NSNotification
                let quote: NSDictionary = ((jsonData.objectForKey("query") as! NSDictionary).objectForKey("results") as! NSDictionary).objectForKey("quote") as! NSDictionary
                dispatch_async(dispatch_get_main_queue(), {
                NSNotificationCenter.defaultCenter().postNotificationName(kNotificationStockUpdated, object: nil, userInfo:[kNotificationStockUpdated:quote])
                })
                
            } catch{
                print("Error converting data to JSON")
            }
            
        })
        //6: DONT FORGET to LAUNCH the NSURLSessionDataTask!!!!!!
        task.resume()
    }
}
