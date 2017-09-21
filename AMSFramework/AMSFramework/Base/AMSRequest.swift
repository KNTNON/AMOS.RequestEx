//
//  AMSRequest.swift
//  AMSFramework
//
//  Created by Train on 10/6/2559 BE.
//
//

import Foundation

class AMSRequest {
    
    
    // MARK : - Public class methods
    public func sendErrorMessage(message:NSString?,toErrorHandler errorHandler:_AMSCore.AMSErrorBlock){
        
    }
    
    // MARK : - Class methods
    public func requestWithOptions(options:NSDictionary?){
        
        
    }
    
    public func requestWithOptions(options:NSDictionary?, completionHandler:_AMSCore.AMSIdBlock, errorHandler:_AMSCore.AMSErrorBlock){
        var req = NSMutableURLRequest()
        if let options = options {
            if options["request"] != nil{
                
                if options["request"] is NSURLRequest {
                    req = (options["request"] as? NSMutableURLRequest)!
                }
                else{
                    self.sendErrorMessage(message: "request is not valid.", toErrorHandler:errorHandler)
                    return
                }
            }
            else if options["url"] != nil{
                if options["url"] is NSString{
                    req = NSMutableURLRequest(url:URL(string: options["useProxy"] as! Bool ? String(format:"%@?%@", options["url"] as! String ,options["url"] as! String) : options["url"] as! String )!)
                    if options["method"] != nil {
                        if options["method"] as! String == "GET" || options["method"] as! String == "POST"{
                            req.httpMethod = options["method"] as! String
                        }
                        else{
                            self.sendErrorMessage(message: "method is not valid.", toErrorHandler:errorHandler)
                            return
                        }
                    }
                    if options["httpBodyData"] != nil{
                        if options["httpBodyData"] is NSData {
                            if !(req.httpMethod == "POST"){
                                self.sendErrorMessage(message: "httpBodyData is required POST method.", toErrorHandler: errorHandler)
                                return
                            }
                            else if !(options["contentType"] != nil && options["contentType"] is NSString){
                                self.sendErrorMessage(message: "httpBodyData is required valid contentType.", toErrorHandler: errorHandler)
                                return
                            }
                            req.setValue(options["contentType"] as? String, forHTTPHeaderField: "Content-Type")
                            req.httpBody = options["httpBodyData"] as? Data
                        }
                        else{
                            self.sendErrorMessage(message: "httpBodyData is not valid.", toErrorHandler: errorHandler)
                            return
                        }
                    }
                    else if options["parameters"] != nil {
                        if options["parameters"] is NSDictionary {
                            if req.httpMethod == "GET"{
//                                NSString *urlenParams = [_AMSCore urlEncodedStringOfDictionary:options[@"parameters"]];
                                let urlenParams:NSString = ""
                                if (req.url!.absoluteString as NSString).range(of: "?").location == NSNotFound {
                                    req.url = URL(fileURLWithPath: String(format: "%@?%@", req.url!.absoluteString, urlenParams))
                                }
                                else{
                                    req.url = URL(fileURLWithPath: String(format: "%@&%@", req.url!.absoluteString, urlenParams))
                                }
                            }
                    }
                }
            }
        }
    }
}
}
