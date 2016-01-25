//
//  InvestmentItem.swift
//  Portfolio
//
//  Created by Daniel on 1/5/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

import Foundation

struct StockItem
{
    let name:String
    let symbol:String
    let exchange:String
    let numShare:Int
    let purchaseDate: NSDate
    let price: double_t
}

struct BondItem{
    let name:String
    let symbol:String
    let numShare:Int
    let purchaseDate: NSDate
    let price: double_t
}

struct FundItems{
    let name:String
    let symbol:String
    let exchange:String
    let numShare:Int
    let purchaseDate: NSDate
    let price: double_t
}

struct Portfolio{
    var stockArray :[StockItem] = []
    var bondArray :[BondItem] = []
    var fundArray : [FundItems] = []
}