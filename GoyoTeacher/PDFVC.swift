//
//  PDFVC.swift
//  GoyoParent
//
//  Created by admin on 14/12/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import Foundation

class PDFVC: UIViewController, UIWebViewDelegate {

    @IBOutlet var pdfweb: UIWebView!
   
    @IBOutlet var myActivityIndicator: UIActivityIndicatorView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBack()
        pdfweb.scalesPageToFit = true
        pdfweb.contentMode = .scaleAspectFit
         loadFromUrl()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- UINavigaton
    func navigationBack(){
        // create the button
        let button = UIButton.init(type: .custom)
        let backImg  = UIImage(named: "back")!.withRenderingMode(.alwaysOriginal)
        button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        button.setImage(backImg, for: UIControlState.normal)
        button.addTarget(self, action:#selector(backButton), for: UIControlEvents.touchUpInside)
        // here where the magic happens, you can shift it where you like
        button.transform = CGAffineTransform(translationX: 10, y: 0)
        // add the button to a container, otherwise the transform will be ignored
        let suggestButtonContainer = UIView(frame: button.frame)
        suggestButtonContainer.addSubview(button)
        let leftbarButton = UIBarButtonItem(customView: suggestButtonContainer)
        // add button shift to the side
        navigationItem.leftBarButtonItem = leftbarButton
    }
    func backButton()
    {
        if let navigation = self.navigationController {
            navigation.popViewController(animated: true)
        }
        dismiss(animated: true, completion: nil)
    }
    //MARK:- WebView
    func loadFromUrl(){
        let url =  NSURL(string:SchoolDetailsVariable.pdfurl!)
        pdfweb.loadRequest(URLRequest.init(url: url! as URL))
    }
    func webViewDidStartLoad(_ webView: UIWebView)
    {
        myActivityIndicator.startAnimating()
    }
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        myActivityIndicator.stopAnimating()
    }
}
