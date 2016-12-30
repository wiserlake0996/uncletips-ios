//
//  GoogleDirectionsApi.swift
//  uncletips
//
//  Created by Ibrahim Dawha on 6/8/16.
//  Copyright © 2016 wiserlake. All rights reserved.
//

import Foundation
import CoreLocation
//import SwiftyJSON


protocol GoogleDirectionsApiDelegate:class{
    func googleDirectionsApi(_ view:GoogleDirectionsApi, directionsRecieved directions:[Route])
}

open class GoogleDirectionsApi{
    
    let key:String = "&key=AIzaSyA0fEudI44LTmAytxk95aeAy_xtjYnWdPk"
    var base_url:String = "https://maps.googleapis.com/maps/api/directions/json?"
    
    var delegate:GoogleDirectionsApiDelegate?
    
    func calculateDirections(_ origin:String, destination:String, waypoints:String? ,options:String?, completionHandler:@escaping (_ data: [Route]) -> Void){
        
        var urlStr:String = "\(base_url)origin=\(origin)&destination=\(destination)&alternatives=true"
        
        if let opt = options{
            urlStr += "\(opt)"
        }
        
        if let way = waypoints{
            urlStr += "&waypoints=\(way)"
        }
        
        let requestURL: URL = URL(string:urlStr)!
        print(requestURL)
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            if (statusCode == 200) {
                do{
                    let json = data!
                    let parsed = self.parseDirectionsData(json as AnyObject)
                    completionHandler(parsed)
                    
                }catch {
                    print("Error with Json: \(error)")
                }
            }
        }) 
        task.resume()
    }
    
    func calculateTripDirectionsWithDelegate(_ origin:String, destination:String, waypoints:String? ,options:String?){
        
        calculateDirections(origin, destination: destination, waypoints: waypoints, options: options) {
            (data) in
            if self.delegate != nil{
                self.delegate?.googleDirectionsApi(self, directionsRecieved: data)
            }
        }
    }
    
    func parseDirectionsData(_ data:AnyObject) -> ([Route]){
        
        let travelData = JSON(data: (data as! NSData) as Data)
        let status = travelData["status"].stringValue
        var routes = [Route]()
        
        if status == "OK"{
            let routeData = travelData["routes"].arrayValue
            for r in routeData{
                routes.append(createRouteObject(r))
            }
        }
        return (routes)
    }
}

