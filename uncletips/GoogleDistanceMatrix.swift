//
//  DistanceAPi.swift
//  TestGoogleAPi
//
//  Created by Ibrahim Dawha on 6/13/16.
//  Copyright © 2016 wiserlake. All rights reserved.
//

import Foundation
//import SwiftyJSON

protocol GoogleDistanceApiDelegate: class {
    func distanceApi(_ distanceApi: GoogleDistanceApi, distanceCalculationResponse data:[Journey])
}

protocol SuggestionsDistanceDelegate: class{
    func distanceApi(_ distanceApi: GoogleDistanceApi, todoSuggestionsDistance data:[Journey], todoId:Int)
}

class GoogleDistanceApi{
    
    let baseUrl:String = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial"
    let key:String = "AIzaSyA0fEudI44LTmAytxk95aeAy_xtjYnWdPk"
    var delegate:GoogleDistanceApiDelegate?
    var distanceSuggestDelegate:SuggestionsDistanceDelegate?
    
    func requestDististance(_ origin:String, destinations:String, options:String?=nil, completionHandler:@escaping (_ items:[Journey])->Void){
        
        var url:String = ""
        
        if let opt = options{
            url = "\(baseUrl)&origins=\(origin)&destinations=\(destinations)&key=\(key)\(opt)"
            
        }else{
            
            url = "\(baseUrl)&origins=\(origin)&destinations=\(destinations)&key=\(key)"
            
        }
        
        let requestUrl:URL = URL(string: url)!
        
        print(requestUrl)

        let mutableRequestUrl:NSMutableURLRequest = NSMutableURLRequest(url:requestUrl)
        let session = URLSession.shared
        
        let task = session.dataTask(with: mutableRequestUrl as URLRequest, completionHandler: {(data,response,error) in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if statusCode == 200{
                
                completionHandler(self.parsePlaceDataFromResponse(data! as AnyObject))
            }
        })
        task.resume()
    }
    
    
    func requestDistanceWithDelegate(_ origin:String, destinations:String, options:String?=nil){
        self.requestDististance(origin, destinations: destinations, options: options) {
            (items) in
            
            if self.delegate != nil{
                self.delegate?.distanceApi(self, distanceCalculationResponse: items)
            }
        }
    }
    
    func requestSuggestionsDistanceWithDelegate(_ origin:String, destinations:String, options:String?=nil, todoId:Int){
        self.requestDististance(origin, destinations: destinations, options: options) {
            (items) in
            
            if self.distanceSuggestDelegate != nil{
                self.distanceSuggestDelegate?.distanceApi(self, todoSuggestionsDistance: items, todoId: todoId)
            }
        }
    }
    
    
    func parsePlaceDataFromResponse(_ data: AnyObject) -> [Journey]{
        
        var journeyArray = [Journey]()
        var dataObject = JSON(data: (data as! NSData) as Data)
        
        let status = dataObject["status"].stringValue
        
        if status == "OK"{
            
            let rows = dataObject["rows"].arrayValue
            
            for row in rows{
                let elements = row["elements"].arrayValue
                
                for results in elements{
                    
                    if results["status"].stringValue == "OK"{
                        let distance = results["distance"]["text"].string
                        let duration = results["duration"]["text"].string
                        let traffic = results["duration_in_traffic"].dictionary
                        
                        if distance != nil && duration != nil{
                            
                            var jy = Journey(id: generateUniqueId(), distance: distance!, duration: duration!)
                            if traffic != nil {
                                
                                if let text = traffic!["text"]!.string{
                                    jy.traffic = text
                                }
                            }
                            journeyArray.append(jy)
                        }
                    }else{
                        journeyArray.append(Journey())
                    }
                }
            }
        }
        return journeyArray
        
    }
    
}

