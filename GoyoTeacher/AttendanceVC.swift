//
//  AttendanceVC.swift
//  GoyoParent
//
//  Created by admin on 25/09/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import FSCalendar
import Alamofire

class AttendanceVC: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {

    @IBOutlet var calendar: FSCalendar!
    @IBOutlet var daysofpresent: UILabel!
    @IBOutlet var daysofholidays: UILabel!
    
    let userDefult = UserDefaults.standard
    
    var  date = Date()
    var formatter = DateFormatter()
    var CurrentDate = String()
    
    var  weekOffDates  = [String]()
    var presentDates = [String]()
    var holidayDates = [String]()
    var leaveDates = [String]()
    
    var currentMonth = String()
    var buttonBar = UIView()
    
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter1: DateFormatter = {

        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //: Navigation
        self.navigationItem.title = SchoolDetailsVariable.navigationTitle
        navigationBack()
        //: Calendar
        calendar.delegate = self
        calendar.dataSource = self
        calendar.appearance.titleFont = UIFont(name: "Avenir-Book", size: 16)
        calendar.allowsSelection = false
        calendar.placeholderType = FSCalendarPlaceholderType.none
        currentMonth = getDateAsStringInUTC(date: calendar.currentPage as NSDate)
        // Internet
        if ConnectionCheck.isConnectedToNetwork() {
            print("Connected")
            AttendanceAPI()
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
    // MARK: - FsCalendar
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        currentMonth = getDateAsStringInUTC(date: calendar.currentPage as NSDate)
        AttendanceAPI()

    }
    
    func getDateAsStringInUTC(date: NSDate) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-yyyy"
        let UTCTimeAsString = dateFormatter.string(from: date as Date)
        
        return UTCTimeAsString
    }
    
    //    func calendar(_ calendar: FSCalendar, didSelect date: Date) {
    //        print(getDateAsStringInUTC(date: date as NSDate))
    //    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        
        let datestring2 : String = dateFormatter1.string(from:date)
        
        if holidayDates.contains(datestring2)
        {
            return UIColor(red: 93/255.0, green: 74/255.0, blue: 153/255.0, alpha: 1.0)
        }
        else if  presentDates.contains(datestring2)
        {
            return  UIColor(red: 252/255.0, green: 158/255.0, blue: 24/255.0, alpha: 1.0)
        }
        else if  weekOffDates.contains(datestring2)
        {
            return UIColor.red
        }
        else if  leaveDates.contains(datestring2)
        {
            return UIColor(red: 244/255.0, green: 81/255.0, blue: 30/255.0, alpha: 1.0)
        }
        return nil

    }
    
    
    // MARK: - Web services
    func AttendanceAPI()  {
        
        DispatchQueue.main.async {
            self.showProgressLoader(_view: self)
            let url = URL(string: Constants.getclassAttendance)!
            let session = URLSession.shared
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
            
            let flag = "flag=" + "teacher"
            let month = "&month=" + self.currentMonth
            let id = "&tchrid=" + UserDefaults.standard.string(forKey: "UID")!
            let enttid = "&enttid=" + UserDefaults.standard.string(forKey: "EnttID")!
            
            let paramString = flag+month+id+enttid
            
            request.httpBody = paramString.data(using: String.Encoding.utf8)
            let task = session.dataTask(with: request as URLRequest)
            {
                data,response,error in
                
                do
                {
                    if data == nil {
                        
                    }else{

                        let parsedData = try JSONSerialization.jsonObject(with: data!, options:.mutableContainers) as! NSDictionary

                        print(parsedData)
                        self.hideProgress()
                        if parsedData["status"] as! Int == 200
                        {
                            if let streams = parsedData["data"] as! [AnyObject]? {

                                for arrayOfElements in streams {

                                    let weekoff = arrayOfElements["status"] as! String

                                    if weekoff == "wo"
                                    {
                                        let week = arrayOfElements["attnddate"] as! String
                                        let somedateFromString = self.convertStringToDate(string: week)
                                        self.weekOffDates.append(somedateFromString)

                                    }
                                    else  if weekoff == "p"
                                    {
                                        let present = arrayOfElements["attnddate"] as! String
                                        let somedateFromString = self.convertStringToDate(string: present)
                                        self.presentDates.append(somedateFromString)

                                    }
                                    else  if weekoff == "hld"
                                    {
                                        let holday  = arrayOfElements["attnddate"] as! String
                                        let somedateFromString = self.convertStringToDate(string:holday)
                                        self.holidayDates.append(somedateFromString)

                                    }
                                    else  if weekoff == "l"
                                    {
                                        let holday  = arrayOfElements["attnddate"] as! String
                                        let leaves = self.convertStringToDate(string:holday)
                                        self.leaveDates.append(leaves)

                                    }
                                }

                            }
                            DispatchQueue.main.async {
                                self.calendar .reloadData()
                            }
                        }
                    }
                }
                catch {
                    
                    print("error occured: \(error)")
                }
                
            }
            task.resume()
            
        }
        
    }
    
    func getValue(key: String, dict: [AnyHashable: Any], month: String) -> [String]
    {
        return dict.filter { $0.value as? String == key }.flatMap
            {
                return "\(String(describing: $0.key))-\(month)"
        }
    }
    
    // MARK: - Dates convert
    func convertStringToDate(string: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let myDate = dateFormatter.date(from: string)!
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let somedateString = dateFormatter.string(from: myDate)
        
        return somedateString
    }

    
}

