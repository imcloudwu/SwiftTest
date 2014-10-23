//
//  FirstViewController.swift
//  App
//
//  Created by Cloud on 10/1/14.
//  Copyright (c) 2014 Cloud. All rights reserved.
//

import UIKit

class SemesterScoreViewController: UIViewController,UIAlertViewDelegate,UITabBarDelegate,UITableViewDelegate,UITableViewDataSource {
    
    var _lastChild:Child!
    var _sysm:[SYSM]!
    var _items:[UITabBarItem]!
    var _data:[SemsScore]!
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var Name: UILabel!
    
    @IBAction func changeChild(sender: AnyObject) {
        Global.Selector.Show()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _sysm = [SYSM]()
        _items = [UITabBarItem]()
        _data = [SemsScore]()
        
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
        cell.textLabel?.text = _data[indexPath.row].Name
        cell.detailTextLabel?.text = _data[indexPath.row].Score
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let alert = UIAlertView()
        alert.title = "Info"
        alert.message = _data[indexPath.row].Credit
        alert.addButtonWithTitle("OK")
        alert.show()
    }
    
    // Called when a button is clicked. The view will be automatically dismissed after this call returns
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        
        Global.connector.SendRequest("semesterScoreSH.GetChildSemsScore", body: "<Request><RefStudentId>\(Global.CurrentChild.ID)</RefStudentId></Request>") { (response) -> () in
            
            self.Name.text = Global.CurrentChild.Name
            self.tabBar.setItems([], animated: true)
            self._items.removeAll(keepCapacity: false)
            self._sysm.removeAll(keepCapacity: false)
            
            var xml = SWXMLHash.parse(response)
            for elem in xml["Envelope"]["Body"]["Response"]["SemsSubjScore"] {
                var school_year = elem.element?.attributes["SchoolYear"]
                var semester = elem.element?.attributes["Semester"]
                
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
        Global.connector.SendRequest("semesterScoreSH.GetChildSemsScore", body: "<Request><ScoreInfo/><RefStudentId>\(Global.CurrentChild.ID)</RefStudentId><SchoolYear>\(sy)</SchoolYear><Semester>\(sm)</Semester></Request>") { (response) -> () in
            
            self._data.removeAll(keepCapacity: false)
            
            var xml = SWXMLHash.parse(response)
            for elem in xml["Envelope"]["Body"]["Response"]["SemsSubjScore"]["ScoreInfo"] {
                
                var info = elem.element?.text
                
                var data = SWXMLHash.parse(info!)
                for ele in data["SemesterSubjectScoreInfo"]["Subject"] {
                    var name = ele.element?.attributes["科目"]
                    var score = ele.element?.attributes["原始成績"]
                    var credit = ele.element?.attributes["開課學分數"]
                    
                    var ss = SemsScore(Name: name, Score: score, Credit: credit)
                    
                    self._data.append(ss)
                }
            }
            
            self.tableView.reloadData()
        }
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
