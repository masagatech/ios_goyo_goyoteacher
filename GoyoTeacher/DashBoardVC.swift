//
//  DashBoardVC.swift
//  GoyoTeacher
//
//  Created by admin on 25/10/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit

class DashBoardVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightText
        self.navigationItem.title = SchoolDetailsVariable.className
        navigationBack()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func navigationBack(){
        // create the button
        let button = UIButton.init(type: .custom)
        let suggestImage  = UIImage(named: "back")!.withRenderingMode(.alwaysOriginal)
        button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        button.setImage(suggestImage, for: UIControlState.normal)
        button.addTarget(self, action:#selector(backButton), for: UIControlEvents.touchUpInside)
        // here where the magic happens, you can shift it where you like
        button.transform = CGAffineTransform(translationX: 10, y: 0)
        // add the button to a container, otherwise the transform will be ignored
        let suggestButtonContainer = UIView(frame: button.frame)
        suggestButtonContainer.addSubview(button)
        let suggestButtonItem = UIBarButtonItem(customView: suggestButtonContainer)
        // add button shift to the side
        navigationItem.leftBarButtonItem = suggestButtonItem
    }
    func backButton()
    {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func contentAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let childreenView = storyboard.instantiateViewController(withIdentifier: "ContentList") as! ContentList
        self.navigationController?.pushViewController(childreenView, animated: true)
    }
    @IBAction func Notification(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let childreenView = storyboard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        self.navigationController?.pushViewController(childreenView, animated: true)
    }
    
    @IBAction func Attendance(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let childreenView = storyboard.instantiateViewController(withIdentifier: "AttendanceSection") as! AttendanceSection
        self.navigationController?.pushViewController(childreenView, animated: true)
    }
    @IBAction func exam(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let examView = storyboard.instantiateViewController(withIdentifier: "ExamVC") as! ExamVC
        self.navigationController?.pushViewController(examView, animated: true)
    }
    
    @IBAction func result(_ sender: Any) {
    }
    
    @IBAction func progressCard(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let progressView = storyboard.instantiateViewController(withIdentifier: "ProgressCardVC") as! ProgressCardVC
        self.navigationController?.pushViewController(progressView, animated: true)
    }
    @IBAction func holiday(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let holidayView = storyboard.instantiateViewController(withIdentifier: "HolidayViewController") as! HolidayViewController
        self.navigationController?.pushViewController(holidayView, animated: true)
    }
    @IBAction func assignment(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let assignment  = storyboard.instantiateViewController(withIdentifier: "AssignmentVC") as! AssignmentVC
        self.navigationController?.pushViewController(assignment, animated: true)

    }
    @IBAction func leave(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let leaveView  = storyboard.instantiateViewController(withIdentifier: "TeacherLeave") as! TeacherLeave
        self.navigationController?.pushViewController(leaveView, animated: true)
    }
    @IBAction func timeTable(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let timetable  = storyboard.instantiateViewController(withIdentifier: "TeacherTimeTable") as! TeacherTimeTable
        self.navigationController?.pushViewController(timetable, animated: true)
    }
    @IBAction func teacherRemark(_ sender: Any) {
        //TeacherRemark
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let remark  = storyboard.instantiateViewController(withIdentifier: "TeacherRemark") as! TeacherRemark
        self.navigationController?.pushViewController(remark, animated: true)
    }
    
}
