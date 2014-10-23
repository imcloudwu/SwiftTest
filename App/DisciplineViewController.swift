//
//  FirstViewController.swift
//  App
//
//  Created by Cloud on 10/1/14.
//  Copyright (c) 2014 Cloud. All rights reserved.
//

import UIKit

class DisciplineViewController: UIViewController,UIAlertViewDelegate,UITabBarDelegate,UITableViewDelegate,UITableViewDataSource{
    
    var _lastChild:Child!
    var _sysm:[SYSM]!
    var _items:[UITabBarItem]!
    var _data:[Record]!
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var Name: UILabel!
    
    @IBAction func changeChild(sender: AnyObject) {
        Global.Selector.Show()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _sysm = [SYSM]()
        _data = [Record]()
        _items = [UITabBarItem]()
        
        if Global.CurrentChild == nil && Global.ChildList.count > 0{
                Global.CurrentChild = Global.ChildList[0]
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        
        Global.connector.SendRequest("discipline.GetSchoolYearSemester", body: "<id>\(Global.CurrentChild.ID)</id>") { (response) -> () in
            
            self.Name.text = Global.CurrentChild.Name
            self.tabBar.setItems([], animated: true)
            self._items.removeAll(keepCapacity: false)
            self._sysm.removeAll(keepCapacity: false)
            
            var xml = SWXMLHash.parse(response)
            for elem in xml["Envelope"]["Body"]["data"] {
                var school_year = elem["school_year"].element?.text
                var semester = elem["semester"].element?.text
                
                if school_year != nil && semester != nil{
                    self._sysm.append(SYSM(SchoolYear: school_year!, Semester: semester!))
                }
            }
            
            var font = UIFont(name: "HelveticaNeue-Light", size: 16.0)
            var index = 0
            for sysm in self._sysm{
                var title = sysm.SchoolYear + sysm.Semester
                var item = UITabBarItem(title: title, image: nil, tag: index)
                item.setTitlePositionAdjustment(UIOffsetMake(0.0, -20.0))
                item.setTitleTextAttributes([NSFontAttributeName:font], forState: UIControlState.Normal)
                index++
                self._items.append(item)
            }
            
            self.tabBar.setItems(self._items, animated: true)
            if self._items.count > 0{
                self.tabBar.selectedItem = self._items[0]
                self.tabBar(self.tabBar, didSelectItem: self._items[0])
            }
        }
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        
        var sy = _sysm[item.tag].SchoolYear
        var sm = _sysm[item.tag].Semester
        Global.connector.SendRequest("discipline.GetDiscipline", body: "<id>\(Global.CurrentChild.ID)</id><school_year>\(sy)</school_year><semester>\(sm)</semester>") { (response) -> () in
            
            self._data.removeAll(keepCapacity: false)
            var xml = SWXMLHash.parse(response)
            for elem in xml["Envelope"]["Body"]["data"] {
                var merita = elem["merita"].element?.text
                var meritb = elem["meritb"].element?.text
                var meritc = elem["meritc"].element?.text
                var demerita = elem["demerita"].element?.text
                var demeritb = elem["demeritb"].element?.text
                var demeritc = elem["demeritc"].element?.text
                var occur_date = elem["occur_date"].element?.text
                var reason = elem["reason"].element?.text
                var isDemerit = false
                
                if let hasDemerit =  demerita{
                    isDemerit = true
                }
                
                var record = Record(MeritA: merita, MeritB: meritb, MeritC: meritc, DemeritA: demerita, DemeritB: demeritb, DemeritC: demeritc, Date: occur_date, Reason: reason, isDemerit: isDemerit)
                
                self._data.append(record)
            }
            
            self.tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = UITableViewCell(style: UITableViewCellStyle.Value2, reuseIdentifier: "discipline")
        cell.textLabel?.text = (_data[indexPath.row].Date as NSString).substringToIndex(10)
        cell.detailTextLabel?.text = _data[indexPath.row].Reason
        
        if _data[indexPath.row].isDemerit{
            cell.detailTextLabel?.textColor = UIColor.redColor()
        }
        else{
            cell.detailTextLabel?.textColor = UIColor.greenColor()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        
        var record = _data[indexPath.row]
        var msg:String
        
        if record.MeritA != nil{
            msg = "大功:\(record.MeritA)\r\n小功:\(record.MeritB)\r\n嘉獎:\(record.MeritC)\r\n原因:\(record.Reason)"
        }
        else{
            msg = "大過:\(record.DemeritA)\r\n小過:\(record.DemeritB)\r\n警告:\(record.DemeritC)\r\n原因:\(record.Reason)"
        }
        
        let alert = UIAlertView()
        alert.title = "Info"
        alert.message = msg
        alert.addButtonWithTitle("OK")
        alert.show()
    }
    
    //切到該功能畫面時呼叫
    override func viewWillAppear(animated: Bool){
        Global.Selector.promp.delegate = self
        
        if _lastChild?.Name == Global.CurrentChild.Name && _lastChild?.ID == Global.CurrentChild.ID {
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
