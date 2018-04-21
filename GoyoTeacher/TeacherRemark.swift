//
//  TeacherRemark.swift
//  GoyoTeacher
//
//  Created by admin on 08/11/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import Alamofire
import TTGTagCollectionView

class TeacherRemark: UIViewController,TTGTextTagCollectionViewDelegate  {

    @IBOutlet var remarktextView: UITextView!
    @IBOutlet var tagCollectionView: TTGTextTagCollectionView!
    var studentListName = [String] ()
    var studentListId :NSMutableArray = []
    
    var studentid  = String()
    var savestudentid  = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*-------- Navigation --------*/
        self.navigationItem.title = "Teacher Remark"
        navigationBack()
        StudentList()
        self.automaticallyAdjustsScrollViewInsets = false
        tagCollectionView.delegate = self
        tagCollectionView.showsVerticalScrollIndicator = false
        style()
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
        }
    }
    func style ()
    {
        var config = TTGTextTagConfig()
        config = tagCollectionView.defaultConfig;
        config.tagTextFont = UIFont.boldSystemFont(ofSize: 20)
        config.tagTextColor = UIColor.white
        config.tagSelectedTextColor = UIColor.white
        config.tagBackgroundColor = UIColor(red: 0.10, green: 0.53, blue: 0.85, alpha: 1.0)
        config.tagSelectedBackgroundColor = UIColor(red: 0.21, green: 0.29, blue: 0.36, alpha: 1.0)
        config.tagExtraSpace = CGSize(width: 12, height: 12)
        config.tagCornerRadius = 8
        config.tagSelectedCornerRadius = 4
        config.tagBorderWidth = 0
        config.tagBorderColor = UIColor.white
        config.tagSelectedBorderColor = UIColor.white
        config.tagShadowColor = UIColor.black
        config.tagShadowOffset = CGSize(width: 0, height: 1)
        config.tagShadowOpacity = 0.3
        config.tagShadowRadius = 2
        tagCollectionView.horizontalSpacing = 8
        tagCollectionView.verticalSpacing = 8
        
        tagCollectionView.reload()
        
    }
    //MARK:- Tag DataSource
    func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTapTag tagText: String!, at index: UInt, selected: Bool) {

        let select = studentListId[Int(index)]
        
        let str = String(format: "%@", select as! CVarArg)
        savestudentid.append(str)
        print(savestudentid)
        
    }
    @IBAction func saveRemark(_ sender: Any) {
        if (remarktextView.text?.isEmpty)! {
            showAlert(self, message: "Please Write remark", title: "")
            
        }
        else{
            saveTeacherRemark()
        }

    }
    //MARK:- Web services
    func StudentList()
    {
        /*--------- Internet ----------- */
        if ConnectionCheck.isConnectedToNetwork() {

            showProgressLoader(_view: self)
            //        self.fetchingView.isHidden = false

            var param = [String: String] ()
            param["flag"] = "studentddl"
            param["enttid"] = UserDefaults.standard.string(forKey: "EnttID")!
            param["classid"] = SchoolDetailsVariable.classID

            Alamofire.request(Constants.getStudentList, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in

                switch(response.result) {
                case .success(_):

                    let jsonDict = response.result.value as! NSDictionary
                    print(jsonDict)
                    self.hideProgress()
                    if jsonDict["status"] as! Int == 200
                    {

                        if let Streams = jsonDict["data"] as! [AnyObject]?
                        {
                            for Stream in Streams {
                                let student = Stream["studname"] as! String
                                self.studentListName.append(student)

                                let studentid = Stream["studid"] as! String
                                self.studentListId.add(studentid)

                            }
                        }
                        self.tagCollectionView.addTags(self.studentListName)
                    }
                    break

                case .failure(let error):
                    print("Request failed with error: \(error)")
                    self.showAlert(self, message: "The Request Timed Out", title: "")
                    break

                }
            }
        }
        else{
            showAlert(self, message: "Make sure your device is connected to the internet.", title: "No Internet Connection")
        }
    }
    
    func saveTeacherRemark()
    {
        if ConnectionCheck.isConnectedToNetwork() {

            let str = String(format: "{%@}",  self.savestudentid.joined(separator: ","))
            
            showProgressLoader(_view: self)
            var param = [String: String] ()
            param["trid"] = "0"
            param["tchrid"] = UserDefaults.standard.string(forKey: "EnttID")!
            param["enttid"] = UserDefaults.standard.string(forKey: "EnttID")!
            param["remark"] = remarktextView.text
            param["studid"] = str
            param["cuid"] = UserDefaults.standard.string(forKey: "UCODE")!
            param["classid"] = SchoolDetailsVariable.classID


            Alamofire.request(Constants.saveTeacherRemark, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in

                switch(response.result) {
                case .success(_):

                    let jsonDict = response.result.value as! NSDictionary
                    print(jsonDict)
                    self.hideProgress()
                    if jsonDict["status"] as! Int == 200
                    {
                        let alertController = UIAlertController(title: "Teacher Remark", message: "Saved Successfully", preferredStyle:UIAlertControllerStyle.alert)

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

        else{
            showAlert(self, message: "Make sure your device is connected to the internet.", title: "No Internet Connection")
        }

    }
}
