//
//  ClassAtendance.swift
//  GoyoTeacher
//
//  Created by admin on 25/10/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import Alamofire
import Foundation


class ClassAtendance: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var remark: UILabel!
    @IBOutlet var topView: UIView!
    @IBOutlet var fetchingView: UIView!
    @IBOutlet var studentRemark: UITextView!
    @IBOutlet var holidayStatus: UILabel!
    @IBOutlet var holidayImage: UIImageView!
    @IBOutlet var holidayView: UIView!
    @IBOutlet var attendanceTable: UITableView!
    
    var attendanceArray: NSArray = []
    var isLeave = Bool()
    var status = String()
    var studentIsON  = String()
    var stdpasngerid:NSMutableArray = []
    var  date = Date()
    var formatter = DateFormatter()
    var CurrentDate = String()
    var rowsswitchChecked: NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = SchoolDetailsVariable.navigationTitle
        navigationBack()

        attendanceTable.delegate = self
        attendanceTable.dataSource = self
        attendanceTable.backgroundColor = UIColor.lightText
        self.holidayView.isHidden = true
        
        //current date
        formatter.dateFormat = "MM-dd-yyyy"
        CurrentDate = formatter.string(from: date)
        //textview
        studentRemark.delegate = self
        studentRemark.text = "Please Write Remark of the student"
        studentRemark.textColor = UIColor.lightGray
        
        /*--------- Internet ----------- */
        if ConnectionCheck.isConnectedToNetwork() {
            ClassAttendanceAPI()
            fetchingView.isHidden = true
            attendanceTable.isHidden = false
            topView.isHidden = false
            remark.isHidden = false
            studentRemark.isHidden = false
            saveButton.isHidden = false
            
        }
        else{
            showAlert(self, message: "Make sure your device is connected to the internet.", title: "No Internet Connection")
            fetchingView.isHidden = false
            attendanceTable.isHidden = true
            topView.isHidden = true
            remark.isHidden = true
            studentRemark.isHidden = true
            saveButton.isHidden = true
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
    //MARK:- UITextview
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            studentRemark.text = nil
            studentRemark.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            studentRemark.text = "Please Write Remark of the student"
            studentRemark.textColor = UIColor.lightGray

        }
    }
    
    //MARK:- UIButton Action
    @IBAction func save(_ sender: Any)
    {
        if studentIsON == ""{
            showAlert(self, message: "Please Select Student", title: "")
        }
        else  if studentRemark.text == nil {
            showAlert(self, message: "Please write student remark", title: "")
        }
        else
        {
            /*--------- Internet ----------- */
            if ConnectionCheck.isConnectedToNetwork() {
                SaveAttendanceAPI()
                fetchingView.isHidden = true
                attendanceTable.isHidden = false
                topView.isHidden = false
                remark.isHidden = false
                studentRemark.isHidden = false
                saveButton.isHidden = false
            }
            else{
                showAlert(self, message: "Make sure your device is connected to the internet.", title: "No Internet Connection")
                fetchingView.isHidden = false
                attendanceTable.isHidden = true
                topView.isHidden = true
                remark.isHidden = true
                studentRemark.isHidden = true
                saveButton.isHidden = true
            }
        }
        
    }
    // MARK: - tableview
    func  tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attendanceArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! AttendanceCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell") as! AttendanceCell
        }
        //roll no
        let rollno =  ((attendanceArray[indexPath.row] ) as AnyObject).value(forKey: "rollno") as? NSNumber
        if rollno == nil{
            
        }
        else {
            cell.rollNumber.text = String(format: "%@", rollno!)
        }
        
        cell.name.text = ((attendanceArray[indexPath.row] ) as AnyObject).value(forKey: "psngrname") as? String
        //remark
        let remark = ((attendanceArray[indexPath.row] ) as AnyObject).value(forKey: "lvremark") as? String
        if remark == nil
        {
            cell.remark.isHidden = true
        }
        else
        {
            cell.remark.isHidden = false
            cell.remark.text = String(format: "Remark:%@", remark!)
        }
        //leave
        isLeave =  (((attendanceArray[indexPath.row] ) as AnyObject).value(forKey: "isleave") as? Bool)!
        if isLeave == false
        {
            cell.leave.image = UIImage(named: "cancel.png")
            cell.present.isHidden = false
        }
        else
        {
            cell.leave.image = UIImage(named: "right.png")
            cell.present.isHidden = true

        }
        //uiswitch
        cell.present.tag = indexPath.row
        if rowsswitchChecked.contains(indexPath.row){
            cell.present.isOn = false
        }
        else {
            status = (((attendanceArray[indexPath.row] ) as AnyObject).value(forKey: "status") as? String)!
            if status == "a"
            {
                cell.present.isOn = false
            }
            else if status == "p"
            {
                cell.present.isOn = true

            }
            else if status == "l"
            {
                cell.present.isHidden = true
            }
        }
        cell.present.addTarget(self, action:#selector(self.SwitchToggle) , for: .valueChanged)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let  heightOfRow = self.calculateHeight(inString: (((attendanceArray[indexPath.row]) as AnyObject).value(forKey: "psngrname") as? String)!)
        return (heightOfRow+50.0)
    }
    // MARK:- Switch Toggle
    func SwitchToggle(sender: UISwitch) {
        let id  = ((attendanceArray[sender.tag]) as AnyObject).value(forKey: "psngrid") as? String
        if  sender.isOn == false
        {
            studentIsON = "a"
            let psngrid = id!
            stdpasngerid.add(psngrid)
            rowsswitchChecked.add(sender.tag)
        }
        else
        {
            stdpasngerid.remove(id!)
            rowsswitchChecked.remove(sender.tag)
        }
        print(stdpasngerid)
        
        return
    }
    //MARK:-  Webservices
    func ClassAttendanceAPI()
    {
        var param = [String: String] ()
        param["flag"] = "student"
        param["uid"] = UserDefaults.standard.string(forKey: "UID")!
        param["enttid"] = UserDefaults.standard.string(forKey: "EnttID")!
        param["classid"] = SchoolDetailsVariable.classID
        
        
        Alamofire.request(Constants.getclassAttendance, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                
                let jsonDict = response.result.value as! NSDictionary
                print(jsonDict)
                if jsonDict["status"] as! Int == 200
                {
                    self.attendanceArray = jsonDict["data"] as! NSArray
                    if self.attendanceArray.count == 0
                    {
                        
                    }else {
                        let weekoff = ((self.attendanceArray[0] ) as AnyObject).value(forKey: "status") as? String
                        if weekoff == "wo" || weekoff == "hld"
                        {
                            self.holidayView.isHidden = false
                            self.attendanceTable.isHidden = true
                            let weekhld = ((self.attendanceArray[0] ) as AnyObject).value(forKey: "statusdesc") as? String
                            self.holidayStatus.text = String(format: "Today Holiday: %@", weekhld!)
                            
                        }
                        else{
                            self.holidayView.isHidden = true
                            self.attendanceTable.isHidden = false
                            self.attendanceTable.reloadData()
                        }
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
    
    func SaveAttendanceAPI()
    {
        let objCMutableArray = NSMutableArray(array: stdpasngerid)
        if let convertingarraytostring = objCMutableArray as NSArray as? [String] {
            // Use swiftArray here
            print(convertingarraytostring)

            showProgressLoader(_view: self)
            var param = [String: Any] ()
            param["psngrtype"] = "student"
            param["psngrid"] = convertingarraytostring
            param["attnddate"] = CurrentDate
            param["isactive"] = "true"
            param["status"] = studentIsON
            param["cuid"] = UserDefaults.standard.string(forKey: "UCODE")!
            param["enttid"] = UserDefaults.standard.string(forKey: "EnttID")!
            param["classid"]  = SchoolDetailsVariable.classID
            param["remark"] = studentRemark.text


            Alamofire.request(Constants.getsaveAttendance, method: .post, parameters: param, encoding: JSONEncoding.prettyPrinted, headers: nil).responseJSON { (response:DataResponse<Any>) in

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
                            let msg = data[0]["funsave_attendance"] as! [String:Any]
                            let msgtext = msg["msg"]

                            let alertController = UIAlertController(title: "", message: msgtext as? String, preferredStyle:UIAlertControllerStyle.alert)

                            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
                            { action -> Void in

                                if let navigation = self.navigationController {
                                    navigation.popViewController(animated: true)
                                }

                            })
                            self.present(alertController,animated: true, completion: nil)
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
}
//MARK:- Other
extension Collection where Iterator.Element == [String:AnyObject] {
    func toJSONString(options: JSONSerialization.WritingOptions = .prettyPrinted) -> String {
        if let arr = self as? [[String:AnyObject]],
            let dat = try? JSONSerialization.data(withJSONObject: arr, options: options),
            
            let str = String(data: dat, encoding: String.Encoding(rawValue: String.Encoding.ascii.rawValue)) {
            return str
        }
        return "[]"
    }
}


