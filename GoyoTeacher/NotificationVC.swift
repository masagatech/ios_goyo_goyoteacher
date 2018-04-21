//
//  NotificationVC.swift
//  GoyoTeacher
//
//  Created by admin on 27/10/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import Alamofire

class NotificationVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var fetchingView: UIView!
    @IBOutlet var notificationTable: UITableView!
    
    var notificationArray: NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Navigation
        self.navigationItem.title = "Notifications"
        navigationBack()

        notificationTable.delegate = self
        notificationTable.dataSource = self
        notificationTable.backgroundColor = UIColor.lightText
        self.notificationTable.backgroundColor = UIColor(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 1.0)
        // Internet 
        if ConnectionCheck.isConnectedToNetwork() {
            NotificationAPI()
            fetchingView.isHidden = true
            notificationTable.isHidden = false
        }
        else{
            showAlert(self, message: "Make sure your device is connected to the internet.", title: "No Internet Connection")
            fetchingView.isHidden = false
            notificationTable.isHidden = true
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
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
        _ = navigationController?.popViewController(animated: true)
    }
    // MARK: - tableview
    func  tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationArray.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NotificationCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.title.text =  ((notificationArray[indexPath.row] ) as AnyObject).value(forKey: "title") as? String
        
        cell.message.text = ((notificationArray[indexPath.row] ) as AnyObject).value(forKey: "msg") as? String
        
        cell.date.text = ((notificationArray[indexPath.row] ) as AnyObject).value(forKey: "createdon") as? String
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let  heightOfRow = self.calculateHeight(inString: (((notificationArray[indexPath.row]) as AnyObject).value(forKey: "title") as? String)!)
        return (heightOfRow + 120.0)
    }
    //MARK:-  Webservices
    func NotificationAPI()
    {
        showProgressLoader(_view: self)
        var param = [String: String] ()
        param["flag"] = "byparents"
        param["uid"] = UserDefaults.standard.string(forKey: "UID")!
        param["enttid"] = UserDefaults.standard.string(forKey: "EnttID")!
        param["sendtype"] = "teacher"
        
        Alamofire.request(Constants.getNotification, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                
                let jsonDict = response.result.value as! NSDictionary
                print(jsonDict)
                self.hideProgress()
                if jsonDict["status"] as! Int == 200
                {
                    self.notificationArray = jsonDict["data"] as! NSArray
                    if self.notificationArray.count == 0
                    {
                        self.notificationTable.isHidden = true
                        self.fetchingView.isHidden = false
                    }else {
                        self.notificationTable.isHidden = false
                        self.fetchingView.isHidden = true
                        self.notificationTable.reloadData()
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
