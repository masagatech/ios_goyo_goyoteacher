//
//  TeacherLeave.swift
//  GoyoTeacher
//
//  Created by admin on 04/11/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import Alamofire

class TeacherLeave: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var leaveAddBtn: UIButton!
    @IBOutlet var fetchingView: UIView!
    @IBOutlet var tableview: UITableView!
    var leaveArray: NSArray = []
    var  jsontArray:NSArray = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Navigation
        self.navigationItem.title = "Teacher Leave Form"
        navigationBack()
        tableview.delegate = self
        tableview.dataSource = self

        // Internet
        if ConnectionCheck.isConnectedToNetwork() {
            TeacherLeaveAPI()
            leaveAddBtn.isUserInteractionEnabled = true

        }
        else{
            showAlert(self, message: "Make sure your device is connected to the internet.", title: "No Internet Connection")
            leaveAddBtn.isUserInteractionEnabled = false
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
    func backButton() {
        //do stuff here
        if let navigation = self.navigationController {
            navigation.popViewController(animated: true)
        }
    }
    //MARK: UIButton
    @IBAction func createLeave(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let leaveapply  = storyboard.instantiateViewController(withIdentifier: "ApplyLeave") as! ApplyLeave
        self.navigationController?.pushViewController(leaveapply, animated: true)
    }
    // MARK: -  Tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func  tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if leaveArray.count == 0
        {
            tableview.isHidden = true
            fetchingView.isHidden = false
            return leaveArray.count
        }
        else
        {
            tableview.isHidden = false
            fetchingView.isHidden = true
            return leaveArray.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! teacherleavecell
        
        cell.leaveType.text = ((leaveArray[indexPath.row]) as AnyObject).value(forKey: "lvtype") as? String
        
        cell.fromdate.text = ((leaveArray[indexPath.row]) as AnyObject).value(forKey: "frmdt") as? String
        
        cell.todate.text = ((leaveArray[indexPath.row]) as AnyObject).value(forKey: "todt") as? String
        
        cell.reason.text = ((leaveArray[indexPath.row]) as AnyObject).value(forKey: "reason") as? String
        
        cell.applydate.text = ((leaveArray[indexPath.row]) as AnyObject).value(forKey: "appldate") as? String
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let  heightOfRow = self.calculateHeight(inString: (((leaveArray[indexPath.row]) as AnyObject).value(forKey: "reason") as? String)!)
        return (heightOfRow + 130.0)
    }

    //MARK:- Web services
    func TeacherLeaveAPI()
    {
        showProgressLoader(_view: self)
        //        self.fetchingView.isHidden = false
        
        var param = [String: String] ()
        param["flag"] = "tchrleave"
        param["enttid"] = UserDefaults.standard.string(forKey: "EnttID")!
        param["tchrid"] = UserDefaults.standard.string(forKey: "UID")!
        param["classid"] = SchoolDetailsVariable.classID
        
        Alamofire.request(Constants.getTeacherLeave, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                
                let jsonDict = response.result.value as! NSDictionary
                print(jsonDict)
                self.hideProgress()
                if jsonDict["status"] as! Int == 200
                {
                    self.jsontArray = jsonDict["data"] as! NSArray
                    self.leaveArray = self.jsontArray.reversed() as NSArray
                    self.tableview.reloadData()
                    
                }
                break
                
            case .failure(let error):
                print("Request failed with error: \(error)")
                self.fetchingView.isHidden = false
                self.showAlert(self, message: "The Request Timed Out", title: "")
                break
                
            }
        }
    }

}
