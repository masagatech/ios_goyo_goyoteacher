//
//  TeacherTimeTable.swift
//  GoyoTeacher
//
//  Created by admin on 08/11/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import FSCalendar
import Alamofire

class TeacherTimeTable: UIViewController, FSCalendarDelegate, FSCalendarDataSource,UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate  {
    @IBOutlet var timesubjectView: UIView!
    @IBOutlet var fetchingView: UIView!
    @IBOutlet var weekOffView: UIView!
    
    @IBOutlet var weekOffLabel: UILabel!
    @IBOutlet var heightConstant: NSLayoutConstraint!
    @IBOutlet var timetableview: UITableView!
    @IBOutlet var calendar: FSCalendar!
    
    var timetablearray : NSArray = []
    var cellAlteration: Int = 0
    var  date = Date()
    var formatter = DateFormatter()
    var CurrentDate = String()

    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //: Navigation
        self.navigationItem.title = "Time Table"
        navigationBack()
        //calendar
        calendar.delegate = self
        calendar.dataSource = self
        self.calendar.scope = .week
        self.calendar.select(Date())
        self.calendar.accessibilityIdentifier = "calendar"
        //table
        timetableview.delegate = self
        timetableview.dataSource = self
        weekOffView.isHidden = true
        //current date
        formatter.dateFormat = "MM-dd-yyyy"
        CurrentDate = formatter.string(from: date)
        // Internet
        if ConnectionCheck.isConnectedToNetwork() {
            TimeTableAPI()
            fetchingView.isHidden = true
            timetableview.isHidden = false
        }
        else{
            showAlert(self, message: "Make sure your device is connected to the internet.", title: "No Internet Connection")
            fetchingView.isHidden = false
            timetableview.isHidden = true
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
        dismiss(animated: true, completion: nil)
    }
    // MARK: - FSCalendar
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("did select date \(self.dateFormatter.string(from: date))")
        let selectedDates = calendar.selectedDates.map({self.dateFormatter.string(from: $0)})
        print("selected dates is \(selectedDates)")
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
        CurrentDate = String(format: "%@", self.dateFormatter.string(from: date))
        print(CurrentDate)
        TimeTableAPI()
        
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("\(self.dateFormatter.string(from: calendar.currentPage))")
    }

    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.heightConstant.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    //MARK: Tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timetablearray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:timetableCell = tableView.dequeueReusableCell(withIdentifier: "Cell")! as! timetableCell
        if cellAlteration == 0 {
            cell.mainView.backgroundColor = UIColor(red: 135/255, green: 206/255, blue: 250/255, alpha: 1.0)
            cellAlteration = 1
        } else {
            cell.mainView.backgroundColor = UIColor.white
            cellAlteration = 0
        }

        let frmtTime =  ((timetablearray[indexPath.row]) as AnyObject).value(forKey: "frmtm") as? String
        let toTime =  ((timetablearray[indexPath.row]) as AnyObject).value(forKey: "totm") as? String

        //removing digits
        let endIndex = frmtTime?.index((frmtTime?.endIndex)!, offsetBy: -2)
        let truncated = frmtTime?.substring(to: endIndex!)

        let finalTime = String(format: "%@-%@", truncated!, toTime!)
        cell.timeings.text = finalTime
        
        cell.subject.text =  ((timetablearray[indexPath.row]) as AnyObject).value(forKey: "subname") as? String
        
        cell.className.text = ((timetablearray[indexPath.row]) as AnyObject).value(forKey: "classname") as? String
        return cell
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        cell.contentView.backgroundColor = UIColor.clear
    }
    //MARK:- Web services
    func TimeTableAPI()
    {
        showProgressLoader(_view: self)
        var param = [String: String] ()
        param["flag"] = "byteacher"
        param["caldate"] = CurrentDate
        param["tchrid"] = UserDefaults.standard.string(forKey: "UID")!
        param["classid"] = SchoolDetailsVariable.classID
        param["enttid"] = UserDefaults.standard.string(forKey: "EnttID")!

        Alamofire.request(Constants.teacherTimeTable, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                
                let jsonDict = response.result.value as! NSDictionary
                print(jsonDict)
                self.hideProgress()
                if jsonDict["status"] as! Int == 200
                {
                    self.timetablearray = jsonDict["data"] as! NSArray
//                    let weekoff = ((self.timetablearray[0]) as AnyObject).value(forKey: "frmtm") as? String
//                     if weekoff == ""
                    if self.timetablearray.count == 0
                    {
//                        self.weekOffLabel.text = ((self.timetablearray[0]) as AnyObject).value(forKey: "subname") as? String
                        self.timetableview.isHidden = true
                        self.weekOffView.isHidden = false
                        self.timesubjectView.isHidden = true
                    }
                    else{
                        self.timetableview.isHidden = false
                        self.weekOffView.isHidden = true
                        self.timesubjectView.isHidden = false
                        self.timetableview.reloadData()
                    }
                }
                if jsonDict["status"] as! Int == 401
                {
                    self.showAlert(self, message: "Please select Class Then show your time table inside", title: "")
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
