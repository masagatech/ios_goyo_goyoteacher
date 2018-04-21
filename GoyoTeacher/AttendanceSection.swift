//
//  AttendanceSection.swift
//  GoyoTeacher
//
//  Created by admin on 03/11/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit

class AttendanceSection: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var attendanceTable: UITableView!
    
    var attendanceSectionArray = ["My Attendance", "Student Attendance"]
   
    var imageArray: [UIImage] = [
        UIImage(named: "attendance-1.png")!,
        UIImage(named: "attendance-1.png")!
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Navigation
        self.navigationItem.title = "Class Attendance"
        navigationBack()

        attendanceTable.delegate = self
        attendanceTable.dataSource = self
        attendanceTable.backgroundColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1.0)
      
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

    // MARK: - tableview
    func  tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attendanceSectionArray.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "attendanceCell", for: indexPath) as! AttendanceCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        cell.attendanceName.text = attendanceSectionArray[indexPath.row]
        cell.sectionImage.image = imageArray[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if indexPath.row == 0 {
         
            SchoolDetailsVariable.navigationTitle = attendanceSectionArray[indexPath.row]
              let teacherattendance = storyboard.instantiateViewController(withIdentifier: "AttendanceVC") as! AttendanceVC
             navigationController?.pushViewController(teacherattendance, animated: true)
        }
        else {
        SchoolDetailsVariable.navigationTitle = attendanceSectionArray[indexPath.row]
      let studentattendance = storyboard.instantiateViewController(withIdentifier: "ClassAtendance") as! ClassAtendance
             navigationController?.pushViewController(studentattendance, animated: true)
    }
        
    }

}
