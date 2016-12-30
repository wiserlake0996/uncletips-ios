//
//  LeGuageResultViewController.swift
//  uncletips
//
//  Created by Ibrahim Dawha on 6/10/16.
//  Copyright © 2016 wiserlake. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class LeGuageResultViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, GoogleDirectionsApiDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var mapView: GMSMapView!
    
    let locationManager = CLLocationManager()
    var gta:GoogleDirectionsApi = GoogleDirectionsApi()
    var currentLocation = CLLocationCoordinate2DMake(40.852285, -73.964989)
    
    var destinationTodo:Todo?
    var destinationPlace:Place?
    
    var originTodo:Todo?
    var originPlace:Place?
    
    var waypointTodos:[Todo]?
    var waypointPlaces:[Place]?
    
    var travelOptions:[String:String]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.mapView.camera = GMSCameraPosition(target: currentLocation, zoom: 15, bearing: 0, viewingAngle: 0)
        
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        
        mapView.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if let or = originPlace{
            currentLocation = CLLocationCoordinate2DMake(or.lat, or.lng)
        }
        
        gta.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sendGuageRequest("\(currentLocation.latitude),\(currentLocation.longitude)")

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    
    func googleDirectionsApi(_ view: GoogleDirectionsApi, directionsRecieved directions: [Route]) {
        
        DispatchQueue.main.async { [unowned self] in
            
            //print ("polyline: ", directions[0].overview_polyline)
            if directions.count > 0{
                self.displayResult(directions[0].legs, polyline: directions[0].overviewPolyline, waypointOrder: directions[0].waypointOrder)
            }else{
                showSimpleAlertWithTitle("no results", message: "no result", viewController: self)
            }
        }
    
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        locationManager.startUpdatingLocation()
        
        self.mapView.isMyLocationEnabled = true
        self.mapView.settings.myLocationButton = true
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 13, bearing: 0, viewingAngle: 0)
            self.currentLocation = location.coordinate
            locationManager.stopUpdatingLocation()
            
        }
    }
    
    func sendGuageRequest(_ loc:String){
        
        var optionString:String?
        
        if let opt = travelOptions{
            optionString = urlEncodeOptions(opt)
        }
        
        let origin = "\(currentLocation.latitude),\(currentLocation.longitude)"
        
        if let dest = destinationPlace{
            let destination = "\(dest.lat),\(dest.lng)"
            if let wp = waypointPlaces{
                
                if wp.count > 0{
                    let wayp = placesToWaypointString(wp)

                    gta.calculateTripDirectionsWithDelegate(origin, destination: destination, waypoints: wayp.stringByAddingPercentEncodingForURLQueryParameter() , options: optionString)
                }else{
                    gta.calculateTripDirectionsWithDelegate(origin, destination: destination, waypoints:nil, options: optionString)
                }

            }else{
                gta.calculateTripDirectionsWithDelegate(origin, destination: destination, waypoints:nil, options: optionString)
            }
        }else{
            showSimpleAlertWithTitle("Destination missing", message: "Enter destination", viewController: self)
        }
 
    }
    
    func displayResult(_ legs:[Leg], polyline:String, waypointOrder:[Int]?){
        
        if legs.count > 0{
        
            for leg in legs{
                createMapObject(leg: leg)
            }

            drawRoute(polyline)
            displayTripText(legs, displayOrder: waypointOrder)
            createDestinationMapObject()
        }
    }
    
    func createMapObject(_ waypointOrder:Int?=nil,leg: Leg){
        

        let marker = GMSMarker(position: CLLocationCoordinate2DMake(leg.startLocation["lat"]!, leg.startLocation["lng"]!))
        
            marker.title = "\(leg.startAddress)"
            marker.snippet = "heading to - \(leg.endAddress)"
            
            marker.map = mapView
       
    }
    
    func createDestinationMapObject(){
        let marker = GMSMarker(position: CLLocationCoordinate2DMake(destinationPlace!.lat, destinationPlace!.lng))
        
        marker.title = "\(destinationPlace!.name)"
        marker.snippet = "\(destinationPlace!.address)"
        marker.icon = GMSMarker.markerImage(with: UIColor.green)

        
        marker.map = mapView
        
    }
    
    func drawRoute(_ polyline:String){
        let path = GMSMutablePath(fromEncodedPath: polyline)
        let line = GMSPolyline(path: path)
        line.strokeWidth = 3
        line.strokeColor = UIColor.darkGray
        line.map = mapView
    }
    
    func displayTripText(_ legs: [Leg], displayOrder:[Int]?){
        
        var text = "Trip Details\n _____________________ \n\n"
        
        var totalDuration:Int = 0
        var totalDistance:Double = 0.0

            for (i,leg) in legs.enumerated(){
                text += "Trip \(i+1) starts\n"
                
                if let way  = waypointTodos{
                    if way.count > 0{
                        if i < way.count{
                            text += "Todo name: \(waypointTodos![i].name)\n"
                        }
                    }
                }
                
                if waypointTodos?.count == i{
                    text += "Todo name: \(destinationTodo!.name)\n"
                 }
 
 
                text += "start Address: \(leg.startAddress)\n"
                text += "end address: \(leg.endAddress)\n"
                
                if let traDur = leg.durationInTraffic{
                    text += "traffic: \(traDur)\n"
                }
                
                if let depart = leg.departureTime{
                    text += "depart at: \(depart)\n"
                }
                
                if let arrive = leg.arrivalTime{
                    text += "arrive at: \(arrive)\n"
                }
                
                text += "distance: \(leg.distance)\n"
                text += "duration: \(leg.duration)\n"
                text += "Trip \(i+1) ends\n\n\n"

                let dur = leg.duration.components(separatedBy: " ")
                let val:Int = Int(dur[0])!
                totalDuration = val + totalDuration
                
                let dis = leg.distance.components(separatedBy: " ")
                
                totalDistance += Double(dis[0])!
                
                let steps = leg.steps
                var text2 = ""
                for step in steps{
                    text2 += "\(step.travelMode) - "
                }
                text += "summary: \(text2)\n"
                

            }
        
        text += "Total distance: \(totalDistance) mi\n"
        text += "Total duration: \(totalDuration) mins\n"
        
        
  
        textView.text = text
    }
    
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}
