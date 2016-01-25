//
//  AddToPortfolioViewController.swift
//  Portfolio
//
//  Created by Daniel on 1/7/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import UIKit

class AddToPortfolioViewController: UIViewController {

    var nameToPass:String!
    var symbolToPass:String!
    var exchangeToPass:String!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var exchangeLabel:UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        nameLabel.text = nameToPass
        symbolLabel.text = symbolToPass
        exchangeLabel.text = exchangeToPass
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
