//
//  HolidayViewController.swift
//  GoyoParent
//
//  Created by admin on 21/09/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit

class HolidayViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableview: UITableView!

    var holidayListArray: NSArray = []
    var rightbutton = UIButton()
    
    
    @IBOutlet var fetchingview: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*-------- Navigation --------*/
        self.navigationItem.title = "Holiday"
        navigationBack()
        
        //        let button = UIButton.init(type: .custom)
        //        button.setImage(UIImage.init(named: "back.png"), for: UIControlState.normal)
        //        button.addTarget(self, action:#selector(callMethod), for: UIControlEvents.touchUpInside)
        //        button.frame = CGRect.init(x: 0, y: 0, width: 20, height: 20) //CGRectMake(0, 0, 30, 30)
        //        let barButton = UIBarButtonItem.init(customView: button)


        
        //        self.navigationItem.leftBarButtonItem = barButton
        //        navigationItem.rightBarButtonItem = rightbarButton

        
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.tableview.backgroundColor = UIColor(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 1.0)

        /*--------- Internet ----------- */
        if ConnectionCheck.isConnectedToNetwork() {
            holidayAPI()
            rightbutton.isEnabled = true
        }
        else{
            showAlert(self, message: "Make sure your device is connected to the internet.", title: "No Internet Connection")
            rightbutton.isEnabled = false
        }
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
        //right
        rightbutton = UIButton.init(type: .custom)
        let calendarImg  = UIImage(named: "calender")!.withRenderingMode(.alwaysOriginal)
        rightbutton.setImage(calendarImg, for: UIControlState.normal)
        rightbutton.addTarget(self, action:#selector(rightCallMethod), for: UIControlEvents.touchUpInside)
        rightbutton.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
        rightbutton.transform = CGAffineTransform(translationX: 10, y: 0)
        let rightbarButton = UIBarButtonItem.init(customView: rightbutton)
        navigationItem.rightBarButtonItem = rightbarButton

    }
    func backButton() {
        //do stuff here
        _ = self.navigationController?.popViewController(animated: true)
    }
    //HolidayCalendarVC
    func rightCallMethod() {
        //do stuff here
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let holidayCalendar = storyboard.instantiateViewController(withIdentifier: "HolidayCalendarVC") as! HolidayCalendarVC

        navigationController?.pushViewController(holidayCalendar, animated:true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- Tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func  tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if holidayListArray.count == 0
        {
            tableview.isHidden = true
            fetchingview.isHidden = false
            return holidayListArray.count
        }
        else
        {
            tableview.isHidden = false
            fetchingview.isHidden = true
            return holidayListArray.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HolidayTableViewCell
        cell.holidayName.text = ((holidayListArray[indexPath.row]) as AnyObject).value(forKey: "hldnm") as? String
        cell.holidayDesc.text = ((holidayListArray[indexPath.row]) as AnyObject).value(forKey: "hlddesc") as? String
        //Date
        let fromdate = ((holidayListArray[indexPath.row]) as AnyObject).value(forKey: "frmdt") as? String
        let todate = ((holidayListArray[indexPath.row]) as AnyObject).value(forKey: "todt") as? String
        cell.date.text = fromdate!+" to "+todate!
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let  heightOfRow = self.calculateHeight(inString: (((holidayListArray[indexPath.row]) as AnyObject).value(forKey: "hlddesc") as? String)!)
        
        return (heightOfRow + 90.0)
    }
    //MARK:- webservices
    func holidayAPI()  {
        
        DispatchQueue.main.async {
            self.showProgressLoader(_view: self)
            let url = URL(string: Constants.getHoliday)!
            let session = URLSession.shared
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
            let flag = "flag=" + "byentt"
            let holidayfor = "&hldfor=" + "teacher"
            let enttilid = "&enttid=" + UserDefaults.standard.string(forKey: "EnttID")!
            let paramString = flag+enttilid+holidayfor
            request.httpBody = paramString.data(using: String.Encoding.utf8)
            let task = session.dataTask(with: request as URLRequest)
            {
                data,response,error in
                if error != nil {
                    print(error!.localizedDescription)
                }
                else
                {
                    do {
                        let parsedData = try JSONSerialization.jsonObject(with: data!, options:[]) as! [String:Any]
                        print(parsedData)
                        self.hideProgress()
                        if parsedData["status"] as! Int == 200
                        {
                            if (parsedData["data"] as! [AnyObject]?) != nil
                            {

                                self.holidayListArray = parsedData["data"] as! NSArray

                            }
                            DispatchQueue.main.async {
                                self.tableview.reloadData()
                            }
                        }
                        else
                        {
                        }
                    }
                    catch {

                        print("error occured: \(error)")
                    }
                }
            }
            task.resume()
        }
    }
    // MARK: - Dates convert
    func convertStringToDate(string: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let myDate = dateFormatter.date(from: string)!
        dateFormatter.dateFormat = "dd-MM"
        let somedateString = dateFormatter.string(from: myDate)
        return somedateString
    }
}
