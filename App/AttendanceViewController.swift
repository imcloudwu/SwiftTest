//
//  FirstViewController.swift
//  App
//
//  Created by Cloud on 10/1/14.
//  Copyright (c) 2014 Cloud. All rights reserved.
//

import UIKit

class AttendanceViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate {
    
    var _data:[Attendance]!
    var _lastChild:Child!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var Name: UILabel!
    
    @IBAction func changeChild(sender: AnyObject) {
        Global.Selector.Show()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _data = [Attendance]()
        
        if Global.CurrentChild == nil && Global.ChildList.count > 0{
            Global.CurrentChild = Global.ChildList[0]
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = UITableViewCell(style: UITableViewCellStyle.Value2, reuseIdentifier: "test")
        cell.textLabel?.text = _data[indexPath.row].Date
        cell.detailTextLabel?.text = _data[indexPath.row].Desc
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let alert = UIAlertView()
        alert.title = "Info"
        alert.message = _data[indexPath.row].Desc
        alert.addButtonWithTitle("OK")
        alert.show()
    }
    
    // Called when a button is clicked. The view will be automatically dismissed after this call returns
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        
        _data.removeAll(keepCapacity: false)
        
        Global.connector.SendRequest("absence.GetChildAttendance", body: "<Request><RefStudentId>\(Global.CurrentChild.ID)</RefStudentId></Request>") { (response) -> () in
            
            self.Name.text = Global.CurrentChild.Name
            var temp = Dictionary<String,Dictionary<String,String>>()
            var xml = SWXMLHash.parse(response)
            
            for att in xml["Envelope"]["Body"]["Response"]["Attendance"] {
                if let date = att.element?.attributes["OccurDate"]{
                    
                    //println("OccurDate:\(date)")
                    for elem in att["Detail"]["Period"] {
                        
                        if let type = elem.element?.attributes["AbsenceType"]{
                            if let period = elem.element?.text {
                                //println("\(type):\(period)")
                                
                                if temp[date] == nil{
                                    temp[date] = Dictionary<String,String>()
                                }
                                
                                if temp[date]?[type] == nil{
                                    temp[date]?[type] = period
                                }
                                else{
                                    temp[date]?[type] = temp[date]![type]! + "," + period
                                }
                            }
                        }
                    }
                }
            }
            
            for (key,value) in temp{
                var attendance = Attendance(Date: key, Desc: "")
                for (type,period) in value{
                    attendance.Desc = attendance.Desc + type + ":" + period + "\r\n"
                }
                
                self._data.append(attendance)
            }
            
            self._data.sort{$0.Date > $1.Date}
            
            self.tableView.reloadData()
        }
    }
    
    
    //切到該功能畫面時呼叫
    override func viewWillAppear(animated: Bool){
        Global.Selector.promp.delegate = self
        
        if _lastChild?.Name == Global.CurrentChild.Name && _lastChild?.ID == Global.CurrentChild.ID{
            return
        }
        
        if Global.CurrentChild != nil {
            alertView(Global.Selector.promp,clickedButtonAtIndex: 0)
        }
    }
    
    //離開畫面前記錄最後的小孩
    override func viewDidDisappear(animated: Bool){
        _lastChild = Global.CurrentChild
    }
}
