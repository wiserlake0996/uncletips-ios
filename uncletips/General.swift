//
//  General.swift
//  uncletips
//
//  Created by Ibrahim Dawha on 5/30/16.
//  Copyright © 2016 wiserlake. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import SwiftyJSON


extension Array {
    mutating func removeObject<U: Equatable>(_ object: U) -> Bool {
        for (idx, objectToCompare) in self.enumerated() {  //in old swift use enumerate(self)
            if let to = objectToCompare as? U {
                if object == to {
                    self.remove(at: idx)
                    return true
                }
            }
        }
        return false
    }
}

extension String {
    
    /// Returns a new string made from the `String` by replacing all characters not in the unreserved
    /// character set (As defined by RFC3986) with percent encoded characters.
    
    func stringByAddingPercentEncodingForURLQueryParameter() -> String? {
        let allowedCharacters = CharacterSet.URLQueryParameterAllowedCharacterSet()
        return addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
    
}

extension CharacterSet {
    
    /// Returns the character set for characters allowed in the individual parameters within a query URL component.
    ///
    /// The query component of a URL is the component immediately following a question mark (?).
    /// For example, in the URL `http://www.example.com/index.php?key1=value1#jumpLink`, the query
    /// component is `key1=value1`. The individual parameters of that query would be the key `key1`
    /// and its associated value `value1`.
    ///
    /// According to RFC 3986, the set of unreserved characters includes
    ///
    /// `ALPHA / DIGIT / "-" / "." / "_" / "~"`
    ///
    /// In section 3.4 of the RFC, it further recommends adding `/` and `?` to the list of unescaped characters
    /// for the sake of compatibility with some erroneous implementations, so this routine also allows those
    /// to pass unescaped.
    
    
    static func URLQueryParameterAllowedCharacterSet() -> CharacterSet {
        return self.init(charactersIn:"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~/?")
    }
    
}


func generateUniqueId() -> String{
    let uuid = UUID().uuidString
    return uuid
}


func generateRandomInt(min: Int, max: Int) -> Int {
    if max < min { return min }
    return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
}


func showSimpleAlertWithTitle(_ title: String!, message: String, viewController: UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alert.addAction(action)
    viewController.present(alert, animated: true, completion: nil)
}

func saveObjectMake(_ todo: Todo, place:Place) -> Dictionary<String,AnyObject>{
    
    var toPost = [String:AnyObject]()
    
    toPost["id"] = todo.id as AnyObject?
    toPost["name"] = todo.name as AnyObject?
    
    var settings = [String:AnyObject]()
    
    if todo.settings.locationEntry != nil{
        settings["on_entry"] = true as AnyObject?
    }
    
    if todo.settings.locationExit != nil{
        settings["on_exit"] = true as AnyObject?
    }
    
    settings["radius"] = todo.settings.radius as AnyObject?
    
    if todo.settings.notificationEmail != nil{
        settings["notification_email"] = todo.settings.notificationEmail as AnyObject?
    }
    
    if todo.settings.suggestions != nil{
        settings["suggestions"] = true as AnyObject?
    }
    
    if todo.settings.fixedTime != nil{
        
        let yourDate: Date = todo.settings.fixedTime! as Date
        //now in this example
        let epochTimestamp: TimeInterval = yourDate.timeIntervalSince1970
        let epochTimestampString: String = epochTimestamp.description
        settings["fixed_time"] = epochTimestampString as AnyObject?
    }
    
    if todo.settings.randomTime != nil{
        
        settings["random_time"] = todo.settings.randomTime?.description as AnyObject?
    }
    
    if todo.settings.timeAllocation != nil{
        settings["time_allocation"] = todo.settings.timeAllocation as AnyObject?
    }
    
    
    var placeData = [String:AnyObject]()
    
    placeData["name"] = place.name as AnyObject?
    placeData["id"] = place.id as AnyObject?
    placeData["address"] = place.address as AnyObject?
    placeData["lat"] = place.lat as AnyObject?
    placeData["lng"] = place.lng as AnyObject?
    placeData["type"] = place.type() as AnyObject?
    
    if place.typeID != nil{
        placeData["type_id"] = place.typeID as AnyObject?
    }
    
    if let open = place.openStatus{
        placeData["open_status"] = open as AnyObject?
    }
    
    if let price = place.priceLevel{
        placeData["price_level"] = price as AnyObject?
    }
    
    if let rating = place.rating{
        placeData["rating"] = rating as AnyObject?
    }
    
    if let ref = place.reference{
        placeData["reference"] = ref as AnyObject?
    }
    
    if let placeId = place.googlePlaceId{
        placeData["google_place_id"] = placeId as AnyObject?
    }
    
    if let types = place.categoryTypes{
        placeData["category_types"] = types as AnyObject?

    }
    
    if let icon = place.icon{
        placeData["icon"] = icon as AnyObject?

    }
    
    toPost["place"] = placeData as AnyObject?
    toPost["settings"] = settings as AnyObject?
    
    return toPost
    
}


func dictToObjects(_ settings: [String:AnyObject], place:[String:AnyObject]) -> (TodoSettings, TodoPlace){
    
    
    var setOBj = TodoSettings()
    
    let plOBj = TodoPlace(id: place["id"] as! String, name: place["name"] as! String, address: place["address"] as! String, lat: place["lat"] as! Double, lng: place["lng"] as! Double)
    plOBj.typeID = (place["type_id"] as! String)
    
    
    if let entry = settings["on_entry"]{
        setOBj.locationEntry = entry as? Bool
    }
    
    if let exit = settings["on_exit"]{
        setOBj.locationExit = exit as? Bool
    }
    
    if let radius = settings["radius"]{
        setOBj.radius = radius as! Double
    }
    
    if let email = settings["notification_email"]{
        setOBj.notificationEmail = email as? String
    }
    
    if let fixed = settings["fixed_time"]{
        setOBj.fixedTime = Date(timeIntervalSince1970: Double(fixed as! String)!)
    }
    
    if let random = settings["random_time"]{
        setOBj.randomTime = TimeInterval(Double(random as! String)!)
    }
    
    if let suggest = settings["suggestions"]{
        setOBj.suggestions = suggest as? Bool
    }
    
    if let timeAllocation = settings["time_allocation"]{
        setOBj.timeAllocation = timeAllocation as? Double
    }
    
    if let icon = place["icon"]{
        plOBj.icon = icon as? String
    }
    
    if let ref = place["reference"]{
        plOBj.reference = ref as? String
    }
    
    if let open = place["open_status"]{
        plOBj.openStatus = open as? Bool
    }
    
    if let rating = place["rating"]{
        plOBj.rating = rating as? Double
    }
    
    if let price = place["price_level"]{
        plOBj.priceLevel = price as? Int
    }
    
    if let placeid = place["google_place_id"]{
        plOBj.googlePlaceId = placeid as? String
    }
    
    if let categ = place["category_types"]{
        plOBj.categoryTypes = categ as? [String]
    }
    
    
    return (setOBj, plOBj)
}

func urlEncodeOptions(_ options:[String:String]) -> String{
    
    var text:String = ""
    
    for (k,v) in options{
        text += "&\(k)=\(v)"
    }
    return text
}

func placesToWaypointString(_ places: [Place]) -> String{
    
    var waypoints:String = ""
    
    for (i,j) in places.enumerated(){
        if i > 0{
            waypoints += "|\(j.lat),\(j.lng)"
        }else{
            waypoints += "\(j.lat),\(j.lng)"
        }
    }
    
    return waypoints
}

func createLegObject(_ data:JSON) -> Leg
{
    var departureTime:String?
    var arrivalTime:String?
    var durationInTraffic:String?
    
    departureTime = data["departure_time"]["text"].string
    arrivalTime = data["arrival_time"]["text"].string
    durationInTraffic = data["duration_in_traffic"]["text"].string
    
    let id:String = generateUniqueId()
    let startAddress:String = data["start_address"].stringValue
    let endAddress:String = data["end_address"].stringValue
    let distance:String = data["distance"]["text"].stringValue
    let duration:String = data["duration"]["text"].stringValue
    
    let startLat = data["start_location"]["lat"].doubleValue
    let startLng = data["start_location"]["lng"].doubleValue
    let startLocation:[String:Double] = ["lat":startLat, "lng":startLng]
    
    let endLat = data["end_location"]["lat"].doubleValue
    let endLng = data["end_location"]["lng"].doubleValue
    let endLocation:[String:Double] = ["lat":endLat, "lng":endLng]
    
    var steps = [Step]()
    
    for step in data["steps"].arrayValue{
        steps.append(createStepObject(step))
    }
    
    let durationValue:Int = data["duration"]["value"].intValue
    
    
    let leg = Leg(id: id, startAddress: startAddress, endAddress: endAddress, distance: distance, duration: duration, durationValue: durationValue, startLocation: startLocation, endLocation: endLocation, steps: steps, arrivalTime: arrivalTime, departureTime: departureTime, durationInTraffic: durationInTraffic)
    
    
    
    return leg
}

func createTransitObject(_ data:JSON) -> Transit{
    var transit:Transit
    
    let id:String = generateUniqueId()
    let arrivalStopName:String = data["arrival_stop"]["name"].stringValue
    let arrivalStopLocation:[String:Double] = ["lat":data["arrival_stop"]["location"]["lat"].doubleValue, "lng":data["arrival_stop"]["location"]["lng"].doubleValue]
    let arrivalTime:String = data["arrival_time"]["text"].stringValue
    let departureStopName:String = data["departure_stop"]["name"].stringValue
    let departureStopLocation:[String:Double] = ["lat":data["departure_stop"]["location"]["lat"].doubleValue, "lng":data["departure_stop"]["location"]["lng"].doubleValue]
    let departureTime:String = data["departure_time"]["text"].stringValue
    let headsign:String = data["headsign"].stringValue
    let numOfStops:Int = data["num_of_stops"].intValue
    let line:TransitLine = createTransitLineObject(data["line"])
    
    transit = Transit(id: id, arrivalStopName: arrivalStopName, arrivalStopLocation: arrivalStopLocation, arrivalTime: arrivalTime, departureStopName: departureStopName, departureStopLocation: departureStopLocation, departureTime: departureTime, headsign: headsign, numOfStops: numOfStops, line: line)
    
    return transit
}

func createTransitLineObject(_ data:JSON) -> TransitLine{
    var transitLine:TransitLine
    
    let name = data["name"].string
    let shortName = data["short_name"].string
    let color = data["color"].string
    let url = data["url"].string
    let icon = data["icon"].string
    let textColor = data["text_color"].string
    var agencies = [[String:String]]()
    var vehicle = [String:String]()
    
    let tempagencies = data["agencies"].arrayValue
    
    for agency in tempagencies{
        //get dict values
        var temp = agency.dictionaryValue
        let keys = Array(temp.keys)
        
        var tempDict = [String:String]()
        
        // add data to agencies
        
        for k in keys{
            tempDict[k] = temp[k]?.stringValue
        }
        
        agencies.append(tempDict)
    }
    
    let tempvehicle = data["vehicle"].dictionaryValue
    let keys = Array(tempvehicle.keys)
    
    for k in keys{
        vehicle[k] = tempvehicle[k]?.stringValue
    }
    
    transitLine = TransitLine(name: name, shortName: shortName, color: color, agencies: agencies, url: url, icon: icon, textColor: textColor, vehicle: vehicle)
    
    return transitLine
}


func createStepObject(_ data:JSON) -> Step{
    var step:Step
    
    let id:String = generateUniqueId()
    let distance:String = data["distance"]["text"].stringValue
    let duration:String = data["duration"]["text"].stringValue
    let startLocation:[String:Double] = ["lat":data["start_location"]["lat"].doubleValue, "lng":data["start_location"]["lng"].doubleValue]
    let endLocation:[String:Double] = ["lat":data["end_location"]["lat"].doubleValue, "lng":data["end_location"]["lng"].doubleValue]
    let htmlInstruction:String = data["html_instructions"].stringValue
    let polyline:String = data["polyline"]["points"].stringValue
    let travelMode:String = data["travel_mode"].stringValue
    var subStep:[SubStep]?
    var transitDetails:Transit?
    
    
    if travelMode == "TRANSIT"{
        transitDetails = createTransitObject(data["transit_details"])
    }
    
    if travelMode == "WALKING"{
        
        let temp = data["steps"].arrayValue
        var stepss = [SubStep]()
        for st in temp{
            stepss.append(createSubStepObject(st))
        }
        subStep = stepss
    }
    
    step = Step(id: id, distance: distance, duration: duration, startLocation: startLocation, endLocation: endLocation, htmlInstruction: htmlInstruction, polyline: polyline, travelMode: travelMode, transitDetails: transitDetails, subStep: subStep)
    
    return step
}

func createSubStepObject(_ data:JSON) -> SubStep{
    var step:SubStep
    
    let distance:String = data["distance"]["text"].stringValue
    let duration:String = data["duration"]["text"].stringValue
    let startLocation:[String:Double] = ["lat":data["start_location"]["lat"].doubleValue, "lng":data["start_location"]["lng"].doubleValue]
    let endLocation:[String:Double] = ["lat":data["end_location"]["lat"].doubleValue, "lng":data["end_location"]["lng"].doubleValue]
    let polyline:String = data["polyline"]["points"].stringValue
    let travelMode:String = data["travel_mode"].stringValue
    
    step = SubStep(id: generateUniqueId(), distance: distance, duration: duration, startLocation: startLocation, endLocation: endLocation, polyline: polyline, travelMode: travelMode)
    
    return step
}



func createRouteObject(_ data:JSON) -> Route{
    var route:Route!
    var legs = [Leg]()
    
    let legData = data["legs"].arrayValue
    let boundsNE = ["lat":data["bounds"]["northeast"]["lat"].doubleValue, "lng":data["bounds"]["northeast"]["lng"].doubleValue]
    let boundsSW = ["lat":data["bounds"]["southwest"]["lat"].doubleValue, "lng":data["bounds"]["southwest"]["lng"].doubleValue]
    let summary = data["summary"].stringValue
    let overviewPoly = data["overview_polyline"]["points"].stringValue
    
    for l in legData{
        legs.append(createLegObject(l))
    }
    
    route = Route(id: generateUniqueId(), summary:summary, overviewPolyline:overviewPoly, boundsNorthEast:boundsNE, boundsSouthWest:boundsSW, legs:legs)
    
    if let wayOrder = data["waypoint_order"].array{
        if wayOrder.count > 0{
            route.waypointOrder = [Int]()
            for r in wayOrder{
                route.waypointOrder?.append(r.intValue)
            }
        }
    }
    
    return route
}


func createTripSummary(_ route:Route) -> TripSummary{
    var tripSumm:TripSummary?
    var distance:Double = 0.0
    var duration:Int = 0
    
    for leg in route.legs{
        let dur = leg.duration.components(separatedBy: " ")
        
        if dur.count > 2{
            duration += leg.durationValue / 60
        }else{
            duration += Int(dur[0])!
        }
        let dis = leg.distance.components(separatedBy: " ")
        distance += Double(dis[0])!
        
    }
    
    tripSumm = TripSummary(totalDistance: distance, totalDuration: duration)
    return tripSumm!
    
}


func createRouteSummary(_ route:Route) -> RouteSummary{
    var routeSumm:RouteSummary
    
    var distance:Double = 0.0
    var duration:Int = 0
    
    for leg in route.legs{
        let dur = leg.duration.components(separatedBy: " ")
        
        if dur.count > 2{
            duration += leg.durationValue / 60
        }else{
            duration += Int(dur[0])!
        }
        let dis = leg.distance.components(separatedBy: " ")
        distance += Double(dis[0])!
        
        /*
        var steps = leg.steps
        
        for step in steps{
            
            if step.travelMode == "TRANSIT"{
                travelModes += (step.transitDetails?.line.vehicle["type"])! + " "+step.duration + " > "
            }
        }
 
 */
        
    }
    
    routeSumm = RouteSummary(totalDuration: duration, totalDistance: distance)//, travelModeSummary: travelModes)
    
    return routeSumm
    
}



func createLegDisplayData(_ leg:Leg) -> LegDisplayData{
    var tripData:LegDisplayData
    var temp = [Transit]()
    
    let startAddress:String = leg.startAddress
    let endAddress:String = leg.endAddress
    let distance:String = leg.distance
    let duration:String = leg.duration
    var transitData:[Transit]?
    let startLocation = leg.startLocation
    let endLocation = leg.endLocation

    for step in leg.steps{
        if step.travelMode == "TRANSIT"{
            temp.append(step.transitDetails!)
        }
    }
    
    if temp.count > 0{
        transitData = temp
    }
    
    let arrivalTime:String? = leg.arrivalTime
    let departureTime:String? = leg.departureTime
    let durationInTraffic:String? = leg.durationInTraffic
    
    var travelSummary = ""
    
    for step in leg.steps{
        
        travelSummary += step.travelMode + " "+step.duration + " > "
        
    }
    
    tripData = LegDisplayData(startAddress: startAddress, endAddress: endAddress, distance: distance, duration: duration, transitDetails: transitData, arrivalTime: arrivalTime, departureTime: departureTime, durationInTraffic: durationInTraffic, travelSummary: travelSummary, startLocation: startLocation, endLocation: endLocation)
    return tripData
}



func createTrips(_ route:Route) -> [Trip]{
    var trips = [Trip]()
    let legs = route.legs
    
    for (i,leg) in legs.enumerated(){
        let startLocation = leg.startLocation
        let endLocation = leg.endLocation
        
        trips.append(Trip(number: i, fromAddress: leg.startAddress, toAddress: leg.endAddress, todo: "todos \(i)", distance: leg.distance, duration: leg.duration, startLocation: startLocation, endLocation: endLocation))
    }
    return trips
}

