//
//  WebViewCacher.swift
//  SUI-Connector
//
//  Created by Dom on 25.01.18.
//  Copyright © 2018 Dom. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class WebViewCacher: NSObject, WKNavigationDelegate {
    
    private var webView: WKWebView?
    private var suiCallback: CollectorSuiCallback?
    
    public func loadURLInWebView(url: URL, callback: @escaping CollectorSuiCallback) {
        self.suiCallback = callback
        
        DispatchQueue.main.async {
            let webView = WKWebView(frame: CGRect(x: 20, y: 20, width: 1, height: 1))
            var request = URLRequest(url: url)
            request.cachePolicy = .useProtocolCachePolicy
            self.webView = webView
            webView.isHidden = true
            webView.navigationDelegate = self
            
            if let vc = UIApplication.shared.windows.first?.rootViewController {
                vc.view.addSubview(webView)
            }
            webView.load(request)
        }
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            webView.evaluateJavaScript("document.body.innerText") { (data, error) in
                guard let result = data as? String else { return }
                
                var dict = [String: Any?]()
                do {
                    dict = try JSONSerialization.jsonObject(with: result.data(using: .utf8)!) as! [String: Any]
                } catch {
                    print(error.localizedDescription)
                }
                
                if dict["id"] != nil {
                    self.suiCallback?(dict["id"] as! String)
                }
            }
        }
    }
}

class URLCacher: Foundation.URLCache {
    
    var cachers: [WebViewCacher] = []
    
    public override init() {
        let kB = 1024
        let MB = kB * 1024
        super.init(memoryCapacity: 3 * MB, diskCapacity: 3 * MB, diskPath: nil)
    }
    
    private func synchronized<T>(_ lockObj: AnyObject!, closure: () -> T) -> T {
        objc_sync_enter(lockObj)
        let value: T = closure()
        objc_sync_exit(lockObj)
        return value
    }
    
    func loadURLInWebView(_ url: URL, callback: @escaping CollectorSuiCallback) {
        let webViewCacher = WebViewCacher()
        
        synchronized(self) {
            self.cachers.append(webViewCacher)
        }
        
        webViewCacher.loadURLInWebView(url: url, callback: callback)
    }
}
