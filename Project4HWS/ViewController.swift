//
//  ViewController.swift
//  Project4HWS
//
//  Created by Christian Lorenzo on 8/27/19.
//  Copyright © 2019 Christian Lorenzo. All rights reserved.
//

import UIKit
import WebKit  //Bringing the webkit framework

class ViewController: UIViewController, WKNavigationDelegate { //we added WKNavigation to fix the error for webView.navigationDelegate = self "below"
    var webView: WKWebView!
    var progressView: UIProgressView!
    var webSites = ["google.com", "apple.com", "hackingwithswift.com"]
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self //Delegation, when any webpage navigation happens.
        view = webView
    }
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) //this creates a flexible space
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))//this will reload the webview in place.
        
        
        progressView = UIProgressView(progressViewStyle: .default) //Initializer or instance
        progressView.sizeToFit() //This is to show the full progress view on entire screen
        let progressButton = UIBarButtonItem(customView: progressView)//Creates a new button and an initializer creating a custom view.
        
        toolbarItems = [progressButton, spacer, refresh] //this creates an array
        navigationController?.isToolbarHidden = false //the tool property will show.
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        //THis code is to run the website on the app.  ----------------
        let url = URL(string: "https://" + webSites[0])! //put it like this unwrapped. We have to make sure that the url we're using has no typos -------
        
        webView.load(URLRequest(url: url)) // Here we're requesting the url by passing it.
        webView.allowsBackForwardNavigationGestures = true //allows us to go left and right.
    }

    @objc func openTapped() {
        let ac = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)
        
        for website in webSites {
            ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)

    }
    
    func openPage(action: UIAlertAction) {
        guard let actionTitle = action.title else {return}
        guard let url = URL(string: "https://" + actionTitle) else {return}
        webView.load(URLRequest(url: url))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    //This code is to be able to showe the blue progress bar on the screen to show the website loading progress.
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress) //This is a float conversion from Double to Float.
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        
        if let host = url?.host { //If the page we're loading hosted ".com"
            for website in webSites {
                if host.contains(website)   { //if it contains website anywhere then...
                    decisionHandler(.allow) // load the page then.
                    return
                }
            }
        }
        
        decisionHandler(.cancel) //If no website was found then this will cancel the loading.
    }

}

