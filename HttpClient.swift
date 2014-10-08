//
//  Http.swift
//  App
//
//  Created by Cloud on 10/8/14.
//  Copyright (c) 2014 Cloud. All rights reserved.
//

import Foundation

public class HttpClient{
    
    class func Get(url:String,callback:(data:String) -> ()){
        
        var req = NSURLRequest(URL: NSURL(string: url))
        var conn = NSURLConnection(request: req, delegate: HttpRequest(callback), startImmediately: true)
    }
    
    class func POST(url:String,body:String,callback:(data:String) -> ()){
        
        var req = NSMutableURLRequest()
        req.URL = NSURL(string:url)
        req.HTTPMethod = "POST"
        req.HTTPBody = body.dataUsingEncoding( NSUTF8StringEncoding, allowLossyConversion: true)
        var conn = NSURLConnection(request: req, delegate: HttpRequest(callback), startImmediately: true)
    }
    
    class HttpRequest:NSObject{
        
        private var callback:(data:String) -> ()
        
        init(callback:(data:String) -> ()){
            self.callback = callback
        }
        
        func connection(connection: NSURLConnection, didReceiveData data: NSData){
            var string = NSString(data: data, encoding: NSUTF8StringEncoding)
            
            self.callback(data:string)
        }
    }
}