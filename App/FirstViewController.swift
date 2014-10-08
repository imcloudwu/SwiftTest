//
//  FirstViewController.swift
//  App
//
//  Created by Cloud on 10/1/14.
//  Copyright (c) 2014 Cloud. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    var con:Connector!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var myqueue1 = dispatch_queue_create("myqueue1", nil)
        var myqueue2 = dispatch_queue_create("myqueue2", nil)
        
        con = Connector(authUrl: "https://auth.ischool.com.tw/oauth/token.php", accessPoint: "http://dev.ischool.com.tw:8080/cs4_beta/dev.sh_d", contract: "ischool.parent.app")
        
        con.ClientID = "5e89bdfbf971974e3b53312384c0013a"
        con.ClientSecret = "855b8e05afadc32a7a2ecbf0b09011422e5e84227feb5449b1ad60078771f979"
        con.UserName = "bubu@debug.ischool.com.tw"
        con.Password = "1234"
        
        con.Queue1 = myqueue1
        con.Queue2 = myqueue2
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btn_click(sender: AnyObject) {
        
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
        
        con.SendRequest("absence.GetAbsenceNames", body: "") { (response) -> () in
            var xml = SWXMLHash.parse(response)
            for elem in xml["Envelope"]["Body"]["data"] {
                println(elem["name"].element?.text)
            }
        }
        
        con.SendRequest("evaluateScoreSH.GetClassExamScore", body: "<Request><StudentID>55137</StudentID><SchoolYear>99</SchoolYear><Semester>1</Semester><ExamName>第一次月考</ExamName><Subject>閱讀指導</Subject></Request>") { (response) -> () in
            println(response)
            var xml = SWXMLHash.parse(response)
            for elem in xml["Envelope"]["Body"]["Exam"] {
                println(elem["ref_student_id"].element?.text)
                println(elem["score"].element?.text)
                println(elem["exam_name"].element?.text)
                println(elem["course_name"].element?.text)
                println(elem["subject"].element?.text)
                println(elem["school_year"].element?.text)
                println(elem["semester"].element?.text)
            }
        }
    }
}
