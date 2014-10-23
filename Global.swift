//
//  Global.swift
//  App
//
//  Created by Cloud on 10/9/14.
//  Copyright (c) 2014 Cloud. All rights reserved.
//

import Foundation
import UIKit

struct Global{
    static var connector:Connector!
    static var ChildList:[Child] = [Child]()
    static var CurrentChild:Child!
    static var Selector:PrompView!
}

class PrompView:NSObject,UIPickerViewDataSource,UIPickerViewDelegate{
    
    var promp:UIAlertView!
    var picker:UIPickerView!
    
    class func GetInstance() -> PrompView {
        
        struct Static {
            static var instance: PrompView?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = PrompView()
        }
        
        return Static.instance!
    }
    
    private override init(){
        super.init()
        promp = UIAlertView()
        picker = UIPickerView()
        
        picker.delegate = self
        picker.dataSource = self
        promp.title = "選擇小孩"
        promp.setValue(picker, forKey: "accessoryView")
        promp.addButtonWithTitle("確認")
        promp.delegate = self
    }
    
    func Show(){
        promp.show()
    }
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return Global.ChildList.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!{
        return Global.ChildList[row].Name
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        Global.CurrentChild = Global.ChildList[row]
    }
}

struct Child{
    var ID:String!
    var Name:String!
}

struct Attendance{
    var Date:String
    var Desc:String
}

struct SYSM{
    var SchoolYear:String
    var Semester:String
}

struct Record{
    var MeritA:String!
    var MeritB:String!
    var MeritC:String!
    var DemeritA:String!
    var DemeritB:String!
    var DemeritC:String!
    var Date:String!
    var Reason:String!
    var isDemerit:Bool
}

struct SemsScore{
    var Name:String!
    var Score:String!
    var Credit:String!
}

//Connector Sample Code
/*
con.SendRequest("absence.GetAbsenceNames", body: "") { (response) -> () in
var xml = SWXMLHash.parse(response)
for elem in xml["Envelope"]["Body"]["data"] {
println(elem["name"].element?.text)
}
}

con.SendRequest("evaluateScoreSH.GetClassExamScore", body: "<Request><StudentID>55137</StudentID><SchoolYear>99</SchoolYear><Semester>1</Semester><ExamName>第一次月考</ExamName><Subject>閱讀指導</Subject></Request>") { (response) -> () in
var xml = SWXMLHash.parse(response)
for elem in xml["Envelope"]["Body"]["Exam"] {
println(elem["ref_student_id"].element?.text)
//                println(elem["score"].element?.text)
//                println(elem["exam_name"].element?.text)
//                println(elem["course_name"].element?.text)
//                println(elem["subject"].element?.text)
//                println(elem["school_year"].element?.text)
//                println(elem["semester"].element?.text)
}
}

con.SendRequest("main.GetSchoolInfo", body: "") { (response) -> () in
var xml = SWXMLHash.parse(response)
for elem in xml["Envelope"]["Body"]["SchoolInfo"] {
println(elem["ChineseName"].element?.text)
println(elem["EnglishName"].element?.text)
println(elem["Address"].element?.text)
println(elem["Code"].element?.text)
println(elem["Fax"].element?.text)
}
}
*/