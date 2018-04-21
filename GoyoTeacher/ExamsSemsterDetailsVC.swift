//
//  ExamsSemsterDetailsVC.swift
//  GoyoParent
//
//  Created by admin on 12/10/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import Alamofire


class ExamsSemsterDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let userDefult = UserDefaults.standard

    let kCloseCellHeight: CGFloat = 110 //foreground
    let kOpenCellHeight: CGFloat = 300 //container
    let kRowsCount = 100
    var cellHeights: [CGFloat] = []
    
    @IBOutlet var fetchingView: UIView!
    @IBOutlet var tableView: UITableView!
    
    var semsterArray : NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Navigation
        self.navigationItem.title = SchoolDetailsVariable.semsterName
        navigationBack()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 1.0)
        // Internet
        if ConnectionCheck.isConnectedToNetwork() {
            ExamsDetailsAPI()
        }
        else{
            showAlert(self, message: "Make sure your device is connected to the internet.", title: "No Internet Connection")
        }
        setup()
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
        }    }
    
    // MARK: -- Tableview

    private func setup() {
        cellHeights = Array(repeating: kCloseCellHeight, count: kRowsCount)
        tableView.estimatedRowHeight = kCloseCellHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1.0)
    }

    func  tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if semsterArray.count == 0
        {
            tableView.isHidden = true
            fetchingView.isHidden = false
            return semsterArray.count
        }
        else
        {
            tableView.isHidden = false
            fetchingView.isHidden = true
            return semsterArray.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExamSemsterCell", for: indexPath) as! FoldingCell
        
        let durations: [TimeInterval] = [0.26, 0.2, 0.2]
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations

        cell.semsterDate.text = ((semsterArray[indexPath.row]) as AnyObject).value(forKey: "examdate") as? String
        
        cell.chpater.text = ((semsterArray[indexPath.row]) as AnyObject).value(forKey: "chptrname") as? String
        
        let subject = ((semsterArray[indexPath.row]) as AnyObject).value(forKey: "subname") as? String
        
        let fromTime = ((semsterArray[indexPath.row]) as AnyObject).value(forKey: "frmtm") as? String
        
        let toTime = ((semsterArray[indexPath.row]) as AnyObject).value(forKey: "totm") as? String
        
        let pasmarks = ((semsterArray[indexPath.row]) as AnyObject).value(forKey: "passmarks") as? NSNumber
        
        let outofmarks = ((semsterArray[indexPath.row]) as AnyObject).value(forKey: "outofmarks") as? NSNumber
        
        cell.subjectName.text = String(format: "Subject: %@", subject!)
        cell.examsFromTime.text = String(format: "From: %@", fromTime!)
        cell.toTime.text = String(format: "To: %@", toTime!)
        cell.passmarks.text = String(format: "%@", pasmarks!)
        cell.totalMarks.text = String(format: "%@", outofmarks!)

        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
        let  heightOfRow = self.calculateHeight(inString: (((semsterArray[indexPath.row]) as AnyObject).value(forKey: "chptrname") as? String)!)
        //   tableView.calculateHeight(inString: (((semsterArray[indexPath.row]) as AnyObject).value(forKey: "chptrname") as? String)!)
        return (heightOfRow + 130.0)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as ExamSemsterCell = cell else {
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
            cell.containerHeightConstant.constant = 300
            cell.containerViewTop.constant = 110
            
            duration = 0.5
        } else {
            cellHeights[indexPath.row] = kCloseCellHeight
            duration = 0.8
            cell.containerViewTop.constant = 110
        }
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
    }
    // MARK: -  WebServices studid
    func ExamsDetailsAPI()
    {
        showProgressLoader(_view: self)
        var param = [String: String] ()
        param["flag"] = "byteacher"
        param["enttid"] = UserDefaults.standard.string(forKey: "EnttID")!
        param["classid"] = SchoolDetailsVariable.classID
        param["smstrid"] = SchoolDetailsVariable.semsterID
        Alamofire.request(Constants.getExam, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                
                let jsonDict = response.result.value as! NSDictionary
                print(jsonDict)
                self.hideProgress()
                if jsonDict["status"] as! Int == 200
                {
                    self.semsterArray = jsonDict["data"] as! NSArray
                    self.tableView.reloadData()
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


