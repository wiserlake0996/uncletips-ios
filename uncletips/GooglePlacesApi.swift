//
//  GooglePlacesApi.swift
//  uncletips
//
//  Created by Ibrahim Dawha on 5/31/16.
//  Copyright © 2016 wiserlake. All rights reserved.
//


//import SwiftyJSON
import GoogleMaps


protocol GooglePlacesApiDelegate:class{
    func placesApi(_ placeApi:GooglePlacesApi, placesSearchResult placeItems:[Place])
}

protocol PlacesSuggestionsDelegate:class{
    func placesSuggestions(_ places:GooglePlacesApi, forPlacesResult data:[Place], forTodoId todoId:Int)
}

class GooglePlacesApi{
    
    let baseUrl:String = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
    let key:String = "AIzaSyA0fEudI44LTmAytxk95aeAy_xtjYnWdPk"
    var delegate:GooglePlacesApiDelegate?
    var suggestionsDelegate:PlacesSuggestionsDelegate?
    
    func performNearbySearch(_ name:String, radius:Double, latitude:String, longitude:String, options:String?=nil, placeResultType:String?=nil, completionHandler:@escaping (_ items:[Place])->Void){
        
        var url:String = "\(baseUrl)location=\(latitude),\(longitude)&radius=\(radius)&name=\(name)&key=\(key)"//&rankby=distance"
        
        if let opt = options{
            url += "\(opt)"
        }
        
        let requestUrl:URL = URL(string: url)!
        print(requestUrl)
        
        let mutableRequestUrl:NSMutableURLRequest = NSMutableURLRequest(url:requestUrl)
        let session = URLSession.shared
        
        let task = session.dataTask(with: mutableRequestUrl as URLRequest, completionHandler: {(data,response,error) in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if statusCode == 200{
                let json = JSON(data: data!)
                completionHandler(self.parsePlaceDataFromResponse(json))
            }
        })
        task.resume()
    }
    
    
    func searchPlacesWithDelegate(_ name:String, radius:Double, latitude:String, longitude:String, options:String?=nil){
        
        self.performNearbySearch(name, radius: radius, latitude: latitude, longitude: longitude, options: options) {
            (items) in
            
            if self.delegate != nil{
                self.delegate?.placesApi(self, placesSearchResult: items)
            }
        }
    }
    
    
    func searchPlacesSuggestionWithDelegate(_ name:String, radius:Double, latitude:String, longitude:String, options:String?=nil, todoId:Int){
        
        self.performNearbySearch(name, radius: radius, latitude: latitude, longitude: longitude, options: options) {
            (items) in
            
            if self.suggestionsDelegate != nil{
                self.suggestionsDelegate?.placesSuggestions(self, forPlacesResult: items, forTodoId: todoId)
            }
        }
    }
    
    
    func parsePlaceDataFromResponse(_ data: JSON, placeResultType:String?=nil) -> [SearchPlace]{
        
        var placesArray = [SearchPlace]()
        let status = data["status"].stringValue
        
        if status == "OK"{
            let results = data["results"].arrayValue
            
            for result in results{
                let icon = result["icon"].stringValue
                let name = result["name"].stringValue
                let address = result["vicinity"].stringValue
                let placeID = result["place_id"].stringValue
                let types = result["types"].arrayValue.map { $0.string!}
                let lat = result["geometry"]["location"]["lat"].doubleValue
                let lng = result["geometry"]["location"]["lng"].doubleValue
                
                let pl:SearchPlace = SearchPlace(id: generateUniqueId(), name: name, address: address, lat: lat, lng:lng)
                
                if let ref = result["reference"].string{
                    pl.reference = ref
                }
                
                if let open = result["opening_hours"]["open_now"].bool{
                    pl.openStatus = open
                }
                
                if let rating = result["rating"].double{
                    pl.rating = rating
                }
                
                if let price = result["price_level"].int{
                    pl.priceLevel = price
                }
                
                pl.googlePlaceId = placeID
                pl.categoryTypes = types
                pl.icon = icon
                
                placesArray.append(pl)
            }
        }
        return placesArray
    }
}
