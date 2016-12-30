//
//  LeGuageResultController.swift
//  uncletips
//
//  Created by Ibrahim Dawha on 6/20/16.
//  Copyright © 2016 wiserlake. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class LeGuageResultController: UIViewController, UITableViewDelegate, UITableViewDataSource , GMSMapViewDelegate, CLLocationManagerDelegate, GoogleDirectionsApiDelegate{

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var routeStepper: UIStepper!
    
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
    
    var routeSummary:RouteSummary?
    var legDisplayData = [LegDisplayData]()
    
    var calculatedRoutes:[Route]?
    
    
    var mapMarkers = [GMSMarker]()
    var mapPolyline = GMSPolyline()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        routeStepper.wraps = true
        routeStepper.maximumValue = 3
        routeStepper.minimumValue = 0
        routeStepper.stepValue = 1
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        gta.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if let or = originPlace{
            currentLocation = CLLocationCoordinate2DMake(or.lat, or.lng)
        }
        
        
       // tableView.estimatedRowHeight = 112
        //tableView.rowHeight = UITableViewAutomaticDimension
        
        // Do any additional setup after loading the view.
        self.edgesForExtendedLayout = UIRectEdge()
        self.mapView.camera = GMSCameraPosition(target: currentLocation, zoom: 10, bearing: 0, viewingAngle: 0)
        


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        makeDirectionsRequest()
        
        
    }
    @IBAction func routeStepperValueChanged(_ sender: AnyObject) {
        
        if Int(routeStepper.value) < calculatedRoutes!.count{
            clearMapObjects()
            clearTableData()
            displayRouteData(Int(routeStepper.value))
        }
    }

    //MARK: Table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1{
            return (legDisplayData.count)
        }
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1{
            return 300
        }
        return 112
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "travelSummaryCell", for: indexPath) as! TravelSummaryTableViewCell
           
            if let summ = routeSummary{
                
                cell.distanceLabel.text = "\(summ.totalDistance) miles"
                
                if summ.totalDuration > 60{
                    let hr = summ.totalDuration/60
                    let mins = summ.totalDuration%60
                    cell.durationLabel.text = "\(hr)hr \(mins)min(s)"
                    cell.durationLabel.textColor = UIColor.red
                }else{
                    cell.durationLabel.text = "\(summ.totalDuration) mins"
                    cell.durationLabel.textColor = UIColor.green
                }
                
                if let mode = self.travelOptions{
                    cell.travelModesLabel.text = "\(mode["mode"]!)"
                }else{
                    cell.travelModesLabel.text = "driving"
                }
                
                if getTotalAllocatedTime() > 60{
                    let hr = getTotalAllocatedTime()/60
                    let mins = getTotalAllocatedTime()%60
                    cell.totalTimeAllocatedLabel.text = "\(hr)hr \(mins)min(s)"
                }else{
                    cell.totalTimeAllocatedLabel.text = "\(getTotalAllocatedTime()) mins"
                }
                
            }else{
                cell.distanceLabel.text = "no summary data"
                cell.durationLabel.text = "do durations data"
                cell.travelModesLabel.text = "no mode data"
            }
            
            return cell
        }
        
        if indexPath.section == 1{
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "travelDetailsCell", for: indexPath) as! TravelDetailsTableViewCell
        
            if legDisplayData.count - 1 == indexPath.row {
     
                var travelText = ""
                
                cell.fromLabel.text = legDisplayData[indexPath.row].startAddress
                cell.toLabel.text = legDisplayData[indexPath.row].endAddress
                cell.todoLabel.text = "TODO: \(destinationTodo!.name)"
                travelText = "dist: \(legDisplayData[indexPath.row].distance) \t \t dur: \(legDisplayData[indexPath.row].duration)"
                cell.distanceLabel.text = travelText
                
                if let t = legDisplayData[indexPath.row].transitDetails{
                    let ans  = formattedTransitInfo(t)
                    cell.transitDetails.text = ans
                }else{
                    cell.transitDetails.text = "no additional data"

                }
                
                if let alloc = destinationTodo?.settings.timeAllocation{
                    let todoText = cell.todoLabel.text!
                    if alloc > 60{
                        let hr = alloc/60
                        let mins = alloc.truncatingRemainder(dividingBy: 60)
                        
                        cell.todoLabel.text = todoText + "(\(Int(hr))hr \(Int(mins))min(s))"
                    }else{
                        cell.todoLabel.text = todoText + "(\(Int(alloc))min(s))"
                    }
                }
                
            }else{
                var travelText = ""
                
                cell.fromLabel.text = legDisplayData[indexPath.row].startAddress
                cell.toLabel.text = legDisplayData[indexPath.row].endAddress
                cell.todoLabel.text = "TODO: \(waypointTodos![indexPath.row].name)"
                travelText = "dist: \(legDisplayData[indexPath.row].distance) \t \t dur: \(legDisplayData[indexPath.row].duration)"
                cell.distanceLabel.text = travelText

                if let t = legDisplayData[indexPath.row].transitDetails{
                    let ans  = self.formattedTransitInfo(t)
                    cell.transitDetails.text = ans
                }
                
                if let alloc = waypointTodos![indexPath.row].settings.timeAllocation{
                    let todoText = cell.todoLabel.text!

                    if alloc > 60{
                        let hr = alloc/60
                        let mins = alloc.truncatingRemainder(dividingBy: 60)
                        cell.todoLabel.text = todoText + "(\(Int(hr))hr \(Int(mins))min(s))"
                    }else{
                        cell.todoLabel.text = todoText + "(\(Int(alloc)) mins)"
                    }
                }
            }
            return cell
        }
        
        let cell = UITableViewCell()
        return cell

    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Trip Summary"
        }
        return "Trip Details"
    }
    
    
    //MARK: location manager 
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
    
    
    //MARK: Directions delegate
    
    func googleDirectionsApi(_ view:GoogleDirectionsApi, directionsRecieved directions:[Route])
    {
        calculatedRoutes = directions
        
        print ("total routes \(directions.count)")
        
        routeStepper.maximumValue = Double(directions.count)
        
        if directions.count > 0{

            self.displayRouteData(0)
            self.routeStepper.isEnabled = true
            
        }

    }
    
    
    //MARK: Methods
    
    func displayRouteData(_ routeNumber:Int){
        
        DispatchQueue.main.async(execute: {
            
            if let routeData = self.calculatedRoutes{
                self.detailsLabel.text = "Route number: \(routeNumber + 1)"
                if routeNumber < routeData.count{
                    self.routeSummary = createRouteSummary(routeData[routeNumber])
                    var allDisplayData = [LegDisplayData]()
                    
                    for leg in routeData[routeNumber].legs{
                        allDisplayData.append(createLegDisplayData(leg))
                    }
                
                    for (_,v) in allDisplayData.enumerated(){
                        let newIndexPath = IndexPath(row: self.legDisplayData.count, section: 1)
                        self.legDisplayData.append(v)
                        self.tableView.insertRows(at: [newIndexPath], with: .bottom)
                    }
                    self.loadDataToMap()
                    self.drawRoute(routeData[routeNumber].overviewPolyline)
                
                    self.tableView.reloadData()
                }else{
                    NotificationsManager.sharedInstance.showSimpleAlertWithTitle("error", message: "invalid route number", viewController: self)
                }
            
            }else{
                NotificationsManager.sharedInstance.showSimpleAlertWithTitle("no routes", message: "try adjusting the options or locations", viewController: self)
            }
        })
        
    }
    
    func makeDirectionsRequest(){
        var origin:String = ""
        var destination:String = ""
        var waypoints:String? = nil
        var options:String? = nil
        
        if originPlace != nil && destinationPlace != nil{
            origin = "\(originPlace!.lat),\(originPlace!.lng)"
            destination = "\(destinationPlace!.lat),\(destinationPlace!.lng)"
            
            if let wp = waypointPlaces{
                waypoints = placesToWaypointString(wp).stringByAddingPercentEncodingForURLQueryParameter()
            }
            
            if let op = travelOptions{
                options = urlEncodeOptions(op)
            }
            
            gta.calculateTripDirectionsWithDelegate(origin.stringByAddingPercentEncodingForURLQueryParameter()!, destination: destination.stringByAddingPercentEncodingForURLQueryParameter()!, waypoints: waypoints, options: options)
        }else{
            showSimpleAlertWithTitle("Error ", message: "Error for request", viewController: self)
        }
        
    }
    
    func loadDataToMap(){
        createOriginMapObject()
        for (i,trip) in legDisplayData.enumerated(){
            
            if i == legDisplayData.count - 1{
                createDestinationMapObject()
                return
            }
            createMapObject(trip, stopNum: i)
        }
    }
    
    
    
    func createMapObject(_ trip:LegDisplayData, stopNum:Int){
        
        
        let marker = GMSMarker(position: CLLocationCoordinate2DMake(trip.endLocation["lat"]!, trip.endLocation["lng"]!))
        
        marker.title = "(\(stopNum+1)) - \(waypointTodos![stopNum].name)"
        marker.snippet = "\(trip.endAddress)"
        
        marker.map = mapView
        mapMarkers.append(marker)
        
    }
    
    func createOriginMapObject(){
        let marker = GMSMarker(position: CLLocationCoordinate2DMake(originPlace!.lat, originPlace!.lng))
        
        marker.title = "Origin - \(originTodo!.name)"
        marker.snippet = originPlace!.address
        marker.icon = GMSMarker.markerImage(with: UIColor.white)
        
        marker.map = mapView
        mapMarkers.append(marker)

    }
    
    func createDestinationMapObject(){
        let marker = GMSMarker(position: CLLocationCoordinate2DMake(legDisplayData[legDisplayData.count-1].endLocation["lat"]! , legDisplayData[legDisplayData.count-1].endLocation["lng"]!))
        
        marker.title = "Destination - \(destinationTodo!.name)"
        marker.snippet = legDisplayData[legDisplayData.count-1].endAddress
        marker.icon = GMSMarker.markerImage(with: UIColor.green)
        
        marker.map = mapView
        mapMarkers.append(marker)

        
    }
    
    func clearMapObjects(){
        for m in mapMarkers{
            m.map = nil
        }
        
        mapPolyline.map = nil
    }
     
    
    func drawRoute(_ polyline:String){
        let path = GMSMutablePath(fromEncodedPath: polyline)
        let line = GMSPolyline(path: path)
        line.strokeWidth = 3
        line.strokeColor = UIColor.darkGray
        line.map = mapView
        mapPolyline = line
    }
    
    func getTotalAllocatedTime() -> Int{
        var time = 0.0
        
 //       if let o = originTodo?.settings.timeAllocation{
  //          time += o
  //      }
        
        if let d = destinationTodo?.settings.timeAllocation{
            time += d
        }
        
        if let wpt = waypointTodos{
            for wp in wpt{
                if let all = wp.settings.timeAllocation{
                    time += all
                }
            }
        }
        
        return Int(time)
    }
    
    func formattedTransitInfo(_ data:[Transit]) -> String{
        var outputText = "\n TRANSIT DATA \n\n"
        
        for (i,td) in data.enumerated(){
            outputText += "+ \(td.line.vehicle["type"]!): "
            if let name = td.line.name{
                outputText += " \(name)"
            }
            
            if let sname = td.line.shortName{
                outputText += " / \(sname)"
            }
            
            outputText += "\n"
            outputText += "+ '\(td.departureTime)' from \(td.departureStopName)\n"
            outputText += "+ arrive \(td.arrivalStopName) at '\(td.arrivalTime)'\n"
            outputText += "+ HEADSIGN: \(td.headsign)"
            
            if i < data.count{
                outputText += "\n\n\n"
            }

        }
        
        return outputText
    }
    
    
    func clearTableData(){
        routeSummary = nil
        legDisplayData.removeAll()
        tableView.reloadData()
    }
 
 

}
