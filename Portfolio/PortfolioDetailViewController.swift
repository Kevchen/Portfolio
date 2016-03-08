//
//  PortfolioDetailViewController.swift
//  Portfolio
//
//  Created by Daniel on 3/3/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import UIKit
import CoreData

class PortfolioDetailViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var exchangeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var numShareTextField: UITextField!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIButton!


    
    var itemToPass: NSManagedObject!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        exchangeLabel.text = itemToPass.valueForKey("exchange") as? String
        nameLabel.text     = itemToPass.valueForKey("name") as? String
        symbolLabel.text   = itemToPass.valueForKey("symbol") as? String
        numShareTextField.text = String(itemToPass.valueForKey("numShare")!)
        priceTextField.text    = String(itemToPass.valueForKey("price")!)
    
        let date  = itemToPass.valueForKey("date") as! NSDate
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateTextField.text = dateFormatter.stringFromDate(date)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    @IBAction func allowEdit(sender: UIButton) {
        if(editButton.title == "Edit"){
            priceTextField.enabled = true
            numShareTextField.enabled = true
            dateTextField.enabled = true
            editButton.title = "Done"
            deleteButton.hidden = false
        }
        else{
            priceTextField.enabled = false
            numShareTextField.enabled = false
            dateTextField.enabled = false
            editButton.title = "Edit"
            deleteButton.hidden = true
            
            //do the saving
        }
    }
    
    // Mark: Textfield done button
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
    
    @IBAction func removeTrade(sender: UIButton) {
        //setup UIActionSheet
        let alertController = UIAlertController(title: "Are you sure you want to delete the trade record?", message: "", preferredStyle: .ActionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
            print("Cancel Button Pressed")
        })
        let  delete = UIAlertAction(title: "Delete", style: .Destructive) { (action) -> Void in
            print("Delete Button Pressed")
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            
            //delete record
            managedContext.deleteObject(self.itemToPass)
            
            //core data save
            do {
                try managedContext.save()
                print("record is deleted")
                
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            //go back to previous view, which is the PortfolioView controller
            self.navigationController?.popViewControllerAnimated(true)
        }
        alertController.addAction(cancel)
        alertController.addAction(delete)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
