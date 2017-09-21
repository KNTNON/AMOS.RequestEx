//
//  AMSDatastore.swift
//  AMSFramework
//
//  Created by Train on 10/4/2559 BE.
//
//

import Foundation

class AMSDatastore: NSObject {

    // MARK: - Typealias
    typealias AMSDataStoreBlock=(NSDictionary?) -> Void
    
    // MARK: - Properties
    var data:NSArray?
    var url:NSString?
    var useProxy:Bool?
    var parameters:NSDictionary?
    var timeout:NSNumber?
    var type:NSString?
    var isMultipartData:Bool?
    var completionHandler:AMSDataStoreBlock?
    var errorHandler:AMSDataStoreBlock?
    
    override init() {}
    
    // MARK: - Class methods
    public func dataStoreWithOptions(option : NSDictionary?) -> AMSDatastore {
        let instance = AMSDatastore()
        
        if let option = option {
            if option["data"] is NSArray{
                instance.data = option.object(forKey: "data") as? NSArray
            }
            if option["url"] is NSString{
                instance.url = option.object(forKey: "url") as? NSString
            }
            instance.useProxy = option["useProxy"] != nil ? option["useProxy"] as? Bool : false
            if option["parameters"] is NSDictionary{
                instance.parameters = option.object(forKey: "parameters") as? NSDictionary
            }
            if option["timeout"] is NSNumber {
                instance.timeout = option.object(forKey: "timeout") as? NSNumber
            }
            else{
                instance.timeout = 0
            }
            let get = "GET"
            let post = "POST"
            if let type = option["type"]{
                if type as! String == get || type as! String == post{
                    instance.type = type as? NSString
                }
            }
            instance.isMultipartData = option["isMultipartData"] != nil ? option["isMultipartData"] as? Bool : false
        }
            
        else{
            return AMSDatastore()
        }
        
        return instance
    }

    public func dataStoreWithData(data:NSArray?,options:NSDictionary?) -> AMSDatastore {
        
            guard data != nil || options != nil else {
                return AMSDatastore()
            }
        
            let tmp = NSMutableDictionary(dictionary:options!)
            tmp["data"] = data!
        
        return self.dataStoreWithOptions(option:tmp)
        
    }
    
    public func dataStoreWithURL(url:NSString?, parameters:NSDictionary? = nil, options:NSDictionary?) -> AMSDatastore {
        
        guard url != nil || options != nil else {
            return AMSDatastore()
        }
        
        let tmp = NSMutableDictionary(dictionary:options!)
        tmp["url"] = url!;
        tmp["parameters"] = parameters != nil ? parameters! : [:];
        return self.dataStoreWithOptions(option:tmp)
    }
    
    //MARK: - Private instance methods
    private func sendResponseWithData(data:Any?){
        
        guard data != nil else { return }
        
        if data is NSDictionary {
            if let data = data as? NSDictionary {
                
                guard data["data"] != nil && data["success"] != nil else { return }
                
                if data["success"] as! Bool {
                    if (self.completionHandler != nil) {
                        self.completionHandler!(data)
                    }
                }
                else{
                    if (self.errorHandler != nil){
                        self.errorHandler!(data)
                    }
                }
                
            }
        }
        else{
            let formattedDate:[String:Any] = ["data": data != nil ? (data is NSArray) ? data : [data] : [],"success":1]
            
            if(self.completionHandler != nil){
                self.completionHandler!(formattedDate as NSDictionary);
            }
            }
    }
    
    private func sendErrorMessage(message:NSString? = nil,errorHandler:AMSDataStoreBlock? = nil){
        
        guard message != nil || errorHandler != nil else { return }
        
        let data:[String:Any] = ["data":[],"success":0,"message":message!]
        
        if(self.errorHandler != nil){
            self.errorHandler!(data as NSDictionary)
        }
        
    }
    
    private func recheckType() {
        
        guard self.data != nil && self.url != nil else { return }
        
            self.type = self.type == "GET" ? "GET" : "POST"
    }
    
    private func request(){
        let param = NSMutableDictionary()
        if let parameters = self.parameters{
            for key in parameters{
                if(parameters[key] is NSString || parameters[key] is NSNumber || parameters[key] is NSNull){
                    param[key] = parameters[key]
                }
                else if (parameters[key] is NSData){
                    let date = parameters[key] as! NSDate
                    param[key] = NSNumber.init(value: date.timeIntervalSince1970)
                }
                else{
                    self.sendErrorMessage(message: "[AMSDataStore] Wrong type of parameter: \(key).\rSupported types \(self.type!): \rNSString for string value.\rNSNumber for number or boolean(0, 1) value.\rNSDate for date value." as NSString!,
                                          errorHandler: self.errorHandler)
                    return
                }
            }
    
        }
    }
    
    private func requestWithMultipartData(){
        let boundary = UUID().uuidString
//        let req = NSMutableURLRequest(url: URL(fileURLWithPath: String(format:"%@?%@", AMSConfig.proxyURL!,self.url!)))
        let req = NSMutableURLRequest(url: URL(fileURLWithPath: String(format:"%@?%@", self.url!,self.url!)))
        req.httpMethod = self.type != nil ? self.type! as String : ""
        req.setValue(String(format:"multipart/form-data; boundary=%@",boundary), forHTTPHeaderField:"Content-Type")
        
        //MARK: Will edit
//        let httpBody:Data?
//        NSData *httpBody = [self createMultipartDataHTTPBodyWithParameters:_parameters boundary:boundary];
//        if httpBody != nil {
//            req.httpBody = httpBody
//            [AMSRequest requestWithOptions:@{
//                @"request": req,
//                @"timeout": _timeout ? _timeout : @0,
//            }
//            completionHandler:^(NSDictionary *response) {
//                [self sendResponseWithData:response];
//            }
//            errorHandler:^(NSError *error) {
//                [self sendErrorMessage:[NSString stringWithFormat:@"[%@] Error(%d): %@", error.domain, error.code, error.userInfo[NSLocalizedDescriptionKey]] toErrorHandler:_errorHandler];
//            }];
            }
    
    private func createMultipartDataHTTPBodyWithParameters(parameters:NSDictionary? ,boundary:NSString? = nil)-> NSData{
        let httpBody = NSMutableData()
        let dataNil:NSData! = nil
        
        let tmpboundary = boundary ?? ""
        
        if let parameters = parameters{
            for key in parameters{
                httpBody.append(String(format: "--%@\r\n", tmpboundary).data(using: .utf8)!)
                httpBody.append(String(format: "Content-Disposition: form-data; name=\"%@\"",key as! CVarArg).data(using: .utf8)!)
                if parameters[key] is NSDictionary {
                    
                    if let tmp = parameters[key] as? NSDictionary{
                        if tmp.object(forKey: "fileData") != nil && !(tmp.object(forKey: "fileData") is NSDate) {
                            self.sendErrorMessage(message: String(format:"[AMSDataStore] Wrong type of parameter: %@.\rSupported types (POST with multipart/form-data): \rNSString for string value.\rNSNumber for number or boolean(0, 1) value.\rNSDate for date value.\rNSDictionary with keys {fileName(NSString), mimeType(NSString), fileData(NSData)} for file's details.",key as! CVarArg) as NSString!, errorHandler: self.errorHandler)
                            return dataNil
                        }
                        
                        if let filename = tmp.object(forKey: "fileName") as? String ,!filename.isEmpty {
                            httpBody.append(String(format:"; filename=\"%@\"\r\n", filename).data(using: .utf8)!)
                        }
                        else{
                            httpBody.append(String(format:"; filename=\"\"\r\n").data(using: .utf8)!)
                        }
                        
                        if let mimeType = tmp.object(forKey: "mimeType") as? String, !mimeType.isEmpty{
                            httpBody.append(String(format:"Content-Type: %@\r\n\r\n", mimeType).data(using: .utf8)!)
                        }
                        else{
                            httpBody.append(String(format:"Content-Type: \r\n\r\n").data(using: .utf8)!)
                        }
                        
                        httpBody.append(tmp.object(forKey: "fileData") as! Data)
                    }
                }
                else if parameters[key] is NSString || parameters[key] is NSNumber {
                    httpBody.append(String(format: "\r\n\r\n%@", parameters[key] as Any as! CVarArg ).data(using: .utf8)!)
                }
                else if parameters[key] is NSNull {
                    httpBody.append(String(format: "\r\n\r\n").data(using: .utf8)!)
                }
                else if parameters[key] is NSDate {
                    let date:NSDate = parameters[key] as! NSDate
                    httpBody.append(String(format: "\r\n\r\n%@",NSNumber(integerLiteral: Int(date.timeIntervalSince1970))).data(using: .utf8)!)
                }
                else{
                    self.sendErrorMessage(message: String(format:"[AMSDataStore] Wrong type of parameter: %@.\rSupported types (POST with multipart/form-data): \rNSString for string value.\rNSNumber for number or boolean(0, 1) value.\rNSDate for date value.\rNSDictionary with keys {fileName(NSString), mimeType(NSString), fileData(NSData)} for file's details.", key as! CVarArg) as NSString!,
                    errorHandler: self.errorHandler)
                    return dataNil
                }
                httpBody.append("\r\n".data(using: .utf8)!)
            }
        }
        httpBody.append(String(format: "--%@--\r\n", tmpboundary).data(using: .utf8)!)
        return httpBody
    }

    // MARK: - Instance methods
    public func query() {
        self.recheckType()
        if let type = self.type{
            if (type as String == "GET" || type as String == "POST"){
                if self.isMultipartData != nil{
                    self.type = "POST" as NSString
                    self.requestWithMultipartData()
                }
                else{
                    self.request()
                }
            }
            else{
                if let data = self.data{
                    self.sendResponseWithData(data: data)
                }
            }
        }
    }
    
    public func queryWithCompletionHandler(completionHandler:@escaping AMSDataStoreBlock,errorHandler:@escaping AMSDataStoreBlock) {
        self.completionHandler = completionHandler
        self.errorHandler = errorHandler
        self.query()
    }
    
}







