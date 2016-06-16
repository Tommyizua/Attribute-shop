//
//  Parse.swift
//  Attribute
//
//  Created by Yaroslav on 21/11/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit
import CoreData

enum IsAvailable: NSNumber {
    case Available
    case NotAvailable
}

class Parser: NSObject {
    
    private var totalPageNumber = ""
    private let kGlobalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    private let kMainQueue = dispatch_get_main_queue()
    
    // MARK: - Help Methods
    
    func searchInfo (page: String, start: String, end: String) -> String {
        
        if let startRange = page.rangeOfString(start) {
            
            if let endRange = page.rangeOfString(end) {
                
                let finalRange = (startRange.endIndex)..<(endRange.startIndex)
                let info = page.substringWithRange(finalRange)
                
                return info
            }
            
        }
        
        return String()
    }
    
    func removeUnicodeFromString(inout text: String)  {
        
        while text.rangeOfString("&#039;") != nil {
            
            let range039 = text.rangeOfString("&#039;")
            
            text.removeRange(range039!)
        }
        
        while  text.rangeOfString("&quot;") != nil {
            
            let rangeQuot = text.rangeOfString("&quot;")
            
            text.removeRange(rangeQuot!)
        }
        
    }
    
    func formattingPrice(price: String) -> String {
        
        var formattedPrice = "Цена: " + price
        let index = formattedPrice.characters.endIndex.predecessor().predecessor()
        
        formattedPrice.insert(",", atIndex: index)
        formattedPrice.appendContentsOf(" грн.")
        
        return formattedPrice
    }
    
    // MARK: - Get Catalog products Method
    
    func getProductsFromLink(link: String, type: ProductType, completionHandler:(productArray: [Product]?) -> ()) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
        
        dispatch_async(kGlobalQueue, {
            
            let encodedPath = link.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            if let url = NSURL(string: encodedPath) {
                
                let dataMainPage = NSData(contentsOfURL: url)
                
                if let dataMainPage = dataMainPage {
                    
                    let sourceHtmlCode = String(data: dataMainPage, encoding: NSUTF8StringEncoding)!
                    
                    var range = " ".startIndex..." ".startIndex
                    
                    if let startRange = sourceHtmlCode.rangeOfString("</div><h1> Каталог") {
                        
                        range = startRange
                        
                    } else if let startRange = sourceHtmlCode.rangeOfString("heading-counter\">") {
                        
                        range = startRange
                        
                        let resultsCount = self.searchInfo(sourceHtmlCode, start: "heading-counter\"> ", end: " results")
                        
                        if resultsCount == "0" {
                            
                            dispatch_async(self.kMainQueue, { () in
                                
                                completionHandler(productArray: nil)
                                
                                UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
                            })
                            
                            return
                        }
                        
                    } else {
                        
                        print("no range")
                    }
                    
                    var code = sourceHtmlCode.substringFromIndex(range.endIndex)
                    
                    var totalPageNumberDescription = self.searchInfo(code, start: "</span> </span></li><li> <a href=\"/", end: "</span> </a></li><li id=")
                    
                    if totalPageNumberDescription.characters.count > 40 {
                        
                        let startRange = totalPageNumberDescription.rangeOfString("</span> </span></li><li> <a href=\"/")!
                        
                        totalPageNumberDescription = totalPageNumberDescription.substringFromIndex(startRange.endIndex)
                    }
                    
                    if let range = totalPageNumberDescription.rangeOfString("<span>") {
                        
                        self.totalPageNumber = totalPageNumberDescription.substringFromIndex(range.endIndex)
                    }
                    
                    var productArray = [Product]()
                    
                    var orderId = DataManager.sharedInstance.getMaxIdWithProductType(type)
                    
                    while code.containsString("product-name\" href=\"") {
                        
                        if var product = NSEntityDescription.insertNewObjectForEntityForName(String(Product), inManagedObjectContext: DataManager.sharedInstance.managedObjectContext) as? Product {
                            
                            let detailLink = self.searchInfo(code, start: "product-name\" href=\"", end: "\" title=")
                            
                            let fetchedProduct = DataManager.sharedInstance.getProductWithDetailLink(detailLink)
                            
                            if let storedProduct = fetchedProduct {
                                
                                DataManager.sharedInstance.managedObjectContext.deleteObject(product)
                                
                                product = storedProduct
                                
                            } else {
                                
                                product.article = "Артикул: " + self.searchInfo(code, start: "</span> <span>", end: "</sapn>")
                                
                                product.detailLink = detailLink
                                
                                product.title = self.searchInfo(code, start: "\" itemprop=\"url\" > ", end: " </a>")
                                
                                self.removeUnicodeFromString(&product.title!)
                                
                                product.imageUrlString = self.searchInfo(code, start: "src=\"", end: "\" alt=\"")
                                
                                
                                let stringPrice = self.searchInfo(code, start: "price\"> ", end: " </span><meta")
                                
                                var priceValueString = ""
                                
                                for letter in stringPrice.characters {
                                    
                                    if "0"..."9" ~= letter {
                                        
                                        priceValueString += String(letter)
                                    }
                                    
                                }
                                
                                product.price = Int(priceValueString)
                                
                                product.priceFormatted = self.formattingPrice(priceValueString)
                                
                                product.availability = self.searchInfo(code, start: "Stock\" />", end: " </span> </span><div")
                                
                                if product.availability!.lowercaseString.hasPrefix("нет") {
                                    
                                    product.isAvailable = IsAvailable.NotAvailable.rawValue
                                    
                                } else {
                                    
                                    product.isAvailable = IsAvailable.Available.rawValue
                                }
                                
                                product.type = type.rawValue;
                                
                                orderId += 1
                                product.orderId = orderId
                            }
                            
                            print(product)
                            
                            let startRange = code.rangeOfString("/div></div></li>")!
                            code = code.substringFromIndex(startRange.endIndex)
                            
                            productArray.append(product)
                        }
                    }
                    
                    dispatch_async(self.kMainQueue, { () in
                        
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
                        
                        DataManager.sharedInstance.saveContext()
                        
                        completionHandler(productArray: productArray)
                    })
                }
            }
        })
        
        //        dispatch_async(self.kMainQueue, { () in
        //
        //            UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
        //
        //            completionHandler(productArray: [Product]())
        //        })
        
    }
    
    // MARK: - Get Product's Features Method
    
    func getFeature(link: String, completionHandler:(features: [Feature]) -> ()) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
        
        dispatch_async(kGlobalQueue, {
            
            var featureArray = [Feature]()
            
            let encodedPath = link.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            if let url = NSURL(string: encodedPath) {
                
                let dataMainPage = NSData(contentsOfURL: url)
                
                if let dataMainPage = dataMainPage {
                    
                    let sourceHtmlCode = String(data: dataMainPage, encoding: NSUTF8StringEncoding)!
                    
                    var code = self.searchInfo(sourceHtmlCode, start: "class=\"table-data-sheet", end: "</table> </section>")
                    
                    while code.containsString("\"><td>") {
                        
                        let feature = Feature()
                        
                        feature.name = self.searchInfo(code, start: "\"><td>", end: "</td><td>")
                        
                        feature.value = self.searchInfo(code, start: "</td><td>", end: "</td></tr>")
                        
                        self.removeUnicodeFromString(&feature.value)
                        
                        let startRange = code.rangeOfString("</td></tr>")!
                        code = code.substringFromIndex(startRange.endIndex)
                        
                        featureArray.append(feature)
                        
                    }
                }
                
                dispatch_async(self.kMainQueue, { () in
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
                    
                    completionHandler(features: featureArray)
                })
                
            }
        })
    }
    
    // MARK: - Get Stores Info Method
    
    func getStoresInfo(link: String, completionHandler:(stores: [StoresInCityArea]) -> ()) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
        
        dispatch_async(kGlobalQueue, {
            
            let encodedPath = link.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            if let url = NSURL(string: encodedPath) {
                
                let dataMainPage = NSData(contentsOfURL: url)
                
                var storesInfoArray = [StoresInCityArea]()
                
                if let dataMainPage = dataMainPage {
                    
                    let sourceHtmlCode = String(data: dataMainPage, encoding: NSUTF8StringEncoding)!
                    var code = self.searchInfo(sourceHtmlCode, start: "Сеть бутиков", end: "footer")
                    
                    var orderId = 0
                    
                    while code.containsString("city_name\">") {
                        
                        let storesInCityArea = StoresInCityArea()
                        
                        var codeBlock = self.searchInfo(code, start: "<div class=\"city\">", end: "\"></div></div></div>")
                        
                        storesInCityArea.cityName = self.searchInfo(codeBlock, start: "city_name\">", end: "</div>")
                        
                        while codeBlock.containsString("\" src=\"") {
                            
                            if let store = NSEntityDescription.insertNewObjectForEntityForName(String(Store), inManagedObjectContext: DataManager.sharedInstance.managedObjectContext) as? Store {
                                
                                store.imageUrlString = self.searchInfo(codeBlock, start: "\" src=\"", end: "\" alt=\"\" /></div>")
                                
                                store.name = self.searchInfo(codeBlock, start: "store_name\">", end: "</div><div class=\"store_address")
                                self.removeUnicodeFromString(&store.name!)
                                
                                store.address = self.searchInfo(codeBlock, start: "store_address\">", end: "</div><div class=\"clear")
                                
                                store.cityName = storesInCityArea.cityName
                                
                                orderId += 1
                                store.orderId = orderId
                                
                                let startRange = codeBlock.rangeOfString("clear")!
                                codeBlock = codeBlock.substringFromIndex(startRange.endIndex)
                                
                                storesInCityArea.storeObjectArray.append(store)
                            }
                        }
                        
                        storesInfoArray.append(storesInCityArea)
                        
                        let startRange = code.rangeOfString("clear\"></div></div></div>")!
                        code = code.substringFromIndex(startRange.endIndex)
                    }
                    
                }
                
                dispatch_async(self.kMainQueue, { () in
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
                    
                    DataManager.sharedInstance.saveContext()
                    
                    completionHandler(stores: storesInfoArray)
                })
            }
        })
    }
    
    func getCountStores(link: String, completionHandler:(count: Int) -> ()) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
        
        dispatch_async(kGlobalQueue, {
            
            let dataMainPage = NSData(contentsOfURL: NSURL(string: link)!)
            
            var count = 0
            
            if let dataMainPage = dataMainPage {
                
                let sourceHtmlCode = String(data: dataMainPage, encoding: NSUTF8StringEncoding)!
                var code = self.searchInfo(sourceHtmlCode, start: "Сеть бутиков", end: "footer")
                
                while code.containsString("city_name\">") {
                    
                    var codeBlock = self.searchInfo(code, start: "<div class=\"city\">", end: "\"></div></div></div>")
                    
                    while codeBlock.containsString("\" src=\"") {
                        
                        count += 1
                        
                        let startRange = codeBlock.rangeOfString("clear")!
                        codeBlock = codeBlock.substringFromIndex(startRange.endIndex)
                    }
                    
                    let startRange = code.rangeOfString("clear\"></div></div></div>")!
                    code = code.substringFromIndex(startRange.endIndex)
                }
                
            }
            
            dispatch_async(self.kMainQueue, { () in
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
                
                completionHandler(count: count)
            })
            
        })
    }
    
}