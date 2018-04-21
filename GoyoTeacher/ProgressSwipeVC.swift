//
//  ProgressSwipeVC.swift
//  GoyoTeacher
//
//  Created by admin on 02/11/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import Alamofire
class ProgressSwipeVC: UIViewController ,CarbonTabSwipeNavigationDelegate  {
    let  defaults  = UserDefaults.standard
    var names  = NSArray()
    var carbonTabSwipeNavigation: CarbonTabSwipeNavigation = CarbonTabSwipeNavigation()
    var subjectName  = [String]()
    var subjectid  = String()
    var subjectArray =  NSArray()
    var subjectNameid  = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Navigation
        self.navigationItem.title = "Exam"
        navigationBack()
        subjectAPI()
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
    // MARK: - CarbonSwipe
    func style() {
        
        let color: UIColor = UIColor(red: 24.0 / 255, green: 75.0 / 255, blue: 152.0 / 255, alpha: 1)
        carbonTabSwipeNavigation.toolbar.isTranslucent = false
        carbonTabSwipeNavigation.setIndicatorColor(color)
        carbonTabSwipeNavigation.setTabExtraWidth(30)
        let  bounds = UIScreen.main.bounds
        let width = bounds.size.width
        if names.count == 1
        {
            if carbonTabSwipeNavigation.carbonSegmentedControl?.tag == 0
            {
                carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(width, forSegmentAt: 0)
            }
        }
        else
        {
            if carbonTabSwipeNavigation.carbonSegmentedControl?.tag == 0
            {
                carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(160, forSegmentAt: 0)
            }
            else if carbonTabSwipeNavigation.carbonSegmentedControl?.tag == 1
            {
                carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(160, forSegmentAt: 2)
            }
        }
        carbonTabSwipeNavigation.setNormalColor(UIColor.black.withAlphaComponent(0.6))
        carbonTabSwipeNavigation.setSelectedColor(color, font: UIFont.boldSystemFont(ofSize: 14))
    }
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        let nextVC = self.storyboard!.instantiateViewController(withIdentifier: "ResultExamDetailsVC") as! ResultExamDetailsVC
        SchoolDetailsVariable.subjectID = subjectArray.object(at: Int(index)) as! String
        return nextVC
    }
    // MARK: - WebServices
    func subjectAPI()
    {
        var param = [String: String] ()
        param["flag"] = "examsubject"
        param["classid"] = SchoolDetailsVariable.classID
        param["enttid"] = UserDefaults.standard.string(forKey: "EnttID")!
        param["smstrid"] = SchoolDetailsVariable.semsterID
        
        Alamofire.request(Constants.getProgressCard, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                
                let jsonDict = response.result.value as! NSDictionary
                print(jsonDict)
                if jsonDict["status"] as! Int == 200
                {
                    if let Streams = jsonDict["data"] as! [AnyObject]?
                    {
                        for Stream in Streams {

                            let post = Stream["subname"] as? String
                            self.subjectName.append(post!)
                            let subid = Stream["subid"] as! NSNumber
                            let subID = String(format: "%@", subid)
                            self.subjectNameid.append(subID)
                        }
                        if self.subjectNameid.count == 0 {
                            self.showAlert(self, message: "There Is Subject", title: "Subject!")
                            
                        }else {
                            self.names = self.subjectName as NSArray
                            self.subjectArray = self.subjectNameid as NSArray
                            print(self.subjectArray)
                            self.subjectid = self.subjectArray.object(at: 0) as! String

                            print(self.names)
                            self.carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: self.names as [AnyObject], delegate: self)
                            self.carbonTabSwipeNavigation.insert(intoRootViewController: self)
                            self.style()
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
}
