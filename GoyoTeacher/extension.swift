//
//  extension.swift
//  GoyoTeacher
//
//  Created by admin on 25/10/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit
//MARK: - Remove white space

struct SchoolDetailsVariable {
    static var schoolLogo: String?
    static var classID : String?
    static var className: String?
    //exam
    static var semsterID: String?
    static var semsterName: String?
    //result
    static var subjectID: String?
    static var navigationTitle: String?
    //class
    static var teacherName: String?
    //content
    static var contentID: String?
    static var pdfurl: String?
}
extension UIView
{
    func viewDesign(view:UIView)
    {
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 5.0
        view.layer.shadowOpacity = 0.75
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 0.3
        view.clipsToBounds = true
    }
}
extension UIViewController
{
    func  showImage(text:UITextField ,image: String)
    {
        let leftImageView = UIImageView()
        leftImageView.image = UIImage(named: image)

        let leftView = UIView()
        leftView.addSubview(leftImageView)

        leftView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        leftImageView.frame = CGRect(x: -10, y: 0, width: 60, height: 60)
        text.rightViewMode = .always
        text.rightView = leftView
    }
    //MARK:- cell Label Height
    func calculateHeight(inString:String) -> CGFloat {
        let messageString = inString
        let attributes : [String : Any] = [NSFontAttributeName : UIFont.systemFont(ofSize: 15.0)]
        
        let attributedString : NSAttributedString = NSAttributedString(string: messageString, attributes: attributes)
        
        let rect : CGRect = attributedString.boundingRect(with: CGSize(width: 200.0, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        
        let requredSize:CGRect = rect
        return requredSize.height
    }
    //MARK:- Alert
    func showAlert(_ view: UIViewController , message: String, title: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        DispatchQueue.main.async {
            view.present(alert, animated: true, completion: nil)
        }
    }
    //show toast
    func showToast(message : String) {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        // let screenHeight = screenSize.height
        
        let toastLabel = UILabel(frame: CGRect(x: 20, y: self.view.frame.size.height-100, width: screenWidth-50, height: 30))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }

    //ACProgress
    func showProgressLoader(_view: UIViewController)
    {
        let progressView = ACProgressHUD.shared
        progressView.progressText = "Please wait..."
        progressView.showHUD()
    }
    
    func hideProgress()
    {
        ACProgressHUD.shared.hideHUD()
    }
    //MARK:- Image download
    func requestImage(url: String, success: @escaping (UIImage?) -> Void) {
        requestURL(url: url, success: { (data) -> Void in
            if let d = data {
                success(UIImage(data: d as Data))
            }
        })
    }
    func requestURL(url: String, success: @escaping (NSData?) -> Void, error: ((NSError) -> Void)? = nil) {
        NSURLConnection.sendAsynchronousRequest(
            URLRequest(url: URL (string: url)! as URL),
            queue: OperationQueue.main,
            completionHandler: { response, data, err in
                if let e = err {
                    error?(e as NSError)
                } else {
                    success(data as NSData?)
                }
        })
    }
}
