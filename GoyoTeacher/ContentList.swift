//
//  ContentList.swift
//  GoyoTeacher
//
//  Created by admin on 15/12/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import  Alamofire

class ContentList: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var fetchingView: UIView!
    
    @IBOutlet var contentTable: UITableView!
    var contentList = [contentModal]()
    override func viewDidLoad() {
        super.viewDidLoad()
        //Navigation
        self.navigationItem.title = "Teacher Content"
        navigationBack()
        // Internet
        if ConnectionCheck.isConnectedToNetwork() {
            ContentAPI()
        }
        else{
            showAlert(self, message: "Make sure your device is connected to the internet.", title: "No Internet Connection")
            contentTable.isHidden = true
            fetchingView.isHidden = false
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
        _ = navigationController?.popViewController(animated: true)
    }
    //MARK:-- Tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func  tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if contentList.count == 0 {
            fetchingView.isHidden = false
            contentTable.isHidden = true
            return contentList.count
        }else {
            fetchingView.isHidden = true
            contentTable.isHidden = false
            return contentList.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ContentListCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        let content : contentModal
        let row = indexPath.row
        content = self.contentList[row]
        cell.subjname.text = content.subjectName
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let content : contentModal
        content = self.contentList[indexPath.row]
        
        SchoolDetailsVariable.contentID = String("\(content.subjectID)")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let studentList = storyboard.instantiateViewController(withIdentifier: "ContentDetails") as! ContentDetails
        self.navigationController?.pushViewController(studentList, animated: true)
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    //MARK:-- Webservices
    func ContentAPI(){
        showProgressLoader(_view: self)
        var param = [String: String] ()
        param["flag"] = "byteachersub"
        param["enttid"] = UserDefaults.standard.string(forKey: "EnttID")!
        param["classid"] = SchoolDetailsVariable.classID
        
        Alamofire.request(Constants.getContent, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                
                let jsonDict = response.result.value as! NSDictionary
                print(jsonDict)
                self.hideProgress()
                if jsonDict["status"] as! Int == 200
                {
                    if let _Streams = jsonDict["data"] as! [NSDictionary]?
                    {
                        for  Stream in _Streams {
                            let subname = Stream["subname"] as! String
                            let subid = Stream["subid"] as! NSNumber
                            
                            let rec = contentModal(subjectName: subname, subjectID: subid)
                            self.contentList.append(rec)
                        }
                    }
                    self.fetchingView.isHidden = true
                    self.contentTable.delegate = self
                    self.contentTable.dataSource = self
                    self.contentTable.reloadData()
                }
                break
            case .failure(let error):
                print("Request failed with error: \(error)")
                
                break
            }
        }
    }
    
}
