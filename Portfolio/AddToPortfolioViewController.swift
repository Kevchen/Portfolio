//
//  AddToPortfolioViewController.swift
//  Portfolio
//
//  Created by Daniel on 1/7/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import UIKit
import CoreData

class AddToPortfolioViewController: UIViewController, UITextFieldDelegate {

    var nameToPass:String!
    var symbolToPass:String!
    var exchangeToPass:String!
    var priceToPass:String!
    
    var date:NSDate!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var numShareTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var exchangeLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //query latest price if they clicked the "+" button and bypass detailVeiw
        if(priceToPass == nil){
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "stockUpdated:", name: kNotificationStockUpdated, object: nil)
            self.updateStocks()
        }
        
        //remove done button on top right tool bar
        self.navigationItem.setRightBarButtonItem(nil, animated: true)
        
        // Do any additional setup after loading the view.
        nameLabel.text = nameToPass
        symbolLabel.text = symbolToPass
        exchangeLabel.text = exchangeToPass
        priceTextField.text = priceToPass
        
        //set default date
        date = NSDate()
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateTextField.text = dateFormatter.stringFromDate(date)
        
        //set keyboard types for textfields
        //priceTextField.keyboardType = UIKeyboardType.DecimalPad
        //numShareTextField.keyboardType = UIKeyboardType.NumberPad
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
    
    func stockUpdated(notification: NSNotification){
        let quote: NSDictionary = notification.userInfo![kNotificationStockUpdated] as! NSDictionary
        //print(quote)
        
        //set the price
        priceTextField.text = quote.objectForKey("LastTradePriceOnly") as? String
    }

    @IBAction func showDatePicker(sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateTextField.text = dateFormatter.stringFromDate(sender.date)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mark: Text Field Done button
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        let keyboardDoneButtonShow = UIToolbar(frame: CGRectMake(200,200, self.view.frame.size.width,30))
        // self.view.frame.size.height/17
        keyboardDoneButtonShow.barStyle = UIBarStyle .BlackTranslucent
        let button: UIButton = UIButton()
        button.frame = CGRectMake(0, 0, 65, 20)
        button.setTitle("Done", forState: UIControlState .Normal)
        button.addTarget(self, action: Selector("textFieldShouldReturn:"), forControlEvents: UIControlEvents .TouchUpInside)
        button.backgroundColor = UIColor .clearColor()
        // let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("textFieldShouldReturn:"))
        let doneButton: UIBarButtonItem = UIBarButtonItem()
        doneButton.customView = button
        let negativeSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        negativeSpace.width = -10.0
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        //doneButton.tintColor = UIColor .yellowColor()
        let toolbarButton = [flexSpace,doneButton,negativeSpace]
        keyboardDoneButtonShow.setItems(toolbarButton, animated: false)
        textField.inputAccessoryView = keyboardDoneButtonShow
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //add stuff to coredata
    @IBAction func AddToPortfolio(sender: UIButton) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        //if no record exists, create a new record
        if(checkExistAndUpdate() == false){
            let entity =  NSEntityDescription.entityForName("Stock",inManagedObjectContext:managedContext)
            let stock = NSManagedObject(entity: entity!,insertIntoManagedObjectContext: managedContext)
        
            stock.setValue(nameLabel.text, forKey: "name")
            stock.setValue(symbolLabel.text, forKey: "symbol")
            stock.setValue(exchangeLabel.text, forKey: "exchange")
            stock.setValue(Double(priceTextField.text!), forKey: "price")
            stock.setValue(Int(numShareTextField.text!), forKey: "numShare")
            stock.setValue(date, forKey: "date")

            do {
                try managedContext.save()

            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            print("inserted new record")
        }
        
        //go back to portfolio view
        performSegueWithIdentifier("addToPortfolioToPortfolio", sender: self)
    }
    
    func checkExistAndUpdate() -> Bool  {
        //check if record exists
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Stock")
        fetchRequest.returnsObjectsAsFaults = false;
        
        //set up predicate to find existing record
        let resultPredicate1 = NSPredicate(format: "exchange = %@", exchangeToPass)
        let resultPredicate2 = NSPredicate(format: "symbol = %@", symbolToPass)
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [resultPredicate1, resultPredicate2])
        fetchRequest.predicate = compound
        
        //do the fetch
        do {
            var results = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            
            if(results.count==0){
                //nothing found, return false
                return false
            }
            
            let record = results[0]
            
            //print("updating")
            //print(record)
            
            //get original share number
            let oldNumShare: Int = (record.valueForKey("numShare") as? Int)!
            let newNumShare: Int = Int(numShareTextField.text!)!
            let newTotal: Int = newNumShare + oldNumShare
            
            //save new total num share
            record.setValue(Int(newTotal), forKey: "numShare")
            
            //calculate new price
            let oldPrice: Double = (record.valueForKey("price") as? Double)!
            let oldWorth: Double = Double(oldNumShare) * oldPrice
            let newPrice: Double = Double(priceTextField.text!)!
            let newWorth: Double = Double(newNumShare) * newPrice
            let avgPrice: Double = (newWorth + oldWorth) / (Double(oldNumShare) + Double(newNumShare))
            
            //save new avg price and date
            record.setValue(avgPrice, forKey: "price")
            record.setValue(date, forKey: "date")
            
            //core data save
            do {
                try managedContext.save()
                
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            print("updated existing record")
            
            //record updated, return true
            return true
            
        } catch let error as NSError {
            // failure
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        return false
    }
}


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

