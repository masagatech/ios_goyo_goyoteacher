//
//  UserProfileVC.swift
//  GoyoParent
//
//  Created by admin on 07/11/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import Alamofire

class UserProfileVC: UIViewController {
    @IBOutlet var state: UILabel!
    @IBOutlet var area: UILabel!
    @IBOutlet var city: UILabel!
    @IBOutlet var userEmail: UITextField!
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userMobileNumber: UITextField!
    @IBOutlet var userName: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBack()
        profileAPI()
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
    //MARK: Web service
    func profileAPI()
    {
        showProgressLoader(_view: self)
        
        var param = [String: String] ()
        param["flag"] = "teacher"
        param["uid"] = UserDefaults.standard.string(forKey: "UID")!
        param["enttid"] = UserDefaults.standard.string(forKey: "EnttID")!
        
        Alamofire.request(Constants.userProfile, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                
                let jsonDict = response.result.value as! NSDictionary
                print(jsonDict)
                self.hideProgress()
                if jsonDict["status"] as! Int == 200
                {
                    if  let userData = jsonDict["data"] as? [[String:Any]]
                   {
                    
                    self.userName.text = userData[0]["uname"] as? String
                    self.userMobileNumber.text = userData[0]["mobile"] as? String
                    self.userEmail.text = userData[0]["email"] as? String
                    self.area.text = userData[0]["area"] as? String
                    self.city.text = userData[0]["city"] as? String
                    self.state.text = userData[0]["state"] as? String
                    }
                  
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
