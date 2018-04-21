//
//  AboutUs.swift
//  GoyoTeacher
//
//  Created by admin on 10/11/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import MessageUI
class AboutUs: UIViewController,MFMailComposeViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBack()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- Navigation Controller
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
        dismiss(animated: true, completion: nil)
    }
    @IBAction func website(_ sender: Any) {
        
        let url = URL(string: "http://goyo.in/")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            //If you want handle the completion block than
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                print("Open url : \(success)")
            })
        }
    }
    @IBAction func contact(_ sender: Any) {
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            showAlert(self, message: "Mail services are not available", title: "Set Up")
            return
        }
        sendEmail()
    }
    func sendEmail() {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.setToRecipients(["info@goyo.in"])
        composeVC.setSubject("Hello!")
        composeVC.setMessageBody("Hello this is my message body!", isHTML: false)
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
}
