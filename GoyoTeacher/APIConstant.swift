//
//  APIConstant.swift
//  GoyoTeacher
//
//  Created by admin on 24/10/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import Foundation
struct Constants {
    static let APIURL  = "http://track.goyo.in:8082/goyoapi/"
    static let LiveImageUrl  = "http://track.goyo.in:8082/"
    static let LocalAPI  = "http://192.168.1.107:8082/goyoapi/"
    static let localImageURL = "http://192.168.1.107:8082/images/"
    static let schoolAssignment = "http://school.goyo.in:8082/goyoapi/uploads"

    //Live
    static let loginDetails = APIURL+"getLogin"
    //local
    static let getclassDetails = APIURL+"erp/getClassDetails"
    static let getclassAttendance = APIURL+"erp/getAttendance"
    static let getsaveAttendance = APIURL+"erp/saveAttendance"
    static let getNotification = APIURL+"erp/getNotification"
    static let getExam = APIURL+"erp/getExamDetails"
    static let getProgressCard = APIURL+"erp/getExamResult"
    static let getHoliday = APIURL+"getHoliday"
    static let getAssignment = APIURL+"erp/getAssignmentDetails"
    static let getSaveAssignment = APIURL+"erp/saveAssignmentInfo"
    static let getTeacherLeave = APIURL+"getPassengerLeave"
    static let getSaveTeacherLeave = APIURL+"savePassengerLeave"
    static let teacherTimeIn = APIURL+"erp/tripapi/start"
    static let teacherTimeOut = APIURL+"erp/tripapi/stop"
    static let getEmpStatus = APIURL+"erp/tripapi/getEmpStatus"
    static let userProfile = APIURL+"getUserDetails"
    static let teacherTimeTable = APIURL+"erp/getTimeTable"
    static let getStudentList = APIURL+"erp/getTeacherRemark"
    static let saveTeacherRemark = APIURL+"erp/saveTeacherRemark"
    static let getContent = APIURL+"erp/getContentDetails"

    static let uploadAssignment = schoolAssignment
}

