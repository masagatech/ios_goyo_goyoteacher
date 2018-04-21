//
//  HolidayCalendarVC.swift
//  GoyoParent
//
//  Created by admin on 22/09/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import FSCalendar
import Alamofire


class HolidayCalendarVC: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
  
@IBOutlet var calendar: FSCalendar!
    var somedateFromString = String()
    var somedateEndString = String()
    var presentdays = [String]()
    var totalHolidays = [String]()
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.delegate = self
        calendar.dataSource = self
//        calendar.appearance.todayColor = .red
        calendar.appearance.titleFont = UIFont(name: "Avenir-Book", size: 16)
        calendar.allowsSelection = false
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
         holidayAPI()
}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - FSCalendar
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        
        let datestring2 : String = dateFormatter1.string(from:date)
        
        if totalHolidays.contains(datestring2)
        {
            return UIColor(red: 31/255.0, green: 119/255.0, blue: 219/255.0, alpha: 1.0)
        }
        return nil
        
    }
    // MARK: - Web Services

    func holidayAPI()  {
  
        var param = [String: String] ()
        param["flag"] = "byentt"
        param["hldfor"] = "teacher"
        param["enttid"] = UserDefaults.standard.string(forKey: "EnttID")!
        
        Alamofire.request(Constants.getHoliday, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                
                let jsonDict = response.result.value as! NSDictionary
                print(jsonDict)
                if jsonDict["status"] as! Int == 200
                {
                    if let Streams = jsonDict["data"] as! [AnyObject]? {
                        
                        for arrayElement in Streams
                        {
                            
                if let startDateString = arrayElement["frmdt"]
                {
                      self.somedateFromString = self.convertStringToDate(string: startDateString as! String)
                    
                    if  let endDateString = arrayElement["todt"]
                    {
                        self.somedateEndString = self.convertStringToDate(string: endDateString as! String)
                    }
                    
           self.presentdays = Dates.printDatesBetweenInterval(Dates.dateFromString(self.somedateFromString), Dates.dateFromString(self.somedateEndString))
               self.totalHolidays.append(contentsOf: self.presentdays)
                }
            }
                        print(self.presentdays)
                          print(self.totalHolidays)
                        
                        self.calendar.reloadData()
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
    
    func getDateAsStringInUTC(date: NSDate) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let UTCTimeAsString = dateFormatter.string(from: date as Date)
        
        return UTCTimeAsString
    }
    // MARK: - Dates convert
    func convertStringToDate(string: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        let myDate = dateFormatter.date(from: string)!
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let somedateString = dateFormatter.string(from: myDate)
        return somedateString
    }
}
// MARK: - Dates Class

class Dates {
  static func printDatesBetweenInterval(_ startDate: Date, _ endDate: Date) -> [String] {
        var startDate = startDate
        let calendar = Calendar.current
        
        let fmt = DateFormatter()
        fmt.dateFormat = "dd-MM-yyyy"
        var arrayDateString = [String]()
        while startDate <= endDate {
            let stringDate = fmt.string(from: startDate)
            print("stringDate - \(stringDate)")
            arrayDateString.append(stringDate)
            startDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        }
        return arrayDateString
    }

    static func dateFromString(_ dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.date(from: dateString)!
    }
}
extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}
