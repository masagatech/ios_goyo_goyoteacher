//
//  ApplyLeave.swift
//  GoyoTeacher
//
//  Created by admin on 04/11/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import Alamofire

class ApplyLeave: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var blurView: UIView!
    @IBOutlet var upload: UIButton!
    @IBOutlet var assignDescription: UITextView!
    @IBOutlet var assignmentTitle: UITextField!
    @IBOutlet var assignFromdate: UITextField!
    @IBOutlet var assignTodate: UITextField!
    @IBOutlet var subjectName: UIButton!
    @IBOutlet var subjectable: UITableView!
    
    var teachleaveArray: NSArray = []
    var datePicker : UIDatePicker!
    var isStartDate = Bool()
    var isEndDate = Bool()

    var  date = Date()
    var formatter = DateFormatter()
    var CurrentDate = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation
        self.navigationItem.title = "Apply leave"
        navigationBack()

        // Do any additional setup after loading the view.
        subjectable.delegate = self
        subjectable.dataSource = self
        subjectable.isHidden = true
        
        assignFromdate.delegate = self
        assignTodate.delegate = self
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy"
        let result = formatter.string(from: date)
        assignFromdate.text = result
        assignTodate.text = result
        
        assignDescription.backgroundColor = .clear
        assignDescription.layer.borderWidth = 1
        assignDescription.layer.cornerRadius = 4
        assignDescription.layer.borderColor = UIColor.black.cgColor
        
        upload.layer.cornerRadius = 10
        upload.clipsToBounds = true
        
        //blurView
        blurView.isHidden = true
        let blurEffect = UIBlurEffect(style: .light)
        let sideEffectView = UIVisualEffectView(effect: blurEffect)
        sideEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        sideEffectView.frame = self.view.bounds
        blurView.addSubview(sideEffectView)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(TouchEvent))
        gesture.delegate = self
        blurView.addGestureRecognizer(gesture)

        //current date
        formatter.dateFormat = "dd-MM-yyyy"
        CurrentDate = formatter.string(from: date)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:-- UIButton
    func TouchEvent() {
        //do stuff here
        blurView.isHidden = true
        subjectable.isHidden = true
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
    @IBAction func subjectAction(_ sender: Any) {
        subjectable.isHidden = false
        blurView.isHidden = false
        /*--------- Internet ----------- */
        if ConnectionCheck.isConnectedToNetwork() {
            TeacherDropDownAPI()
        }
        else{
            showAlert(self, message: "Make sure your device is connected to the internet.", title: "No Internet Connection")
        }
    }
    @IBAction func uploadAction(_ sender: Any) {
        
        if assignDescription.text.isEmpty {
            
            showToast(message: "Please write something about your leave")
        }
        else if (subjectName.titleLabel?.text?.isEmpty)!
        {
            showToast(message: "Please select subject name")
        }

        else
        {
            /*--------- Internet ----------- */
            if ConnectionCheck.isConnectedToNetwork() {
                teacherLeaveApplyAPI()
            }
            else{
                showAlert(self, message: "Make sure your device is connected to the internet.", title: "No Internet Connection")
            }
        }
        
    }
    //MARK:-- Tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func  tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teachleaveArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AssignmentSubjectCell
        
        cell.subjectname.text = ((teachleaveArray[indexPath.row]) as AnyObject).value(forKey: "key") as? String
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow //optional, to get from any UIButton for example
        
        let currentCell = tableView.cellForRow(at: indexPath!) as! AssignmentSubjectCell
        subjectName.setTitle(currentCell.subjectname.text, for:.normal)
        subjectName.setTitleColor(UIColor.black, for: .normal)
        tableView.isHidden = true
        
        let subjectid = ((teachleaveArray[(indexPath?.row)!]) as AnyObject).value(forKey: "autoid") as? NSNumber
        SchoolDetailsVariable.subjectID = String(format: "%@", subjectid!)
        subjectable.isHidden = true
        blurView.isHidden = true
    }
    ///MARK:-- Textfield
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            isStartDate = false
            isEndDate = true
            self.pickUpDate(assignFromdate)
        }
        else if textField.tag == 2
        {
            isEndDate = false
            isStartDate = true
            self.pickUpDate(assignTodate)
        }
    }
    
    //MARK:- Function of datePicker
    func pickUpDate(_ sender : UITextField){
        
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datePicker.backgroundColor = UIColor.white
        self.datePicker.datePickerMode = UIDatePickerMode.date
        sender.inputView = self.datePicker
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(CreateAssignmentVC.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(CreateAssignmentVC.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        sender.inputAccessoryView = toolBar
        
    }
    // MARK:- Button Done and Cancel
    func doneClick() {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .medium
        dateFormatter1.timeStyle = .none
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        if  isStartDate == false {
            assignFromdate.text = dateFormatter.string(from: datePicker.date)
            assignFromdate.resignFirstResponder()
            
        }
        else
        {
            assignTodate.text = dateFormatter.string(from: datePicker.date)
            assignTodate.resignFirstResponder()
            
        }
        
    }
    func cancelClick() {
        if  isStartDate == false {
            assignFromdate.resignFirstResponder()
            
        }
        else
        {
            assignTodate.resignFirstResponder()
        }
    }
    
    //MARK:- Web services
    func TeacherDropDownAPI()
    {
        showProgressLoader(_view: self)
        
        var param = [String: String] ()
        param["flag"] = "dropdown"
        
        Alamofire.request(Constants.getTeacherLeave, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                
                let jsonDict = response.result.value as! NSDictionary
                print(jsonDict)
                self.hideProgress()
                if jsonDict["status"] as! Int == 200
                {
                    self.teachleaveArray = jsonDict["data"] as! NSArray
                    self.subjectable.reloadData()
                }
                break
                
            case .failure(let error):
                print("Request failed with error: \(error)")
                self.showAlert(self, message: "The Request Timed Out", title: "")
                break
                
            }
        }
    }
    
    func teacherLeaveApplyAPI()
    {
        showProgressLoader(_view: self)
        
        var param = [String: String] ()
        param["lvfor"] = "teacher"
        param["lvid"] = "0"
        param["lvtype"] = SchoolDetailsVariable.subjectID
        param["reason"] = assignDescription.text
        param["frmdt"] = assignFromdate.text
        param["todt"] = assignTodate.text
        param["psngrid"] = UserDefaults.standard.string(forKey: "UID")!
        param["cuid"] = UserDefaults.standard.string(forKey: "UCODE")!
        param["enttid"] = UserDefaults.standard.string(forKey: "EnttID")!
        param["mob_createdon"] = CurrentDate
        
        Alamofire.request(Constants.getSaveTeacherLeave, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                
                let jsonDict = response.result.value as! NSDictionary
                print(jsonDict)
                self.hideProgress()
                if jsonDict["status"] as! Int == 200
                {
                    let alertController = UIAlertController(title: "Leave", message: "Saved Successfully", preferredStyle:UIAlertControllerStyle.alert)
                    
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
                    { action -> Void in
                        
                        if let navigation = self.navigationController {
                            navigation.popViewController(animated: true)
                        }
                    })
                    
                    self.present(alertController,animated: true, completion: nil)
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
