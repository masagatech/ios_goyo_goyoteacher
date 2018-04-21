//
//  ResultExamDetailsVC.swift
//  GoyoParent
//
//  Created by admin on 16/10/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import Alamofire


class ResultExamDetailsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var examDate: UILabel!
    
    @IBOutlet var examTimings: UILabel!
    @IBOutlet var examDateView: UIView!
    @IBOutlet var fetchingView: UIView!
    @IBOutlet var tableview: UITableView!
    
    let userDefult = UserDefaults.standard
    var ratingDouble: Double = 0/100
    var number = NSNumber()
    
    let kCloseCellHeight: CGFloat = 130 //foreground
    let kOpenCellHeight: CGFloat = 350 //container
    let kRowsCount = 100
    var cellHeights: [CGFloat] = []
    var resultExamDetailArray: NSArray = []
    
    var rollNumber:String?
    var status:String?
    var stdname:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Navigation
        self.navigationItem.title = SchoolDetailsVariable.navigationTitle
        navigationBack()
        //tableview
        tableview.delegate = self
        tableview.dataSource = self
        tableview.backgroundColor = UIColor(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 1.0)
        // Internet
        if ConnectionCheck.isConnectedToNetwork() {
            ResultExamsSemsterDetailsAPI()
            setup()
        }
        else{
            showAlert(self, message: "Make sure your device is connected to the internet.", title: "No Internet Connection")
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
    //MARK:- Tableview
    private func setup() {
        cellHeights = Array(repeating: kCloseCellHeight, count: kRowsCount)
        tableview.estimatedRowHeight = kCloseCellHeight
        tableview.rowHeight = UITableViewAutomaticDimension
        tableview.backgroundColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1.0)
    }
    func  tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultExamDetailArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FoldingCell

        rollNumber =  ((resultExamDetailArray[indexPath.row] ) as AnyObject).value(forKey: "rollno") as? String
        
        status =  ((resultExamDetailArray[indexPath.row] ) as AnyObject).value(forKey: "status") as? String
        
        stdname =  ((resultExamDetailArray[indexPath.row] ) as AnyObject).value(forKey: "studname") as? String
        
        //rool number
        if rollNumber == nil {
            cell.resultStudentNumber.text = ""
        }else {
            cell.resultStudentNumber.text = String(format: "Roll No: %@", rollNumber!)
        }
        //status
        if status == nil {
            cell.resultStudentStatus.text = ""
        }else {
            cell.resultStudentStatus.text = String(format: "Status: %@", status!)
        }
        //studename
        if status == nil {
            cell.resultStudentName.text = ""
        }else {
            cell.resultStudentName.text = String(format: "Student: %@", stdname!)
        }
        //remark
        let remark =  ((resultExamDetailArray[indexPath.row] ) as AnyObject).value(forKey: "resremark") as? String
        
        cell.resultExamRemark.text = String(format: "Remark: %@", remark!)
        
        cell.examChaptername.text =  ((resultExamDetailArray[indexPath.row] ) as AnyObject).value(forKey: "chptrname") as? String
        
        let passmark =  ((resultExamDetailArray[indexPath.row] ) as AnyObject).value(forKey: "passmarks") as? NSNumber

        cell.resultStudentpassMark.text = String(format: "%@", passmark!)
        
        let totlalMark =  ((resultExamDetailArray[indexPath.row] ) as AnyObject).value(forKey: "outofmarks") as? NSNumber
        cell.examTotalMarks.text = String(format: "%@", totlalMark!)
        
        //circle progress
        let  studentmarks = ((resultExamDetailArray[indexPath.row] ) as AnyObject).value(forKey: "marks") as? String
        
        if studentmarks == "-"{
            
            cell.circleprogress.isHidden = true
        }
        else {
            if let myInteger = Int(studentmarks!) {
                number = NSNumber(value:myInteger)
                cell.circleprogress.isHidden = false
            }

            let dec = NSDecimalNumber(decimal: number.decimalValue)
            let mark = String(format: "0.%@", dec)
            let flt = CGFloat((mark as NSString).doubleValue)
            cell.circleprogress.setProgress(flt, animated: true)
            cell.circleprogress.progressBarProgressColor = UIColor(red: 152/255.0, green: 203/255.0, blue: 0.0/255.0, alpha: 1.0)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
        let  heightOfRow = self.calculateHeight(inString: (((resultExamDetailArray[indexPath.row]) as AnyObject).value(forKey: "exmchptrname") as? String)!)
        
        return heightOfRow+100
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as ResultExamDetailCell = cell else {
            return
        }
        
        cell.backgroundColor = .clear
        
        if cellHeights[indexPath.row] == kCloseCellHeight {
            
            cell.setSelected(true, animated: true)
            
        } else {
            cell.setSelected(true, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
        
        if cell.isAnimating() {
            return
        }
        
        var duration = 0.0
        let cellIsCollapsed = cellHeights[indexPath.row] == kCloseCellHeight
        if cellIsCollapsed {
            cellHeights[indexPath.row] = kOpenCellHeight
            cell.setSelected(true, animated: true)
            cell.containerView.alpha = 1.0
            cell.containerHeightConstant.constant = 360
            cell.containerViewTop.constant = 140
            
            
            duration = 0.5
        } else {
            cellHeights[indexPath.row] = kCloseCellHeight
            duration = 0.8
            cell.containerViewTop.constant = 140
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
        
    }
    //MARK: Webservices
    func ResultExamsSemsterDetailsAPI()
    {
        showProgressLoader(_view: self)
        var param = [String: String] ()
        param["flag"] = "byteacher"
        param["smstrid"] = SchoolDetailsVariable.semsterID
        param["classid"] = SchoolDetailsVariable.classID
        param["subid"] = SchoolDetailsVariable.subjectID
        param["enttid"] = UserDefaults.standard.string(forKey: "EnttID")!

        Alamofire.request(Constants.getProgressCard, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success(_):
                let jsonDict = response.result.value as! NSDictionary
                print(jsonDict)
                self.hideProgress()
                if jsonDict["status"] as! Int == 200
                {
                    self.resultExamDetailArray = jsonDict["data"] as! NSArray
                    
                    self.examDate.text = ((self.resultExamDetailArray[0] ) as AnyObject).value(forKey: "examdate") as? String
                    
                    let toTime =  ((self.resultExamDetailArray[0] ) as AnyObject).value(forKey: "totm") as? String
                    
                    let fromTime =  ((self.resultExamDetailArray[0] ) as AnyObject).value(forKey: "frmtm") as? String
                    
                    self.examTimings.text = String(format: "%@ - %@", fromTime!,toTime!)
                    
                    if self.resultExamDetailArray.count == 0
                    {
                        self.tableview.isHidden = true
                        self.fetchingView.isHidden = false
                    }
                    else
                    {
                        self.tableview.isHidden = false
                        self.fetchingView.isHidden = true
                        self.tableview.reloadData()
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
