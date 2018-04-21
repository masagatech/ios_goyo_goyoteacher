//
//  ViewController.swift
//  GoyoTeacher
//
//  Created by admin on 24/10/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import Alamofire


class ViewController: UIViewController {
    let defaults = UserDefaults.standard
    
    @IBOutlet var loginBtn: UIButton!
    @IBOutlet var userPassword: UITextField!
    @IBOutlet var userName: UITextField!
    
    var loginArray: NSMutableArray = []
    var enttd:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationController?.navigationBar.isHidden = true
        //design
        loginBtn.layer.cornerRadius = 5.0
        loginBtn.clipsToBounds = true
        
        showImage(text: userName, image: "email")
        let leftImageView = UIImageView()
        leftImageView.image = UIImage(named: "psw")
        let leftView = UIView()
        leftView.addSubview(leftImageView)
        leftView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        leftImageView.frame = CGRect(x: 0, y: 10, width: 30, height: 30)
        userPassword.rightViewMode = .always
        userPassword.rightView = leftView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- UIButton Actions
    @IBAction func login(_ sender: UIButton) {
        
        if (userName.text?.isEmpty)!{
            showAlert(self, message: "Please Enter UserName", title: "Login")
        }
        else if (userPassword.text?.isEmpty)!{
            showAlert(self, message: "Please Enter Password", title: "Login")
        }
        else{
            /*--------- Internet ----------- */
            if ConnectionCheck.isConnectedToNetwork() {
                LoginAPI()
                
            }
            else{
                showAlert(self, message: "Make sure your device is connected to the internet.", title: "No Internet Connection")
            }
        }
    }
    //MARK:- Webservices
    func LoginAPI()
    {
        showProgressLoader(_view: self)
        var param = [String: String] ()
        param["email"] = userName.text
        param["pwd"] = userPassword.text
        param["type"] = "tchr"
        param["otherdetails"] = "[]"
        
        Alamofire.request(Constants.loginDetails, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                
                let jsonDict = response.result.value as! NSDictionary
                print(jsonDict)
                self.hideProgress()
                if jsonDict["status"] as! Int == 200
                {
                    if let data = jsonDict["data"] as? [[String:Any]],
                        !data.isEmpty
                    {
                        let status = data[0]["status"] as! NSNumber
                        let statusCode = String(format: "%@", status)
                        if statusCode == "0"
                        {
                            self.hideProgress()
                            self.showAlert(self, message: "Invalid User Code / Mobile", title: "Warning !")
                        }
                        else
                        {
                            let loginid = data[0]["uid"] as! NSNumber
                            self.enttd =  data[0]["enttid"] as! String
                            
                            let ucode = data[0]["ucode"] as! String
                            self.defaults.set(ucode, forKey: "UCODE")
                            
                            let loginID = String(format: "%@", loginid)
                            self.defaults.set(loginID, forKey: "UID")
                            self.defaults.set(self.enttd, forKey: "EnttID")
                            
                            self.defaults.set(true, forKey: "Home")
                            self.defaults.set(false, forKey: "Logout")
                            
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let loginView = storyboard.instantiateViewController(withIdentifier: "ClassDetailsVC") as! ClassDetailsVC
                            self.present(loginView, animated:true, completion:nil)
                        }
                    }
                }
                else
                {
                    self.showAlert(self, message: "Please Check your details", title: "")
                }
                break
                
            case .failure(let error):
                print("Request failed with error: \(error)")
                self.showAlert(self, message: "The Request Timed Out", title: "")
                break
                
            }
        }
    }
}



