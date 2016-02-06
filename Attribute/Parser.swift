//
//  Parse.swift
//  Attribute
//
//  Created by Yaroslav on 21/11/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit

class Parser: NSObject {
    
    lazy private var productInfo = [[String: String]]()
    lazy private var featureCollection = [[String: String]]()
    lazy private var storeInfo = [[[String: String]]]()
    lazy private var cities = [String]()
    lazy private var pageNumber = ""
    
    func getInfoFromUrl(link: String) -> [[String: String]] {
        
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
                let productLink = searchInfo(code, start: "product-name\" href=\"", end: "\" title=")
                var title = searchInfo(code, start: "\" itemprop=\"url\" > ", end: " </a>")
                title = searchUnicode(title)
                let image = searchInfo(code, start: "src=\"", end: "\" alt=\"")
                let article = "Артикул: " + searchInfo(code, start: "</span> <span>", end: "</sapn>")
                let stringPrice = searchInfo(code, start: "price\"> ", end: " </span><meta")
                var price = ""
                for letter in stringPrice.characters {
                    switch (letter) {
                    case "0"..."9":
                        price += String(letter)
                    default :
                        break
                    }
                }
                
                let availability = searchInfo(code, start: "Stock\" />", end: " </span> </span><div")
                
                let startRange = code.rangeOfString("/div></div></li>")!
                code = code.substringFromIndex(startRange.endIndex)
                let info = ["image": image, "title": title, "article": article, "price": price, "availability": availability, "productLink": productLink]
                productInfo.append(info)
            }
        }
        return productInfo
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
    
    func getStoresInfo(link: String) -> (storeInfo: [[[String: String]]], cities: [String]) {
        let dataMainPage = NSData(contentsOfURL: NSURL(string: link)!)
        if let dataMainPage = dataMainPage {
            let sourceHtmlCode = String(data: dataMainPage, encoding: NSUTF8StringEncoding)!
            var code = searchInfo(sourceHtmlCode, start: "Сеть бутиков", end: "footer")
            while code.containsString("city_name\">") {
                var infoDict = [[String: String]]()
                var codeBlock = searchInfo(code, start: "<div class=\"city\">", end: "\"></div></div></div>")
                let city = searchInfo(codeBlock, start: "city_name\">", end: "</div>")
                
                while codeBlock.containsString("\" src=\"") {
                    let image = searchInfo(codeBlock, start: "\" src=\"", end: "\" alt=\"\" /></div>")
                    var name = searchInfo(codeBlock, start: "store_name\">", end: "</div><div class=\"store_address")
                    name = searchUnicode(name)
                    let address = searchInfo(codeBlock, start: "store_address\">", end: "</div><div class=\"clear")
                    
                    let startRange = codeBlock.rangeOfString("clear")!
                    codeBlock = codeBlock.substringFromIndex(startRange.endIndex)
                    
                    let info = ["image": image, "name": name, "address": address]
                    infoDict.append(info)
                }
                storeInfo.append(infoDict)
                if !cities.contains(city) {
                    cities.append(city)
                }
                let startRange = code.rangeOfString("clear\"></div></div></div>")!
                code = code.substringFromIndex(startRange.endIndex)
            }
        }
        return (storeInfo, cities)
    }
    
}