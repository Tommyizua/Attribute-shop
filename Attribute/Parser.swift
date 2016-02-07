//
//  Parse.swift
//  Attribute
//
//  Created by Yaroslav on 21/11/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit

class Parser: NSObject {
    
    private var pageNumber = ""
    
    // MARK: - Get Catalog products Methods
    
    func getInfoFromUrl(link: String) -> [Product] {
      
        var productArray = [Product]()

        let dataMainPage = NSData(contentsOfURL: NSURL(string: link)!)
     
        if let dataMainPage = dataMainPage {
          
            let sourceHtmlCode = String(data: dataMainPage, encoding: NSUTF8StringEncoding)!
            var startRange = sourceHtmlCode.rangeOfString("</div><h1> Каталог")!
            var code = sourceHtmlCode.substringFromIndex(startRange.endIndex)
            pageNumber = searchInfo(code, start: "</span> </span></li><li> <a href=\"/", end: "</span> </a></li><li id=")
          
            if pageNumber.characters.count > 40 {
                let startRange = pageNumber.rangeOfString("</span> </span></li><li> <a href=\"/")!
                pageNumber = pageNumber.substringFromIndex(startRange.endIndex)
            }
           
            startRange = pageNumber.rangeOfString("<span>")!
            pageNumber = pageNumber.substringFromIndex(startRange.endIndex)
            
            while code.containsString("product-name\" href=\"") {
             
                let product = Product()
                
                product.detailLink = searchInfo(code, start: "product-name\" href=\"", end: "\" title=")
             
                product.title = searchInfo(code, start: "\" itemprop=\"url\" > ", end: " </a>")
                product.title = searchUnicode(product.title)
               
                product.imageUrlString = searchInfo(code, start: "src=\"", end: "\" alt=\"")
                product.article = "Артикул: " + searchInfo(code, start: "</span> <span>", end: "</sapn>")
               
                let stringPrice = searchInfo(code, start: "price\"> ", end: " </span><meta")

                var priceValueString = ""
                
                for letter in stringPrice.characters {
                  
                    switch (letter) {
                    case "0"..."9":
                        priceValueString += String(letter)
                    default :
                        break
                  
                    }
                }
                
                product.priceValue = Int(priceValueString) ?? 0
                
                product.availability = searchInfo(code, start: "Stock\" />", end: " </span> </span><div")
                
                let startRange = code.rangeOfString("/div></div></li>")!
                code = code.substringFromIndex(startRange.endIndex)
            
                productArray.append(product)
            }
        }
        return productArray
    }
    
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
    
    func searchUnicode(var text: String) -> String {
        
        while text.containsString("&quot;") {
            
            let startRange = text.rangeOfString("&")!
            let endRange = text.rangeOfString(";")!
            let finalRange = startRange.endIndex.predecessor()...endRange.startIndex
            text.removeRange(finalRange)
        }
        
        return text
    }
    
    func getFeature(link: String) -> [[String: String]] {
        
        var featureCollection = [[String: String]]()

        let dataMainPage = NSData(contentsOfURL: NSURL(string: link)!)
        
        if let dataMainPage = dataMainPage {
            let sourceHtmlCode = String(data: dataMainPage, encoding: NSUTF8StringEncoding)!
            var startRange = sourceHtmlCode.rangeOfString("class=\"table-data-sheet")!
            var code = sourceHtmlCode.substringFromIndex(startRange.endIndex)
            
            while code.containsString("\"><td>") {
                var pageFeature = [String:String]()
                let featureName = searchInfo(code, start: "\"><td>", end: "</td><td>")
                var featureValue = searchInfo(code, start: "</td><td>", end: "</td></tr>")
                featureValue = searchUnicode(featureValue)
                startRange = code.rangeOfString("</td></tr>")!
                code = code.substringFromIndex(startRange.endIndex)
                
                pageFeature[featureName] = featureValue
                featureCollection.append(pageFeature)
            }
        }
        return featureCollection
    }
    
    // MARK: - Get Stores Info Method
    
    func getStoresInfo(link: String) -> ([StoresInCityArea]) {
        
        let dataMainPage = NSData(contentsOfURL: NSURL(string: link)!)
        
        if let dataMainPage = dataMainPage {
            
            let sourceHtmlCode = String(data: dataMainPage, encoding: NSUTF8StringEncoding)!
            var code = searchInfo(sourceHtmlCode, start: "Сеть бутиков", end: "footer")
            
            var storesInfoArray = [StoresInCityArea]()
            
            while code.containsString("city_name\">") {
                
                let storesInCityArea = StoresInCityArea()

                var codeBlock = searchInfo(code, start: "<div class=\"city\">", end: "\"></div></div></div>")
               
                storesInCityArea.cityName = searchInfo(codeBlock, start: "city_name\">", end: "</div>")
                
                while codeBlock.containsString("\" src=\"") {
                    
                    let storeObject = StoreObject()
                    
                    storeObject.image = searchInfo(codeBlock, start: "\" src=\"", end: "\" alt=\"\" /></div>")

                    storeObject.name = searchInfo(codeBlock, start: "store_name\">", end: "</div><div class=\"store_address")
                    storeObject.name = searchUnicode(storeObject.name)
                    
                    storeObject.address = searchInfo(codeBlock, start: "store_address\">", end: "</div><div class=\"clear")
                    
                    let startRange = codeBlock.rangeOfString("clear")!
                    codeBlock = codeBlock.substringFromIndex(startRange.endIndex)
                    
                    storesInCityArea.storeObjectArray.append(storeObject)
                }
                
                storesInfoArray.append(storesInCityArea)
                
                let startRange = code.rangeOfString("clear\"></div></div></div>")!
                code = code.substringFromIndex(startRange.endIndex)
            }
            
            return storesInfoArray

        }
        
        return [StoresInCityArea]()
    }
    
}