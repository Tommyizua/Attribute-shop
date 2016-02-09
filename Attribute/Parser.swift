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
    
    func searchForUnicode(inout text: String)  {
        
        while text.rangeOfString("&#039;") != nil {
            
            let range = text.rangeOfString("&#039;")!
            
            text.removeRange(range)
        }
        
        while text.rangeOfString("&quot;") != nil {
            
            let range = text.rangeOfString("&quot;")!
            
            text.removeRange(range)
        }
        
    }
    
    // MARK: - Get Catalog products Method
    
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
                searchForUnicode(&product.title)
                
                product.imageUrlString = searchInfo(code, start: "src=\"", end: "\" alt=\"")
                product.article = "Артикул: " + searchInfo(code, start: "</span> <span>", end: "</sapn>")
                
                let stringPrice = searchInfo(code, start: "price\"> ", end: " </span><meta")
                
                var priceValueString = ""
                
                for letter in stringPrice.characters {
                    
                    if "0"..."9" ~= letter {
                        
                        priceValueString += String(letter)
                    }
                    
                }
                
                product.price = Int(priceValueString) ?? 0
                
                product.availability = searchInfo(code, start: "Stock\" />", end: " </span> </span><div")
                
                if product.availability.lowercaseString.hasPrefix("нет") {
                    
                    product.isAvailable = false
                }
                
                let startRange = code.rangeOfString("/div></div></li>")!
                code = code.substringFromIndex(startRange.endIndex)
                
                productArray.append(product)
            }
        }
        return productArray
    }
    
    // MARK: - Get Product's Features Method
    
    func getFeature(link: String) -> [Feature] {
        
        var featureArray = [Feature]()
        
        let dataMainPage = NSData(contentsOfURL: NSURL(string: link)!)
        
        if let dataMainPage = dataMainPage {
            
            let sourceHtmlCode = String(data: dataMainPage, encoding: NSUTF8StringEncoding)!
            
            var code = searchInfo(sourceHtmlCode, start: "class=\"table-data-sheet", end: "</table> </section>")
            
            while code.containsString("\"><td>") {
                
                let feature = Feature()
                
                feature.name = searchInfo(code, start: "\"><td>", end: "</td><td>")
                
                feature.value = searchInfo(code, start: "</td><td>", end: "</td></tr>")
                
                searchForUnicode(&feature.value)
                
                let startRange = code.rangeOfString("</td></tr>")!
                code = code.substringFromIndex(startRange.endIndex)
                
                featureArray.append(feature)
                
            }
        }
        
        return featureArray
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
                    searchForUnicode(&storeObject.name)
                    
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