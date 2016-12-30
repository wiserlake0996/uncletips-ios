//
//  Place.swift
//  uncletips
//
//  Created by Ibrahim Dawha on 5/25/16.
//  Copyright © 2016 wiserlake. All rights reserved.
//

import Foundation


open class Place{
    
    var id:String
    var name:String
    var address: String
    var lat:Double
    var lng: Double
    var photos:[AnyObject]?
    var openStatus:Bool?
    var openingHours:[String]?
    var googlePlaceId:String?
    var priceLevel:Int?
    var rating:Double?
    var reference:String?
    var categoryTypes:[String]?
    var icon:String?
    var typeID: String?
    
    init(id:String, name:String, address:String, lat:Double, lng:Double, typeID:String?=nil)
    {
        self.id = id
        self.name = name
        self.address = address
        self.lat = lat
        self.lng = lng
        self.typeID = typeID
    }
    
    func type() -> String{
        return "place"
    }
    
}

class TodoPlace:Place{
    
    override func type() -> String {
        return "todo"
    }
    
    func formattedForInfoWinfow(){
        
    }
    
}

class SearchPlace:Place{
    
    override func type() -> String {
        return "search"
    }
    
    func formattedForInfoWinfow(){
        
    }
    
}


struct Journey{
    var id:String?
    var distance:String?
    var duration:String?
    var traffic:String?
    
    init(){
        id = "ds"
        distance = "none"
        duration = "none"
    }
    
    init(id:String, distance:String, duration:String)
    {
        self.id = id
        self.distance = distance
        self.duration = duration
    }
    
    func formattedJourney() -> String{
        
        if traffic != nil{
            return "\(distance!), \(duration!), delay: \(timeInTraffic())"
        }
        return "\(distance!), \(duration!) away"
        
    }
    
    func timeInTraffic() -> String{
        if let tra = traffic{
            let dur = Int(duration!.components(separatedBy: " ")[0])
            let del = Int(tra.components(separatedBy: " ")[0])
            return "\(del! - dur!) mins"
            
        }
        return "0 mins"
    }
}

public struct Leg{
    var id:String
    var startAddress:String
    var endAddress:String
    var distance:String
    var duration:String
    var durationValue:Int
    var startLocation:[String:Double]
    var endLocation:[String:Double]
    var steps:[Step]
    var arrivalTime:String?
    var departureTime:String?
    var durationInTraffic:String?
    
}

public struct Route{
    
    var id:String
    var summary:String
    var waypointOrder:[Int]?
    var overviewPolyline:String
    var boundsNorthEast:[String:Double]
    var boundsSouthWest:[String:Double]
    var warnings:[String]?
    var legs:[Leg]
    
    public init(id:String, summary:String, overviewPolyline:String, boundsNorthEast:[String:Double], boundsSouthWest:[String:Double], legs:[Leg]){
        self.id = id
        self.summary = summary
        self.overviewPolyline = overviewPolyline
        self.boundsNorthEast = boundsNorthEast
        self.boundsSouthWest = boundsSouthWest
        self.legs = legs
    }
    
}

public struct Step{
    var id:String
    var distance:String
    var duration:String
    var startLocation:[String:Double]
    var endLocation:[String:Double]
    var htmlInstruction:String
    var polyline:String
    var travelMode:String
    var transitDetails:Transit?
    var subStep:[SubStep]?
}

public struct SubStep{
    var id:String
    var distance:String
    var duration:String
    var startLocation:[String:Double]
    var endLocation:[String:Double]
    var polyline:String
    var travelMode:String
}

public struct Transit{
    var id:String
    var arrivalStopName:String
    var arrivalStopLocation:[String:Double]
    var arrivalTime:String
    var departureStopName:String
    var departureStopLocation:[String:Double]
    var departureTime:String
    var headsign:String
    var numOfStops:Int
    var line:TransitLine

}

public struct TransitLine{
    var name:String?
    var shortName:String?
    var color:String?
    var agencies:[[String:String]]
    var url:String?
    var icon:String?
    var textColor:String?
    var vehicle:[String:String]
}



public struct DirectionsResponse{
    var status:String
    var geocodedWaypoints:[AnyObject]
    var routes:[Route]
    var availableTravelModes:[String]? = nil
    
}

public struct Trip{ //TripDisplay
    var number:Int
    var fromAddress:String
    var toAddress:String
    var todo:String
    var distance:String
    var duration:String
    var startLocation:[String:Double]
    var endLocation:[String:Double]
    
}

public struct TripSummary{
    var totalDistance:Double
    var totalDuration:Int
}


public struct RouteSummary{
    var totalDuration:Int
    var totalDistance:Double
   // var transitSummary:String
}

public struct LegDisplayData{
    var startAddress:String
    var endAddress:String
    var distance:String
    var duration:String
    var transitDetails:[Transit]?
    var arrivalTime:String?
    var departureTime:String?
    var durationInTraffic:String?
    var travelSummary:String?
    var startLocation:[String:Double]
    var endLocation:[String:Double]
    
}
