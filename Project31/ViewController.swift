//
//  ViewController.swift
//  Project31
//
//  Created by Michael James on 2/17/16.
//  Copyright © 2016 Michael James. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var addressBar: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var instructionsView: UIView!
    
    weak var activeWebView: WKWebView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaultTitle()
        
        let add = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addWebView")
        let delete = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "deleteWebView")
        navigationItem.rightBarButtonItems = [delete, add]
    }
    
    func setDefaultTitle() {
        title = "Multibrowser"
        
        if !stackView.arrangedSubviews.contains(instructionsView) {
            addInstructionsPlaceholder()
        }
    }
    
    func addInstructionsPlaceholder() {
        stackView.addArrangedSubview(instructionsView)
        addressBar.text = ""
        addressBar.enabled = false
    }
    
    func removeInstructionsPlaceholder() {
        if stackView.arrangedSubviews.indexOf(instructionsView) != nil {
            stackView.removeArrangedSubview(instructionsView)
            addressBar.enabled = true
        }
    }
    
    func addWebView() {
        removeInstructionsPlaceholder()
        
        let webView = WKWebView()
        webView.navigationDelegate = self
        
        stackView.addArrangedSubview(webView)
        
        let url = NSURL(string: "https://hackingwithswift.com")!
        webView.loadRequest(NSURLRequest(URL: url))
        
        webView.layer.borderColor = UIColor.blueColor().CGColor
        selectWebView(webView)
        
        let recognizer = UITapGestureRecognizer(target: self, action: "webViewTapped:")
        recognizer.delegate = self
        webView.addGestureRecognizer(recognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func selectWebView(webView: WKWebView) {
        for view in stackView.arrangedSubviews {
            view.layer.borderWidth = 0
        }
        
        activeWebView = webView
        webView.layer.borderWidth = 3
        
        updateUIUsingWebView(webView)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let webView = activeWebView, var address = addressBar.text {
            
            if !address.lowercaseString.hasPrefix("http://") && !address.lowercaseString.hasPrefix("https://") {
                address = "http://\(address)"
            }
            
            if let url = NSURL(string: address) {
                webView.loadRequest(NSURLRequest(URL: url))
            }
        }
        
        textField.resignFirstResponder()
        return true
    }

    func webViewTapped(recognizer: UITapGestureRecognizer) {
        if let selectedWebView = recognizer.view as? WKWebView {
            selectWebView(selectedWebView)
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func deleteWebView() {
        if let webView = activeWebView {
            if let index = stackView.arrangedSubviews.indexOf(webView) {
                stackView.removeArrangedSubview(webView)
                
                webView.removeFromSuperview()
                
                if stackView.arrangedSubviews.count == 0 {
                    setDefaultTitle()
                } else {
                    var currentIndex = Int(index)
                    
                    if currentIndex == stackView.arrangedSubviews.count {
                        currentIndex = stackView.arrangedSubviews.count - 1
                    }
                    
                    if let newSelectedWebView = stackView.arrangedSubviews[currentIndex] as? WKWebView {
                        selectWebView(newSelectedWebView)
                    }
                }
            }
        }
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        if traitCollection.horizontalSizeClass == .Compact {
            stackView.axis = .Vertical
        } else {
            stackView.axis = .Horizontal
        }
    }
    
    func updateUIUsingWebView(webView: WKWebView) {
        title = webView.title
        addressBar.text = webView.URL?.absoluteString ?? ""
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        if webView == activeWebView {
            updateUIUsingWebView(webView)
        }
    }
}

