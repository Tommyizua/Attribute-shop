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
    case available
    case notAvailable
}

class Parser: NSObject {
    
    fileprivate var totalPageNumber = ""
    fileprivate let kGlobalQueue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
    fileprivate let kMainQueue = DispatchQueue.main
    
    // MARK: - Help Methods
    
    func searchInfo (_ page: String, start: String, end: String) -> String {
        
        if let startRange = page.range(of: start) {
            
            if let endRange = page.range(of: end) {
                
                let finalRange = (startRange.upperBound)..<(endRange.lowerBound)
                let info = page.substring(with: finalRange)
                
                return info
            }
            
        }
        
        return String()
    }
    
    func removeUnicodeFromString(_ text: inout String)  {
        
        while text.range(of: "&#039;") != nil {
            
            let range039 = text.range(of: "&#039;")
            
            text.removeSubrange(range039!)
        }
        
        while  text.range(of: "&quot;") != nil {
            
            let rangeQuot = text.range(of: "&quot;")
            
            text.removeSubrange(rangeQuot!)
        }
        
    }
    
    func formattingPrice(_ price: String) -> String {
        
        var formattedPrice = "Цена: " + price
        let index = <#T##Collection corresponding to your index##Collection#>.index(before: formattedPrice.characters.index(before: formattedPrice.characters.endIndex))
        
        formattedPrice.insert(",", at: index)
        formattedPrice.append(" грн.")
        
        return formattedPrice
    }
    
    // MARK: - Get Catalog products Method
    
    func getProductsFromLink(_ link: String, type: ProductType, completionHandler:@escaping (_ productArray: [Product]?) -> ()) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true;
        
        kGlobalQueue.async(execute: {
            
            let encodedPath = link.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            if let url = URL(string: encodedPath) {
                
                let dataMainPage = try? Data(contentsOf: url)
                
                if let dataMainPage = dataMainPage {
                    
                    let sourceHtmlCode = String(data: dataMainPage, encoding: String.Encoding.utf8)!
                    
                    self.getProductsFromSourceCode(sourceHtmlCode, type: type, firstPage: true, completionHandler: { (productArray) in
                        
                        completionHandler(productArray)
                        
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
    
    func getProductsFromSourceCode(_ sourceHtmlCode: String, type: ProductType, firstPage: Bool, completionHandler:@escaping (_ productArray: [Product]?) -> ()) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var range = " ".startIndex..." ".startIndex
        
        if let startRange = sourceHtmlCode.range(of: "</div><h1> Каталог") {
            
            range = startRange
            
        } else if let startRange = sourceHtmlCode.range(of: "heading-counter\">") {
            
            range = startRange
            
            let resultsCount = self.searchInfo(sourceHtmlCode, start: "heading-counter\"> ", end: " results")
            
            if resultsCount == "0" {
                
                self.kMainQueue.async(execute: { () in
                    
                    completionHandler(nil)
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false;
                })
                
                return
            }
            
        } else {
            
            print("no range")
        }
        
        var code = sourceHtmlCode.substring(from: range.upperBound)
        
        var totalPageNumberDescription = self.searchInfo(code, start: "</span> </span></li><li> <a href=\"/", end: "</span> </a></li><li id=")
        
        if totalPageNumberDescription.characters.count > 40 {
            
            let startRange = totalPageNumberDescription.range(of: "</span> </span></li><li> <a href=\"/")!
            
            totalPageNumberDescription = totalPageNumberDescription.substring(from: startRange.upperBound)
        }
        
        if let range = totalPageNumberDescription.range(of: "<span>") {
            
            self.totalPageNumber = totalPageNumberDescription.substring(from: range.upperBound)
        }
        
        var productArray = [Product]()
        
        var orderId = DataManager.sharedInstance.getMaxIdWithProductType(type)
        
        while code.contains("product-name\" href=\"") {
            
            if var product = NSEntityDescription.insertNewObject(forEntityName: String(describing: Product), into: DataManager.sharedInstance.managedObjectContext) as? Product {
                
                let detailLink = self.searchInfo(code, start: "product-name\" href=\"", end: "\" title=")
                
                let fetchedProduct = DataManager.sharedInstance.getProductWithDetailLink(detailLink)
                
                if let storedProduct = fetchedProduct {
                    
                    DataManager.sharedInstance.managedObjectContext.delete(product)
                    
                    product = storedProduct
                    
                } else {
                    
                    let end: String
                    
                    if firstPage == true {
                        
                        end = "</sapn>"
                        
                    } else {
                        
                        end = "</span></div><div class=\"content_price"
                    }
                    
                    let article = self.searchInfo(code, start: "</span> <span>", end: end)
                    
                    product.article = "Артикул: " + article
                    
                    product.detailLink = detailLink
                    
                    var start: String
                    
                    if firstPage == true {
                        
                        start = "\" itemprop=\"url\" >"
                        
                    } else {
                        
                        start = "\" itemprop=\"url\">"
                    }
                    
                    product.title = self.searchInfo(code, start: start, end: " </a>")
                    
                    self.removeUnicodeFromString(&product.title!)
                    
                    product.imageUrlString = self.searchInfo(code, start: "src=\"", end: "\" alt=\"")
                    
                    
                    let stringPrice = self.searchInfo(code, start: "price\"> ", end: " </span><meta")
                    
                    var priceValueString = ""
                    
                    for letter in stringPrice.characters {
                        
                        if "0"..."9" ~= letter {
                            
                            priceValueString += String(letter)
                        }
                    }
                    
                    product.price = Int(priceValueString) as NSNumber?
                    
                    product.priceFormatted = self.formattingPrice(priceValueString)
                    
                    
                    if firstPage == true {
                        
                        start = "Stock\" />"
                        
                    } else {
                        
                        start = "Stock\">"
                    }
                    
                    product.availability = self.searchInfo(code, start: start, end: " </span> </span><div")
                    
                    if product.availability!.lowercased().hasPrefix("нет") {
                        
                        product.isAvailable = IsAvailable.notAvailable.rawValue
                        
                    } else {
                        
                        product.isAvailable = IsAvailable.available.rawValue
                    }
                    
                    product.type = type.rawValue;
                    
                    orderId += 1
                    product.orderId = orderId
                }
                
                print(product)
                
                let startRange = code.range(of: "/div></div></li>")!
                code = code.substring(from: startRange.upperBound)
                
                productArray.append(product)
            }
        }
        
        self.kMainQueue.async(execute: { () in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false;
            
            DataManager.sharedInstance.saveContext()
            
            completionHandler(productArray)
        })
    }
    
    // MARK: - Get Product's Features Method
    
    func getFeature(_ link: String, completionHandler:@escaping (_ features: [Feature]) -> ()) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true;
        
        kGlobalQueue.async(execute: {
            
            var featureArray = [Feature]()
            
            let encodedPath = link.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            if let url = URL(string: encodedPath) {
                
                let dataMainPage = try? Data(contentsOf: url)
                
                if let dataMainPage = dataMainPage {
                    
                    let sourceHtmlCode = String(data: dataMainPage, encoding: String.Encoding.utf8)!
                    
                    var code = self.searchInfo(sourceHtmlCode, start: "class=\"table-data-sheet", end: "</table> </section>")
                    
                    while code.contains("\"><td>") {
                        
                        let feature = Feature()
                        
                        feature.name = self.searchInfo(code, start: "\"><td>", end: "</td><td>")
                        
                        feature.value = self.searchInfo(code, start: "</td><td>", end: "</td></tr>")
                        
                        self.removeUnicodeFromString(&feature.value)
                        
                        let startRange = code.range(of: "</td></tr>")!
                        code = code.substring(from: startRange.upperBound)
                        
                        featureArray.append(feature)
                        
                    }
                }
                
                self.kMainQueue.async(execute: { () in
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false;
                    
                    completionHandler(featureArray)
                })
                
            }
        })
    }
    
    // MARK: - Get Stores Info Method
    
    func getStoresInfo(_ link: String, completionHandler:@escaping (_ stores: [StoresInCityArea]) -> ()) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true;
        
        kGlobalQueue.async(execute: {
            
            let encodedPath = link.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            if let url = URL(string: encodedPath) {
                
                let dataMainPage = try? Data(contentsOf: url)
                
                var storesInfoArray = [StoresInCityArea]()
                
                if let dataMainPage = dataMainPage {
                    
                    let sourceHtmlCode = String(data: dataMainPage, encoding: String.Encoding.utf8)!
                    var code = self.searchInfo(sourceHtmlCode, start: "Сеть бутиков", end: "footer")
                    
                    var orderId = 0
                    
                    while code.contains("city_name\">") {
                        
                        let storesInCityArea = StoresInCityArea()
                        
                        var codeBlock = self.searchInfo(code, start: "<div class=\"city\">", end: "\"></div></div></div>")
                        
                        storesInCityArea.cityName = self.searchInfo(codeBlock, start: "city_name\">", end: "</div>")
                        
                        while codeBlock.contains("\" src=\"") {
                            
                            if let store = NSEntityDescription.insertNewObject(forEntityName: String(describing: Store), into: DataManager.sharedInstance.managedObjectContext) as? Store {
                                
                                store.imageUrlString = self.searchInfo(codeBlock, start: "\" src=\"", end: "\" alt=\"\" /></div>")
                                
                                store.name = self.searchInfo(codeBlock, start: "store_name\">", end: "</div><div class=\"store_address")
                                self.removeUnicodeFromString(&store.name!)
                                
                                store.address = self.searchInfo(codeBlock, start: "store_address\">", end: "</div><div class=\"clear")
                                
                                store.cityName = storesInCityArea.cityName
                                
                                orderId += 1
                                store.orderId = orderId as NSNumber?
                                
                                let startRange = codeBlock.range(of: "clear")!
                                codeBlock = codeBlock.substring(from: startRange.upperBound)
                                
                                storesInCityArea.storeObjectArray.append(store)
                            }
                        }
                        
                        storesInfoArray.append(storesInCityArea)
                        
                        let startRange = code.range(of: "clear\"></div></div></div>")!
                        code = code.substring(from: startRange.upperBound)
                    }
                    
                }
                
                self.kMainQueue.async(execute: { () in
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false;
                    
                    DataManager.sharedInstance.saveContext()
                    
                    completionHandler(storesInfoArray)
                })
            }
        })
    }
    
    func getCountStores(_ link: String, completionHandler:@escaping (_ count: Int) -> ()) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true;
        
        kGlobalQueue.async(execute: {
            
            let dataMainPage = try? Data(contentsOf: URL(string: link)!)
            
            var count = 0
            
            if let dataMainPage = dataMainPage {
                
                let sourceHtmlCode = String(data: dataMainPage, encoding: String.Encoding.utf8)!
                var code = self.searchInfo(sourceHtmlCode, start: "Сеть бутиков", end: "footer")
                
                while code.contains("city_name\">") {
                    
                    var codeBlock = self.searchInfo(code, start: "<div class=\"city\">", end: "\"></div></div></div>")
                    
                    while codeBlock.contains("\" src=\"") {
                        
                        count += 1
                        
                        let startRange = codeBlock.range(of: "clear")!
                        codeBlock = codeBlock.substring(from: startRange.upperBound)
                    }
                    
                    let startRange = code.range(of: "clear\"></div></div></div>")!
                    code = code.substring(from: startRange.upperBound)
                }
                
            }
            
            self.kMainQueue.async(execute: { () in
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false;
                
                completionHandler(count)
            })
            
        })
    }
    
}
