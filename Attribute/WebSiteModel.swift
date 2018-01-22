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
    fileprivate var webView = UIWebView()
    fileprivate var isLoaded = false
    
    
    // MARK: - Public Methods
    
    func openWebSiteWithLink(_ link: String) {
        
        let url = URL(string: link)
        
        if let url = url {
            
            if self.webView.delegate == nil {
                
                webView.delegate = self
            }
            
            self.isLoaded = false
            
            let urlRequest = URLRequest(url: url)
            
            self.webView.loadRequest(urlRequest)
            
        } else {
            
            print("wrong link")
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: dataDidFailLoadNotification), object: nil)
        }
        
    }
    
    func getSourceCode() -> String? {
        
        let html = self.webView.stringByEvaluatingJavaScript(from: "document.documentElement.outerHTML")
        
        self.webView = UIWebView()
        
        return html
    }
    
    // MARK: - UIWebViewDelegate
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        if self.isLoaded == false {
            
            self.isLoaded = true
//            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            NotificationCenter.default.post(name: Notification.Name(rawValue: dataDidFinishLoadNotification), object: nil)
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        print("error load:", error.localizedDescription)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: dataDidFailLoadNotification), object: nil)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
