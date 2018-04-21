
//
//  ClassDetailsVC.swift
//  GoyoTeacher
//
//  Created by admin on 24/10/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class ClassDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var logoutButton: UIButton!
    @IBOutlet var blurView: UIView!
    
    @IBOutlet var logoutView: UIView!
    @IBOutlet var
    classTimeInOutView: UIView!
    
    let defaults = UserDefaults.standard

    @IBOutlet var timeSwitch: UISwitch!
    @IBOutlet var fetchingView: UIView!
    @IBOutlet var classTable: UITableView!
    var classArray: NSArray = []
    
    //CLLocation
    var locationManager: CLLocationManager!
    var latitude: Double!
    var longtitude:Double!
    var tripID = String()
    var tripStatus = Bool()
    
    var latitudeString = String()
    var longtitudeString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false

        classTable.delegate = self
        classTable.dataSource = self
        classTable.backgroundColor = UIColor.lightText

        
        //blur
        logoutView.isHidden = true
        blurView.isHidden = true
        
        let blurEffect = UIBlurEffect(style: .light)
        let sideEffectView = UIVisualEffectView(effect: blurEffect)
        sideEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        sideEffectView.frame = self.view.bounds
        blurView.addSubview(sideEffectView)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(TouchEvent))
        gesture.delegate = self
        blurView.addGestureRecognizer(gesture)
        
        //location
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        getCurrentLocation()
        teacherStatusAPI()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {

    }
    func TouchEvent() {
        //do stuff here
        blurView.isHidden = true
        logoutView.isHidden = true
    }

    //MARK: - LOcationManager
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last! 
        print("Current location: \(currentLocation)")
        latitude = currentLocation.coordinate.latitude
        longtitude = currentLocation.coordinate.longitude
        
        latitudeString = String(format: "%f", latitude)
        longtitudeString = String(format: "%f", longtitude)
        print(latitudeString)
        print(longtitudeString)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")

        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)

        
    }
    @IBAction func timeInOutSwitch(_ sender: UISwitch) {
        if timeSwitch.isOn == true
        {
            teacherTimeInAPI()
            ClassListAPI()
            classTimeInOutView.isHidden = true
            classTable.isHidden = false
            
        }
        else
        {
            locationManager.stopUpdatingLocation()
            teacherTimeOutAPI()
            classTimeInOutView.isHidden = false
            classTable.isHidden = true
        }
    }
    func getCurrentLocation()
    {
        let status  = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        if status == .denied || status == .restricted {
            let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)! as URL)

            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)

            return
        }
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            locationManager.requestWhenInUseAuthorization()
            
        }

    }
    //MARK:-  Tableview
    func  tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classArray.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassCell", for: indexPath) as! ClassTableListCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        cell.className.text = ((classArray[indexPath.row] ) as AnyObject).value(forKey: "classname") as? String
        
        let strngth =  ((classArray[indexPath.row] ) as AnyObject).value(forKey: "strength") as? NSNumber
        if strngth == nil
        {
            cell.clsstrength.text = "0"
        }
        else {
            let clsstrngth = String(format: "%@", strngth!)
            cell.clsstrength.text = clsstrngth
        }
        cell.schoolLogo.image = UIImage(named: "classImag")

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow //optional, to get from any UIButton for example
        
        SchoolDetailsVariable.classID =  (((classArray[(indexPath?.row)!] ) as AnyObject).value(forKey: "classid") as? String)!
        
        SchoolDetailsVariable.className =  (((classArray[(indexPath?.row)!] ) as AnyObject).value(forKey: "clstchrname") as? String)!

        let strngth =  ((classArray[(indexPath?.row)!] ) as AnyObject).value(forKey: "strength") as? NSNumber
        if strngth == 0
        {
showAlert(self, message: "There is no student in class", title: "Student")
        }
        else {
            let dashboard = storyboard?.instantiateViewController(withIdentifier: "DashBoardVC") as! DashBoardVC
            let navController = UINavigationController(rootViewController: dashboard)
            self.present(navController, animated:true, completion: nil)

        }
    }
    //MARK: UIBUtton Action
    @IBAction func logout(_ sender: UIButton) {
        logoutView.isHidden = false
        blurView.isHidden = false
        
        UIView.animate(withDuration: Double(0.5), animations: {
            self.view.layoutIfNeeded()
        })
    }
    @IBAction func TeacherTimeTable(_ sender: Any) {
        logoutView.isHidden = true
        blurView.isHidden = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let timetable  = storyboard.instantiateViewController(withIdentifier: "TeacherTimeTable") as! TeacherTimeTable
        let navController = UINavigationController(rootViewController: timetable)
        self.present(navController, animated:true, completion: nil)
    }
    @IBAction func aboutUsAction(_ sender: UIButton) {
        
        logoutView.isHidden = true
        blurView.isHidden = true
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let aboutus  = storyboard.instantiateViewController(withIdentifier: "AboutUs") as! AboutUs
        let navController = UINavigationController(rootViewController: aboutus)
        self.present(navController, animated:true, completion: nil)
    }
    @IBAction func userProfile(_ sender: UIButton) {
        logoutView.isHidden = true
        blurView.isHidden = true
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profile = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC
        let navController = UINavigationController(rootViewController: profile)
        self.present(navController, animated:true, completion: nil)
    }
    @IBAction func userlogout(_ sender: UIButton) {
        blurView.isHidden = true
        logoutView.isHidden = true
        LogoutalertView()
    }
    //MARK: -- AlertView
    func LogoutalertView()
    {
        let alertController = UIAlertController(title: "Warning", message: "Are you sure want Logout?", preferredStyle:UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        { action -> Void in
            
            if let bundle = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundle)
                
            }
            //Logout
            self.defaults.set(true, forKey: "Logout")
            self.defaults.set(false, forKey: "Home")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "StartVC")
            self.present(initialViewController, animated:true, completion: nil)
            
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alertController,animated: true, completion: nil)
    }

    //MARK:-  Webservices
    func ClassListAPI()
    {
        if ConnectionCheck.isConnectedToNetwork() {
            showProgressLoader(_view: self)
            var param = [String: String] ()
            param["flag"] = "teacher"
            param["uid"] = UserDefaults.standard.string(forKey: "UID")!
            param["enttid"] = UserDefaults.standard.string(forKey: "EnttID")!
            Alamofire.request(Constants.getclassDetails, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in

                switch(response.result) {
                case .success(_):

                    let jsonDict = response.result.value as! NSDictionary
                    print(jsonDict)
                    self.hideProgress()
                    if jsonDict["status"] as! Int == 200
                    {
                        self.classArray = jsonDict["data"] as! NSArray
                        self.classTable.reloadData()
                    }
                    break

                case .failure(let error):
                    print("Request failed with error: \(error)")
                    self.hideProgress()
                    self.showAlert(self, message: "The request timed out", title: "")
                    self.fetchingView.isHidden = false
                    self.classTable.isHidden = true
                    break

                }
            }
        }
        else{
            showAlert(self, message: "Make sure your device is connected to the internet.", title: "No Internet Connection")
        }
    }

    func teacherTimeInAPI()
    {
        if ConnectionCheck.isConnectedToNetwork() {
            showProgressLoader(_view: self)
            var param = [String: String] ()
            param["mode"] = "start"
            param["tripid"] = "0"
            param["emptype"] = "teacher"
            param["lat"] = latitudeString
            param["lon"] = longtitudeString
            param["empid"] = UserDefaults.standard.string(forKey: "UID")!
            param["enttid"] = UserDefaults.standard.string(forKey: "EnttID")!

            Alamofire.request(Constants.teacherTimeIn, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in

                switch(response.result) {
                case .success(_):

                    let jsonDict = response.result.value as! NSDictionary
                    print(jsonDict)
                    self.hideProgress()
                    if jsonDict["status"] as! Int == 401
                    {
                        self.showAlert(self, message: "Check your Location", title: "Location Disabled")
                    }
                    else{

                    }
                    if jsonDict["status"] as! Int == 200
                    {
                        let data = jsonDict["data"] as! [String:Any]

                        let tripNumber = data["tripid"] as! NSNumber

                        self.tripID = String(format: "%@", tripNumber)
                        let msgStatus = data["resmessage"] as! String
                        self.showToast(message: msgStatus)

                    }
                    break

                case .failure(let error):
                    print("Request failed with error: \(error)")
                    self.hideProgress()
                    self.showAlert(self, message: "The request timed out", title: "")
                    self.fetchingView.isHidden = false
                    self.classTable.isHidden = true
                    break

                }
            }
        }
        else{
            showAlert(self, message: "Make sure your device is connected to the internet.", title: "No Internet Connection")
        }
    }
    func teacherTimeOutAPI()
    {
        if ConnectionCheck.isConnectedToNetwork() {
            showProgressLoader(_view: self)
            var param = [String: String] ()
            param["mode"] = "stop"
            param["tripid"] = tripID
            param["emptype"] = "teacher"
            param["lat"] = latitudeString
            param["lon"] = longtitudeString
            param["empid"] = UserDefaults.standard.string(forKey: "UID")!
            param["enttid"] = UserDefaults.standard.string(forKey: "EnttID")!

            Alamofire.request(Constants.teacherTimeOut, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in

                switch(response.result) {
                case .success(_):

                    let jsonDict = response.result.value as! NSDictionary
                    print(jsonDict)
                    self.hideProgress()
                    if jsonDict["status"] as! Int == 200
                    {
                        let data = jsonDict["data"] as! [String:Any]

                        let msgStatus = data["resmessage"] as! String
                        self.showToast(message: msgStatus)
                    }
                    break
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    self.hideProgress()
                    self.showAlert(self, message: "The request timed out", title: "")
                    self.fetchingView.isHidden = false
                    self.classTable.isHidden = true
                    break
                }
            }
        }
        else{
            showAlert(self, message: "Make sure your device is connected to the internet.", title: "No Internet Connection")
        }
    }
    func teacherStatusAPI()
    {
        if ConnectionCheck.isConnectedToNetwork() {
            showProgressLoader(_view: self)
            var param = [String: Any] ()
            param["flag"] = "getchkinout" as AnyObject
            param["emptype"] = "teacher" as AnyObject
            param["empid"] = UserDefaults.standard.string(forKey: "UID")! as AnyObject
            Alamofire.request(Constants.getEmpStatus, method: .get, parameters: param).responseJSON { (response:DataResponse<Any>) in
                
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
                            
                            if let status = data[0]["funget_empstatus"] as? [String:Any] {
                                print(status)
                                let trip  = status["tripid"]  as! NSNumber
                                self.tripID = String(format: "%@", trip)
                                self.tripStatus = status["state"] as! Bool
                                print(self.tripStatus)
                                self.tripState()
                            }
                            else{
                                
                            }
                        }
                    }
                    break
                    
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    self.hideProgress()
                    self.showAlert(self, message: "The request timed out", title: "")
                    self.fetchingView.isHidden = false
                    self.classTable.isHidden = true
                    break
                    
                }
            }
        }
        else{
            showAlert(self, message: "Make sure your device is connected to the internet.", title: "No Internet Connection")
        }
    }
    func tripState ()
    {
        if tripStatus == true
        {
            timeSwitch.isOn = true
            classTable.isHidden = false
            classTimeInOutView.isHidden = true
            ClassListAPI()
        }
        else
        {
            timeSwitch.isOn = false
            classTable.isHidden = true
            classTimeInOutView.isHidden = false
        }
    }
}
