//
//  ProgressCardVC.swift
//  GoyoTeacher
//
//  Created by admin on 02/11/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import Alamofire

class ProgressCardVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var progressTable: UITableView!
    @IBOutlet var fetchingView: UIView!
    
    var progressArray: NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Navigation
        self.navigationItem.title = "Progress Card"
        navigationBack()
        // table
        progressTable.delegate = self
        progressTable.dataSource = self
        progressTable.backgroundColor = UIColor(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 1.0)
        // Internet
        if ConnectionCheck.isConnectedToNetwork() {
            ProgressAPI()
            fetchingView.isHidden = true
            progressTable.isHidden = false
        }
        else{
            showAlert(self, message: "Make sure your device is connected to the internet.", title: "No Internet Connection")
            fetchingView.isHidden = false
            progressTable.isHidden = true
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
        if let navigation = self.navigationController {
            navigation.popViewController(animated: true)
        }
    }
    //
    //MARK: - Tableview
    func  tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return progressArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressCell", for: indexPath) as! ExamCell
        
        cell.semsterName.text = ((progressArray[indexPath.row] ) as AnyObject).value(forKey: "smstrname") as? String
        
        cell.semsterCount.text = ((progressArray[indexPath.row] ) as AnyObject).value(forKey: "countexam") as? String
        
        cell.date.text = ((progressArray[indexPath.row] ) as AnyObject).value(forKey: "examdt") as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow //optional, to get from any UIButton for example
        let semsterID =  ((progressArray[(indexPath?.row)!] ) as AnyObject).value(forKey: "smstrid") as? Int
        SchoolDetailsVariable.semsterID  = String(format: "%d", semsterID!)
        SchoolDetailsVariable.navigationTitle = (((progressArray[(indexPath?.row)!] ) as AnyObject).value(forKey: "smstrname") as? String)!

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let semsterView = storyboard.instantiateViewController(withIdentifier: "ProgressSwipeVC") as! ProgressSwipeVC
        navigationController?.pushViewController(semsterView, animated: true)
    }
    
    //MARK:- WebServices
    func ProgressAPI()
    {
        showProgressLoader(_view: self)
        self.fetchingView.isHidden = false
        
        var param = [String: String] ()
        param["flag"] = "tchrsmstrlist"
        param["enttid"] = UserDefaults.standard.string(forKey: "EnttID")!
        param["classid"] = SchoolDetailsVariable.classID
        
        Alamofire.request(Constants.getProgressCard, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                
                let jsonDict = response.result.value as! NSDictionary
                print(jsonDict)
                self.hideProgress()
                if jsonDict["status"] as! Int == 200
                {
                    self.progressArray = jsonDict["data"] as! NSArray
                    if self.progressArray.count == 0
                    {
                        self.progressTable.isHidden = true
                        self.fetchingView.isHidden = false
                    }
                    else
                    {
                        self.progressTable.isHidden = false
                        self.fetchingView.isHidden = true
                    }
                    self.progressTable.reloadData()
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
