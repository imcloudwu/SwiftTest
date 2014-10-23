//
//  FirstViewController.swift
//  App
//
//  Created by Cloud on 10/1/14.
//  Copyright (c) 2014 Cloud. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    var con:Connector!
    
    @IBOutlet weak var txtAccount: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Global.connector = Connector(authUrl: "https://auth.ischool.com.tw/oauth/token.php", accessPoint: "http://dev.ischool.com.tw:8080/cs4_beta/dev.sh_d", contract: "ischool.parent.app")
        
        con = Global.connector
        
        //con = Connector(authUrl: "https://auth.ischool.com.tw/oauth/token.php", accessPoint: "http://dev.ischool.com.tw:8080/cs4_beta/dev.sh_d", contract: "ischool.parent.app")
        
        con.ClientID = "5e89bdfbf971974e3b53312384c0013a"
        con.ClientSecret = "855b8e05afadc32a7a2ecbf0b09011422e5e84227feb5449b1ad60078771f979"
//        con.UserName = "bubu@debug.ischool.com.tw"
//        con.Password = "1234"
        
        txtAccount.text = "bubu@debug.ischool.com.tw"
        txtPassword.text = "1234"
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btn_click(sender: AnyObject) {
        
        con.UserName = txtAccount.text
        con.Password = txtPassword.text
        
        if con.IsValidated() {
            
            println(Global.connector.AccessToken)
            println(Global.connector.SessionID)
            
            //Get Children List
            con.SendRequest("main.GetMyChildrenWithoutPhoto", body: "") { (response) -> () in
                var xml = SWXMLHash.parse(response)
                for elem in xml["Envelope"]["Body"]["Student"] {
                    if let id = elem["StudentId"].element?.text{
                        if let name = elem["StudentName"].element?.text{
                            Global.ChildList.append(Child(ID: id,Name: name))
                        }
                    }
                }
                
                Global.Selector = PrompView.GetInstance()
                
                var nextView = self.storyboard?.instantiateViewControllerWithIdentifier("Main") as UIViewController
                self.showViewController(nextView, sender: nil)
            }
        }
        else{
            let alert = UIAlertView()
            alert.title = "Login failed"
            alert.message = "Account or password is incorrect"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
}
