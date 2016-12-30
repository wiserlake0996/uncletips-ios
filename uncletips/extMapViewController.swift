//
//  extMapViewController.swift
//  uncletips
//
//  Created by Ibrahim Dawha on 6/1/16.
//  Copyright © 2016 wiserlake. All rights reserved.
//

import Foundation
import GoogleMaps
import CoreLocation
import UIKit


extension MapViewController{
    func getSearchInput(_ coordinate:CLLocationCoordinate2D){
        

        
        alert = UIAlertController(title: "", message: "210m radius", preferredStyle: .alert)
        
        if let alert = alert{
            
            let saveAction = UIAlertAction(title: "search", style: .default,handler: {
                (action:UIAlertAction) -> Void in
                let textField = alert.textFields!.first
                let text = (textField?.text!)!
                let q:String = text.stringByAddingPercentEncodingForURLQueryParameter()!
                let rad = Double(Int(self.searchSliderRadius))
                let lat = "\(coordinate.latitude)"
                let lng = "\(coordinate.longitude)"
                
                DispatchQueue.main.async(execute: {
                    self.removeAllSearchMarkers()
                })
                
                self.gpa.searchPlacesWithDelegate(q, radius: rad, latitude: lat, longitude: lng)
            })
            
            let cancelAction = UIAlertAction(title: "cancel", style: .default) { (action: UIAlertAction) -> Void in
                
            }
            alert.addTextField {
                (textField: UITextField) -> Void in
                textField.placeholder = "search query here.."
            }
            let myFrame = CGRect(x: 2.0, y: 2.0, width: 250.0, height: 25.0)
            let slider = UISlider(frame: myFrame)
            slider.minimumValue = 101
            slider.maximumValue = 1010
            slider.value = Float(210)
            slider.isContinuous = true
            slider.addTarget(self, action: #selector(MapViewController.alertSliderValueChanged(_:)), for: .valueChanged)
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            alert.view.addSubview(slider)
            present(alert, animated: true, completion: nil)
            
            
        }
    }
    
    
    func alertSliderValueChanged(_ sender:UISlider){
        
        if let alert = alert{
            alert.message = "\(Int(sender.value))m radius"
            searchSliderRadius = Double(sender.value)
        }
    }
    
    func loadPlacePicker(_ coordinate:CLLocationCoordinate2D){
        var placePicker:GMSPlacePicker?
        
        let center = coordinate
        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
        let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        placePicker = GMSPlacePicker(config: config)
        
        placePicker?.pickPlace(callback: { (place: GMSPlace?, error: NSError?) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let pl = place{
                self.makeTodoWithGMSPlace(pl)
            }
        } as! GMSPlaceResultCallback)
    }
}




extension MapViewController{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        locationManager.startUpdatingLocation()
        
        self.mapView.isMyLocationEnabled = true
        self.mapView.settings.myLocationButton = true
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            self.currentLocation = location.coordinate
            NotificationsManager.sharedInstance.setCurrentLocation(location.coordinate)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        showSimpleAlertWithTitle("region monitoring", message: "monitoring count \(locationManager.monitoredRegions.count)", viewController: self)
    }
}

extension MapViewController{
    func placesApi(_ placeApi: GooglePlacesApi, placesSearchResult placeItems: [Place]) {
        loadSearchPlaceItems(placeItems)
    }
    
}

extension MapViewController{
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D){
        
        loadPlacePicker(coordinate)
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {

        getSearchInput(coordinate)
        
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
       // marker.map = nil

        DispatchQueue.main.async(execute: {
         //   marker.map = nil

            self.deleteObject(marker)
        })
    }

    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let infoWindow = TodoInfoWindow.loadFromNib()
        
        if let data:[String:String] = (marker.userData as? [String:String]){
            
            if data["type"] == "todo"{//CHECK HERE
                
                if placeJourneys[data["place_id"]!] != nil{
                    infoWindow.setData(todos[data["type_id"]!]!, place: todoPlaces[data["place_id"]!]!, journeyData: placeJourneys[data["place_id"]!])
                }else{
                    infoWindow.setData(todos[data["type_id"]!]!, place: todoPlaces[data["place_id"]!]!, journeyData:nil)
                }
                
                
                return infoWindow
                
            }else if data["type"] == "search"{
                let infoWindow = SearchInfoWindow.loadFromNib()
                
                if placeJourneys[data["place_id"]!] != nil{
                    infoWindow.setData(searchPlaces[data["place_id"]!]!, journey: placeJourneys[data["place_id"]!]!)
                }else{
                    infoWindow.setData(searchPlaces[data["place_id"]!]!, journey: nil)

                }
                
                return infoWindow
                
            }
            
        }
        return nil
        
    } 
    
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if let info = marker.userData as? [String:String]{
            if info["type"] == "todo"{
                if let td = todos[info["type_id"]!]{
                    openTodoItem(td, place: todoPlaces[info["place_id"]!]!)
                }
            }else if info["type"] == "search"{
                let td = Todo(id: generateUniqueId(), name: "")
                openTodoItem(td, place: searchPlaces[info["place_id"]!]!)

            }
        }
    }
    
    
}






