//
//  ContentDetails.swift
//  GoyoParent
//
//  Created by admin on 13/12/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import Alamofire
import PDFKit
class ContentDetails: UIViewController,UITableViewDelegate, UITableViewDataSource,ContentDetailsCellDelegate {
    var contentDetail = [contentDetailModal]()
    @IBOutlet var contentDetailtable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Navigation
        self.navigationItem.title = "Content Details"
        navigationBack()
        // Internet
        if ConnectionCheck.isConnectedToNetwork() {
            ContentDetailAPI()
        }
        else{
            showAlert(self, message: "Make sure your device is connected to the internet.", title: "No Internet Connection")
            contentDetailtable.isHidden = true
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
    func backButton() {
        //do stuff here
        _ = navigationController?.popViewController(animated: true)
    }
    //MARK:-- Tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func  tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentDetail.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "contentDetail", for: indexPath) as! ContentDetailsCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none

        let contentDetail : contentDetailModal
        let row = indexPath.row
        contentDetail = self.contentDetail[row]
        cell.delegate = self
        cell.subjectName.text = contentDetail.subjectName
        cell.subjecTopic.text = contentDetail.subjectTopic
        cell.status.text = String("Status: \(contentDetail.status)")


        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    func ContentDetailsCellPdfAction(_sender:ContentDetailsCell) {

        let tappedIndexPath = contentDetailtable.indexPath(for:_sender)
        let contentDetail : contentDetailModal
        contentDetail = self.contentDetail[(tappedIndexPath?.row)!]
        SchoolDetailsVariable.pdfurl = String("http://school.goyo.in:8082/images/\(contentDetail.pdf)")

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let studentList = storyboard.instantiateViewController(withIdentifier: "PDFVC") as! PDFVC
        self.navigationController?.pushViewController(studentList, animated: true)
    }

    //MARK:-- Webservices
    func ContentDetailAPI(){
        showProgressLoader(_view: self)
        var param = [String: String] ()
        param["flag"] = "byteacher"
        param["enttid"] = UserDefaults.standard.string(forKey: "EnttID")!
        param["classid"] = SchoolDetailsVariable.classID
        param["subid"] = SchoolDetailsVariable.contentID

        Alamofire.request(Constants.getContent, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in

            switch(response.result) {
            case .success(_):

                let jsonDict = response.result.value as! NSDictionary
                print(jsonDict)
                self.hideProgress()
                if jsonDict["status"] as! Int == 200
                {
                    if let _Streams = jsonDict["data"] as! [NSDictionary]?
                    {
                        for  Stream in _Streams {
                            let ctitle = Stream["ctitle"] as! String
                            let topicname = Stream["topicname"] as! String
                            let status = Stream["status"] as! String
                            let uploadfile = Stream["uploadfile"] as! String

                            let rec = contentDetailModal(subjectName: ctitle, subjectTopic: topicname, status: status, pdf: uploadfile)

                            self.contentDetail.append(rec)
                        }
                    }
                    self.contentDetailtable.delegate = self
                    self.contentDetailtable.dataSource = self
                    self.contentDetailtable.reloadData()
                }
                break
            case .failure(let error):
                self.hideProgress()
                print("Request failed with error: \(error)")

                break
            }
        }
    }
}
