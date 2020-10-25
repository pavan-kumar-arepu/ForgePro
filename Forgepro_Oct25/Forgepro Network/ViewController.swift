//
//  ViewController.swift
//  Forgepro Network
//
//  Created by Murali Sai Tummala on 25/05/20.
//  Copyright © 2020 Forgepro Network. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    static let weburl = "https://m.forgepro.app/";
    static let host = URL(string: ViewController.weburl)?.host;
    
    
    //MARK: - IBOutlet's
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadWebView: WKWebView!
    var popupWebView: WKWebView?
    
    //MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupWebView()
        loadWebbrowser()
        
    }
    func setupWebView() {
        
        loadWebView.uiDelegate = self
        loadWebView.allowsBackForwardNavigationGestures = true
        loadWebView.uiDelegate = self
        loadWebView.navigationDelegate = self
        
        //      loadWebView.configuration.preferences.javaScriptEnabled = true;
        //loadWebView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true;
        
    }
    
    // Load webview
    func loadWebbrowser(){
        let myURL = URL(string:ViewController.weburl)
        let myRequest = URLRequest(url: myURL!)
        loadWebView.load(myRequest)
    }
    
    // Show activity indicator
    fileprivate func showActivityIndicator(show: Bool) {
        if show {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}


//MARK: - WKNavigation Delegates

extension ViewController:  WKNavigationDelegate{
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Set the indicator everytime webView started loading
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        guard let reqUrl = webView.url else {
            return
        }
        // Show main ActivityIndicator for first load only As loader is already present in webbrowswer for different navigations.
        if reqUrl.absoluteString.elementsEqual(ViewController.weburl) {
            self.showActivityIndicator(show: true)
        }
        
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        self.showActivityIndicator(show: false)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.showActivityIndicator(show: false)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        if ["tel", "sms", "mailto"].contains(url.scheme) && UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
        } else {
            if let host = navigationAction.request.url?.host {
                if host.elementsEqual(ViewController.host!) || host.contains("google.com"){
                    decisionHandler(.allow)
                }
                else{
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    decisionHandler(.cancel)
                }
            }
            else{
                decisionHandler(.cancel)
            }
        }
    }
}
extension ViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            guard let url = navigationAction.request.url else {
                return nil
            }
            if url.host == ViewController.host {
                webView.load(navigationAction.request)
            }
            else{
                UIApplication.shared.open(url, options: [:])
            }
        }
        return nil
        /*
         popupWebView = WKWebView(frame: view.bounds, configuration: configuration)
         popupWebView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
         popupWebView!.navigationDelegate = self
         popupWebView!.uiDelegate = self
         view.addSubview(popupWebView!)
         return popupWebView!
         */
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        webView.removeFromSuperview()
        popupWebView = nil
    }
}


