//
//  ViewController.swift
//  Browser
//
//  Created by Mohit Kumar on 18/01/17.
//  Copyright © 2017 Mohit Kumar. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController,UITextFieldDelegate,WKNavigationDelegate {
    
    //MARK:- Properties
    
    var webView: WKWebView
    
    
    //MARK:- Outlets
    
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    @IBOutlet weak var progressView: UIProgressView!
    
    
    required init?(coder aDecoder: NSCoder) { //WKWebView initializer methdod
        
        self.webView = WKWebView(frame: .zero)
        super.init(coder: aDecoder)
        self.webView.navigationDelegate = self
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        barView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 70)
        
//        view.addSubview(webView)
        view.insertSubview(webView, belowSubview: progressView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addContraintsWithFormat(format: "H:|[v0]|", views: webView)
        view.addContraintsWithFormat(format: "V:|-70-[v0]-44-|", views: webView)
        
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        let url = URL(string: "https://www.apple.com")
        let urlRequest = URLRequest(url: url!)
        webView.load(urlRequest)
        
        backButton.isEnabled = false
        forwardButton.isEnabled = false
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {//This will take care of view when device orientation change
        barView.frame = CGRect(x:0, y: 0, width: size.width, height: 70)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "loading"){
            backButton.isEnabled = webView.canGoBack
            forwardButton.isEnabled = webView.canGoForward
        }
        if(keyPath == "estimatedProgress"){ //This updates progress view and hides it when loading completes
            progressView.isHidden = webView.estimatedProgress == 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    //MARK:- UITextfield Delegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var url:String = ""
        urlField.resignFirstResponder()
        if let urlString = urlField.text{
            url = "https://www."+"\(urlString)"
        }
        print(url)
        webView.load(URLRequest(url: URL(string: url)!))
        return false
    }
    
    //MARK:- WKWebView Delegate
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.setProgress(0.0, animated: false)
    }
    
    //MARK:- Actions
    
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    
    @IBAction func forward(_ sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    
    @IBAction func reload(_ sender: UIBarButtonItem) {
        let request = URLRequest(url: webView.url!)
        webView.load(request)
    }

}

extension UIView{
    func addContraintsWithFormat(format: String,views : UIView...){
        var viewsDictionary = [String:UIView]()
        for(index,view) in views.enumerated(){
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

