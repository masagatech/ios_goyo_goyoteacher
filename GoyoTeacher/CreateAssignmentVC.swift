//
//  CreateAssignmentVC.swift
//  GoyoTeacher
//
//  Created by admin on 03/11/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit
import Alamofire
import MobileCoreServices
import Foundation


class CreateAssignmentVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate, UIDocumentPickerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    @IBOutlet weak var emailCheck: UIButton!
    @IBOutlet var mainView: UIView!
    @IBOutlet var blurView: UIView!
    @IBOutlet var upload: UIButton!
    @IBOutlet var submit: UIButton!
    @IBOutlet var assignDescription: UITextView!
    @IBOutlet var assignmentTitle: UITextField!
    @IBOutlet var assignFromdate: UITextField!
    @IBOutlet var assignTodate: UITextField!
    @IBOutlet var subjectName: UIButton!
    @IBOutlet var subjectable: UITableView!
    
    var subjectArray: NSArray = []
    var datePicker : UIDatePicker!
    var isStartDate = Bool()
    var isEndDate = Bool()
    //document
    var docController:UIDocumentInteractionController!
    let UTIs:[String] = ["public.data"]

    var imagePicker = UIImagePickerController()
    var pickedImagePath = String()
    var pickedImageData: Data?
    var pickedImageString:String?
    var pickedImage:String?
    var usePhoto = UIImage()
    var filename: String!
    var toParentEmail:String!
    var isParentEmail:Bool!


    //MARK:- Viewforlifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Navigation 
        self.navigationItem.title = "Create Assignment"
        navigationBack()
        // Do any additional setup after loading the view.
        self.isParentEmail = true
        subjectable.delegate = self
        subjectable.dataSource = self
        subjectable.isHidden = true
        
        assignFromdate.delegate = self
        assignTodate.delegate = self
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy"
        let result = formatter.string(from: date)
        assignFromdate.text = result
        assignTodate.text = result

        assignDescription.backgroundColor = .clear
        assignDescription.layer.borderWidth = 1
        assignDescription.layer.cornerRadius = 4
        assignDescription.layer.borderColor = UIColor.black.cgColor
        
        submit.layer.cornerRadius = 10
        submit.clipsToBounds = true
        
        //blurView
        blurView.isHidden = true
        let blurEffect = UIBlurEffect(style: .light)
        let sideEffectView = UIVisualEffectView(effect: blurEffect)
        sideEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        sideEffectView.frame = self.view.bounds
        blurView.addSubview(sideEffectView)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(TouchEvent))
        gesture.delegate = self
        blurView.addGestureRecognizer(gesture)
        self.imagePicker.delegate = self
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:-- UIButton
    func TouchEvent() {
        //do stuff here
        blurView.isHidden = true
        subjectable.isHidden = true
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
    
    @IBAction func sendEmailAction(_ sender: UIButton) {
        if isParentEmail == true {
self.emailCheck.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
            self.toParentEmail = "1"
        }
        else {
            self.emailCheck.setImage(#imageLiteral(resourceName: "uncheckbox"), for: .normal)
            self.toParentEmail = "0"
        }
    }
    func backButton() {
        //do stuff here
        if let navigation = self.navigationController {
            navigation.popViewController(animated: true)
        }
    }
    @IBAction func subjectAction(_ sender: Any) {
        subjectable.isHidden = false
        blurView.isHidden = false
        subjectDropDownAPI()
    }
    @IBAction func submitAction(_ sender: Any) {
        if assignDescription.text.isEmpty {
            showToast(message: "Write something about your Assignment")
        }
        else if (subjectName.titleLabel?.text?.isEmpty)!
        {
            showToast(message: "Please select your subject name")
        }
        else if (assignmentTitle.text?.isEmpty)!
        {
            showToast(message: "Assignment Title is empty")
        }
        else if (self.upload.titleLabel?.text == "Upload documents") {
                  showToast(message: "upload file empty")
        }
        else
        {
            /*--------- Internet ----------- */
            if ConnectionCheck.isConnectedToNetwork() {
                UploadAssignmentAPI()
            }
            else{
                showAlert(self, message: "Make sure your device is connected to the internet.", title: "No Internet Connection")
            }
        }
    }
    @IBAction func uploadAssignment(_ sender: AnyObject) {
        let actionsheet = UIAlertController(title: "Choose Option", message: "Option to select upload", preferredStyle: .actionSheet)

        let cancelBtn = UIAlertAction(title: "cancel", style: .cancel) {action -> Void in
            print("Cancel")
        }
        /*
        let cameraBtn = UIAlertAction(title: "Camera", style: .destructive) { action -> Void in
            print("camerabtn")
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                self.imagePicker.sourceType = .camera
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
 */
        let galleryBtn = UIAlertAction(title: "Gallery", style: .destructive) { action -> Void in
            print("gallery")
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                self.imagePicker.allowsEditing = false
                self.imagePicker.sourceType = .savedPhotosAlbum
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        let fileBtn = UIAlertAction(title: "Choose file from iCloud", style: .destructive) { action -> Void in
            print("icloud")
            //[String(kUTTypePDF)]
            let importMenu = UIDocumentPickerViewController(documentTypes:self.UTIs , in: .import)
            importMenu.delegate = self
            importMenu.modalPresentationStyle = .formSheet
            self.present(importMenu, animated: true, completion: nil)
        }
        actionsheet.addAction(cancelBtn)
//        actionsheet.addAction(cameraBtn)
        actionsheet.addAction(galleryBtn)
        actionsheet.addAction(fileBtn)
        self.present(actionsheet, animated: true, completion: nil)
    }
    //MARK:- UIDocumentDelegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print("path name : \(url.lastPathComponent)")
        let filePath = url.lastPathComponent
        filename = "\(filePath)"
        pickedImage = "\(url)"
        downloadFile(url: filePath)
        if controller.documentPickerMode == .import {
            let alert:UIAlertController = UIAlertController(title: "Successfully imported \(url.lastPathComponent)", message: nil, preferredStyle: .alert)
            self.upload.setTitle("Successfully Upload", for: .normal)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    //MARK:- UIImagePicker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if picker.sourceType == .savedPhotosAlbum {
            let image_data = info[UIImagePickerControllerOriginalImage] as? UIImage
            let imageURL = info[UIImagePickerControllerImageURL] as! URL
            pickedImage = "\(imageURL.absoluteURL)"
            filename = "\(imageURL.absoluteURL.lastPathComponent)"
            pickedImageData = UIImagePNGRepresentation(image_data!)!
            pickedImageString = pickedImageData?.base64EncodedString()
            uploadAssignmentTask(pickImage:image_data!)
        }else {
//            usePhoto = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
//            saveImage(image: usePhoto, completion: {_ in print("Image saved completed") })

        }
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true)
        {
            self.showAlert(self, message: "You cancelled photo selection.", title: "Cancelled Action")
        }
    }
    func saveImage(image: UIImage, completion: @escaping (Error?) -> ()) {

        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(path:didFinishSavingWithError:contextInfo:)), nil)
    }
    @objc func image(path: String, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
        debugPrint(path) // That's the path you want
        let imageURL = path
        print(imageURL)
        uploadAssignmentTask(pickImage:usePhoto)
//        pickedImage = "\(imageURL.)"
    }
    //MARK:-- Tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func  tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjectArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AssignmentSubjectCell

        cell.subjectname.text = ((subjectArray[indexPath.row]) as AnyObject).value(forKey: "subname") as? String

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow //optional, to get from any UIButton for example
        
        let currentCell = tableView.cellForRow(at: indexPath!) as! AssignmentSubjectCell
        subjectName.setTitle(currentCell.subjectname.text, for:.normal)
        subjectName.setTitleColor(UIColor.black, for: .normal)
        tableView.isHidden = true

        let subjectid = ((subjectArray[(indexPath?.row)!]) as AnyObject).value(forKey: "subid") as? NSNumber
        SchoolDetailsVariable.subjectID = String(format: "%@", subjectid!)
        subjectable.isHidden = true
        blurView.isHidden = true
        //        subjectTableHeight.constant = 0
    }
    ///MARK:-- Textfield
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            isStartDate = false
            isEndDate = true
            self.pickUpDate(assignFromdate)
        }
        else if textField.tag == 2
        {
            isEndDate = false
            isStartDate = true
            self.pickUpDate(assignTodate)
        }
    }

    //MARK:- Function of datePicker
    func pickUpDate(_ sender : UITextField){
        
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datePicker.backgroundColor = UIColor.white
        self.datePicker.datePickerMode = UIDatePickerMode.date
        sender.inputView = self.datePicker
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(CreateAssignmentVC.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(CreateAssignmentVC.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        sender.inputAccessoryView = toolBar
        
    }
    // MARK:- Button Done and Cancel
    func doneClick() {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .medium
        dateFormatter1.timeStyle = .none
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        if  isStartDate == false {
            assignFromdate.text = dateFormatter.string(from: datePicker.date)
            assignFromdate.resignFirstResponder()
        }
        else
        {
            assignTodate.text = dateFormatter.string(from: datePicker.date)
            assignTodate.resignFirstResponder()
        }
    }
    func cancelClick() {
        if  isStartDate == false {
            assignFromdate.resignFirstResponder()
        }
        else
        {
            assignTodate.resignFirstResponder()
        }
    }

    //MARK:- Web services
    func subjectDropDownAPI()
    {
        showProgressLoader(_view: self)
        var param = [String: String] ()
        param["flag"] = "subjectddl"
        param["enttid"] = UserDefaults.standard.string(forKey: "EnttID")!
        param["classid"] = SchoolDetailsVariable.classID
        Alamofire.request(Constants.getAssignment, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                
                let jsonDict = response.result.value as! NSDictionary
                print(jsonDict)
                self.hideProgress()
                if jsonDict["status"] as! Int == 200
                {
                    self.subjectArray = jsonDict["data"] as! NSArray 
                    self.subjectable.reloadData()
                    //                     self.subjectTableHeight.constant = 100
                }
                break
                
            case .failure(let error):
                print("Request failed with error: \(error)")
                self.showAlert(self, message: "The Request Timed Out", title: "")
                self.hideProgress()
                break
                
            }
        }
    }
    func UploadAssignmentAPI()
    {
        showProgressLoader(_view: self)
        var param = [String: String] ()
        param["title"] = assignmentTitle.text
        param["uploadassnm"] = self.pickedImagePath
        param["subid"] = SchoolDetailsVariable.subjectID
        param["clsid"] = SchoolDetailsVariable.classID
        param["msg"] = assignDescription.text
        param["frmdt"] = assignFromdate.text
        param["todt"] = assignTodate.text
        param["assnmby"] = UserDefaults.standard.string(forKey: "EnttID")!
        param["enttid"] = UserDefaults.standard.string(forKey: "EnttID")!
        param["cuid"] = UserDefaults.standard.string(forKey: "UCODE")!
        param["toid"] = SchoolDetailsVariable.classID
        param["issendemail"] = self.toParentEmail
        
        Alamofire.request(Constants.getSaveAssignment, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
            case .success(_):
                let jsonDict = response.result.value as! NSDictionary
                print(jsonDict)
                self.hideProgress()
                if jsonDict["status"] as! Int == 200
                {
                    if let navigation = self.navigationController {
                        navigation.popViewController(animated: true)
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
    func downloadFile(url: String) {
    let myurl = URL(string: Constants.uploadAssignment)
        var request = URLRequest(url: myurl!)
        request.httpMethod = "POST"
        let boundary = generateBoundaryString()
     request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        let headerfile = URLResponse.getHeaderField(<#T##URLResponse#>)
        let data = url.data(using: .utf8)
        request.httpBody = createBodyWithParameters(filePathKey: "file", imageDataKey: data! as NSData, boundary: boundary) as Data
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            if error != nil {
                print("error=\(error ?? "" as! Error)")
                return
            }
                // You can print out response object
                print("******* response = \(String(describing: response))")
                // Print out reponse body
                let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print("****** response data = \(responseString!)")
                let result  = self.convertToDictionary(text: responseString! as String)
                if let name = result![0]["path"] {
                    let str = name as! String
                    let fullNameArr = str.components(separatedBy: "/")
                    self.pickedImagePath = fullNameArr[2]
                }
        }
        task.resume()
    }
    func uploadAssignmentTask(pickImage:UIImage)
    {
        let myUrl = URL(string: Constants.uploadAssignment)
        var request = URLRequest(url: myUrl!)
        request.httpMethod = "POST"
        let boundary = generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let imageData = UIImageJPEGRepresentation(pickImage, 1)
        if(imageData==nil)  { return; }
        request.httpBody = createBodyWithParameters(filePathKey: "file", imageDataKey: imageData! as NSData, boundary: boundary) as Data
        self.showProgressLoader(_view: self)
        self.mainView.isUserInteractionEnabled = false
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            if error != nil {
                print("error=\(error ?? "" as! Error)")
                return
            }
            DispatchQueue.main.async {
                  self.hideProgress()
                self.mainView.isUserInteractionEnabled = true
            // You can print out response object
            print("******* response = \(String(describing: response))")
            // Print out reponse body
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("****** response data = \(responseString!)")
            let result  = self.convertToDictionary(text: responseString! as String)
            if let name = result![0]["path"] {
                let str = name as! String
                let fullNameArr = str.components(separatedBy: "/")
                self.pickedImagePath = fullNameArr[2]
            }
            self.upload.setTitle("Successfully Upload", for: .normal)
            }
        }
        task.resume()
    }
    func createBodyWithParameters(filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData()
        let mimetype = mimeTypeForPath(path: pickedImage!)
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString("\r\n")
        body.appendString("--\(boundary)--\r\n")
        return body
    }
    func mimeTypeForPath(path: String) -> String {
        let url = NSURL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    func convertToDictionary(text: String) -> [AnyObject]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSArray
                return json as AnyObject! as! NSArray as [AnyObject]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}
extension URLResponse {
    func getHeaderField(key: String) -> String? {
        if let httpResponse = self as? HTTPURLResponse {
            if let field = httpResponse.allHeaderFields[key] as? String {
                return field
            }
        }
        return nil
    }
}



