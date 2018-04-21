//
//  AssignmentVC.swift
//  GoyoTeacher
//
//  Created by admin on 03/11/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import Alamofire

class AssignmentVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableview: UITableView!
    @IBOutlet var fetchingView: UIView!
    
    var AssignmentArray: NSArray = []
     var jsontArray: NSArray = []
    @IBOutlet var addAssignment: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Navigation
        self.navigationItem.title = "HomeWork"
        navigationBack()
    }
    override func viewWillAppear(_ animated: Bool) {
        // Internet 
        if ConnectionCheck.isConnectedToNetwork() {
           AssignmentAPI()
            addAssignment.isUserInteractionEnabled = true
        }
        else{
            showAlert(self, message: "Make sure your device is connected to the internet.", title: "No Internet Connection")
             addAssignment.isUserInteractionEnabled = false
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
    @IBAction func createAssignment(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let assignment  = storyboard.instantiateViewController(withIdentifier: "CreateAssignmentVC") as! CreateAssignmentVC
        self.navigationController?.pushViewController(assignment, animated: true)
    }
    // MARK: -  Tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func  tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if AssignmentArray.count == 0
        {
            tableview.isHidden = true
            fetchingView.isHidden = false
            return AssignmentArray.count
        }
        else
        {
            tableview.isHidden = false
            fetchingView.isHidden = true
            return AssignmentArray.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AssignmentCell
        
        cell.assignmentTitle.text = ((AssignmentArray[indexPath.row]) as AnyObject).value(forKey: "title") as? String
        
        cell.fromdate.text = ((AssignmentArray[indexPath.row]) as AnyObject).value(forKey: "frmdt") as? String
        
        cell.todate.text = ((AssignmentArray[indexPath.row]) as AnyObject).value(forKey: "todt") as? String
        
        cell.message.text = ((AssignmentArray[indexPath.row]) as AnyObject).value(forKey: "msg") as? String
        
       let subject = ((AssignmentArray[indexPath.row]) as AnyObject).value(forKey: "subname") as? String
        
         cell.assignsubject.text = String(format: "Subject:%@", subject!)
        
        let classname = ((AssignmentArray[indexPath.row]) as AnyObject).value(forKey: "classname") as? String
        
        cell.className.text = String(format: "Class:%@", classname!)
        
        return cell
    }
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
            let  heightOfRow = self.calculateHeight(inString: (((AssignmentArray[indexPath.row]) as AnyObject).value(forKey: "msg") as? String)!)
    
            return (heightOfRow + 130.0)
        }
    
    
    //MARK:- Web services
    func AssignmentAPI()
    {
        showProgressLoader(_view: self)
        self.fetchingView.isHidden = false
        var param = [String: String] ()
        param["flag"] = "byteacher"
        param["enttid"] = UserDefaults.standard.string(forKey: "EnttID")!
        param["classid"] = SchoolDetailsVariable.classID
        
        Alamofire.request(Constants.getAssignment, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                let jsonDict = response.result.value as! NSDictionary
                print(jsonDict)
                self.hideProgress()
                if jsonDict["status"] as! Int == 200
                {
                    self.jsontArray = jsonDict["data"] as! NSArray
                    self.AssignmentArray = self.jsontArray.reversed() as NSArray
                    //tableview
                    self.tableview.delegate = self
                    self.tableview.dataSource = self
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
