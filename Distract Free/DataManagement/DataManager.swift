//
//  DataManager.swift
//  Radio Event
//
//  Created by adb on 1/1/18.
//  Copyright © 2018 Arena. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


protocol DataManagerDelegate :class {
    func didFinishTask(Data: [APIResponse])
}
class DataManager: NSObject {

    var baseURL = "http://rasamfard.ir/api/"
    var delegate:DataManagerDelegate?

    func RegisterNumber(phonenumber:String,completion: @escaping (APIResponse) -> Void) {
        
        let params: [String: Any] = ["phone":phonenumber]
        let response = APIResponse()
        
        Alamofire.request(baseURL+"login", method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                
                print(responseData)
                //to get status code
                if let status = responseData.response?.statusCode {
                    switch(status){
                    case 200:
                        if let resData = JSON(responseData.result.value!).dictionaryObject {
                            if resData.count > 0 {
                                response.message = resData["message"] as? String
                                response.result = resData["result"] as? Bool
                            }
                        }
                    default:
                        print("error with response status: \(status)")
                    }
                }
                
                
            }
            completion(response)
        }
    }
    
    func CheckCode(Code:String,phonenumber:String,completion: @escaping (APIResponse) -> Void) {
        
        let params: [String: Any] = ["phone":phonenumber,"password":Code]
        let response = APIResponse()
        
        Alamofire.request(baseURL+"gettoken", method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                
                print(responseData)
                //to get status code
                if let status = responseData.response?.statusCode {
                    switch(status){
                    case 200:
                        if let resData = JSON(responseData.result.value!).dictionaryObject {
                            if resData.count > 0 {
                                response.message = resData["message"] as? String
                                response.result = true
                                response.token = resData["token"] as? String   
                            }
                        }
                    default:
                        print("error with response status: \(status)")
                    }
                }
                
                
            }
            completion(response)
        }
    }
    
    func GetToken(phonenumber:String,Password:String,completion: @escaping (APIResponse) -> Void) {
        
        
        let params: [String: Any] = ["username":phonenumber,"password":Password,"grant_type":"password"]
        let response = APIResponse()
        
        Alamofire.request("http://eventbot.ir/" + "Token", method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                
                print(responseData)
                //to get status code
                if let status = responseData.response?.statusCode {
                    switch(status){
                    case 200:
                        if let resData = JSON(responseData.result.value!).dictionaryObject {
                            if resData.count > 0 {
                                response.message = "Success"
                                response.result = true
                                response.token = resData["access_token"] as? String                                
                            }
                        }
                    default:
                        print("error with response status: \(status)")
                    }
                }
            }
            completion(response)
        }
    }
    
    func PostFavorites(cities:[Int],artists:[Int],completion: @escaping (APIResponse) -> Void) {
        
        let params: [String: Any] = ["cities":cities,"artists":artists]
        let response = APIResponse()
        
        let headers = [
            "Authorization": "Bearer " + TokenManager().Token
            ]

        Alamofire.request(baseURL+"PostFavorits", method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                
                print(responseData)
                //to get status code
                if let status = responseData.response?.statusCode {
                    switch(status){
                    case 200:
                        if let resData = JSON(responseData.result.value!).dictionaryObject {
                            if resData.count > 0 {
                                response.message = resData["message"] as? String
                                response.result = resData["result"] as? Bool
                            }
                        }
                    default:
                        if let resData = JSON(responseData.result.value!).dictionaryObject {
                            if resData.count > 0 {
                                response.message = resData["message"] as? String
                                response.result = false
                            }
                        }
                        print("error with response status: \(status)")
                    }
                }
                
                
            }
            completion(response)
        }
    }
    
}
