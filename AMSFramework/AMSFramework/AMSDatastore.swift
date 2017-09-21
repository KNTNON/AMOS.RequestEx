//
//  AMSDatastore.swift
//  AMSFramework
//
//  Created by Train on 10/4/2559 BE.
//
//

import UIKit

class AMSDatastore: NSObject {

    // MARK: - Typedefs
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
    
    // MARK: - Class methods
    func dataStoreWithOptions(_ option : NSDictionary?) -> AMSDatastore{
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
        return instance;
    }

    func dataStoreWithData(_ data:NSArray, options:NSDictionary){
        let tmp = NSMutableDictionary(dictionary:options)
    }
}
