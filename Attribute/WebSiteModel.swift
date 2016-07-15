//
//  WebSiteModel.swift
//  Attribute
//
//  Created by Yaroslav Chyzh on 7/13/16.
//  Copyright © 2016 Yaroslav Chyzh. All rights reserved.
//

import UIKit

let dataDidFinishLoadNotification = "dataDidFinishLoadNotification"
let dataDidFailLoadNotification = "dataDidFailLoadNotification"

class WebSiteModel: NSObject, UIWebViewDelegate {
    
    static let sharedInstance = WebSiteModel()
    private var webView = UIWebView()
    private var isLoaded = false
    
    
    func openWebSiteWithLink(link: String) {
        
        let url = NSURL(string: link)
        
        if let url = url {
            
            self.isLoaded = false
            
            self.webView.delegate = self
            let urlRequest = NSURLRequest(URL: url)
            
            self.webView.loadRequest(urlRequest)
            
        } else {
            
            print("wrong link")
        }
        
    }
    
    func getSourceCode() -> String? {
        
        let html = self.webView.stringByEvaluatingJavaScriptFromString("document.documentElement.outerHTML")
        
        self.webView = UIWebView()
        
        return html
    }
    
    // MARK: - UIWebViewDelegate
    
    func webViewDidStartLoad(webView: UIWebView) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        if self.isLoaded == false {
            
            self.isLoaded = true
            
            NSNotificationCenter.defaultCenter().postNotificationName(dataDidFinishLoadNotification, object: nil)
            
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        
        print("error load:", error?.localizedDescription)
        
        NSNotificationCenter.defaultCenter().postNotificationName(dataDidFailLoadNotification, object: nil)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
}
