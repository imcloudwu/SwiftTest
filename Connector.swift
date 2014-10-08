//
//  Connector.swift
//  App
//
//  Created by Cloud on 10/8/14.
//  Copyright (c) 2014 Cloud. All rights reserved.
//

import Foundation

public class Connector{
    
    var AccessToken:String!
    var SessionID:String!
    var ClientID:String!
    var ClientSecret:String!
    var UserName:String!
    var Password:String!
    var AccessPoint:String!
    var Contract:String!
    private var AuthUrl:String!
    var Queue1:dispatch_queue_t!
    var Queue2:dispatch_queue_t!
    var Lock:NSLock!
    
    init(authUrl:String,accessPoint:String,contract:String){
        AuthUrl = authUrl
        AccessPoint = accessPoint
        Contract = contract
        Lock = NSLock()
    }
    
    private func getAuthUrl() -> String {
        return "\(AuthUrl)?grant_type=password&client_id=\(ClientID)&client_secret=\(ClientSecret)&username=\(UserName)&password=\(Password)"
    }
    
    func SendRequest(service:String,body:String,function:(response:String) -> ()){
        
        Lock.lock()
            if self.SessionID == nil {
                self.GetAccessTokenAndSessionID({
                    var body = "<Envelope><Header><TargetContract>\(self.Contract)</TargetContract><TargetService>\(service)</TargetService><SecurityToken Type='Session'><SessionID>\(self.SessionID)</SessionID></SecurityToken></Header><Body>\(body)</Body></Envelope>"
                    
                    HttpClient.POST(self.AccessPoint, body: body, callback: { data in
                        function(response: data)
                    })
                })
            }
            else{
                var body = "<Envelope><Header><TargetContract>\(self.Contract)</TargetContract><TargetService>\(service)</TargetService><SecurityToken Type='Session'><SessionID>\(self.SessionID)</SessionID></SecurityToken></Header><Body>\(body)</Body></Envelope>"
                
                HttpClient.POST(self.AccessPoint, body: body, callback: { data in
                    function(response: data)
                    //self.Lock.unlock()
                })
            }
        self.Lock.unlock()
        
    }
    
    private func GetAccessTokenAndSessionID(function:()->Void){
        
            //Get AccessToken
            HttpClient.Get(self.getAuthUrl(), callback: {(data) in
                
                var nsdata = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                
                var jsonDict = NSJSONSerialization.JSONObjectWithData(nsdata!, options: nil, error: nil) as NSDictionary
                var wrapping_accessToken = jsonDict["access_token"] as String?
                
                if let accessToken = wrapping_accessToken{
                    println("accessToken: \(accessToken)")
                    
                    var body = "<Envelope><Header><TargetContract>\(self.Contract)</TargetContract><TargetService>DS.Base.Connect</TargetService><SecurityToken Type='PassportAccessToken'><AccessToken>\(accessToken)</AccessToken></SecurityToken></Header><Body><RequestSessionID/></Body></Envelope>"
                    
                    //Get SessionID
                    HttpClient.POST(self.AccessPoint, body: body, callback: { data in
                        
                        var xml = SWXMLHash.parse(data)
                        var wrapping_sessionid = xml["Envelope"]["Body"]["SessionID"].element?.text
                        
                        if let sessionid = wrapping_sessionid{
                            self.SessionID = sessionid
                            println("sessionid: \(sessionid)")
                            
                            //After got SessionID
                            function()
                        }
                    })
                }
            })
    }
}
