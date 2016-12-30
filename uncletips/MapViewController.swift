import UIKit
import GoogleMaps
import CoreLocation
import FirebaseDatabase
import Firebase

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, GooglePlacesApiDelegate, TodoItemViewControllerDelegate, GoogleDistanceApiDelegate {

    //MARK: Properties
    @IBOutlet weak var mapView: GMSMapView!
    
    let locationManager = CLLocationManager()
    
    var todos = [String:Todo]()
    var todoPlaces = [String:Place]()
    var placeJourneys = [String: Journey]()
    
    var todoMapMarkers = [String: GMSMarker]()
    var searchMapMarkers = [String: GMSMarker]()

    
    var searchPlaces = [String:Place]()
    
    var segueTodo: Todo?
    var seguePlace:Place?
    var segueJourney:Journey?
    
    var gda:GoogleDistanceApi = GoogleDistanceApi()
    var gpa:GooglePlacesApi = GooglePlacesApi()
    var reminders:Reminders = Reminders()
    
    var searchSliderRadius:Double = 200
    var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(40.802773, -73.992258)
    var alert:UIAlertController?
    
    var appeared:Bool = false
    
    var refHandler:FIRDatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        locationManager.delegate = self
        gpa.delegate = self
        gda.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        self.mapView.camera = GMSCameraPosition(target: currentLocation, zoom: 15, bearing: 0, viewingAngle: 0)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        removeAllTodoMarkers()
   
        let userTodosRef = DataService.sharedInstance.BASE_REF.child("/todos/guestlake")
 
        refHandler = userTodosRef.observe(.childAdded, with: { (data) -> Void in
            
            let dataValue = data.value! as! NSDictionary

            let snapSettings = dataValue["settings"] as! [String:AnyObject]
            let snapPlace = dataValue["place"] as! [String:AnyObject]
                    
            let decoded = dictToObjects(snapSettings, place: snapPlace)
                    
            let todo = Todo(id: data.key, name: dataValue["name"] as! String)
            todo.settings = decoded.0
                    
            let placeData = decoded.1
            self.createOrUpdateTodo(todo, place: placeData)
            
           // self.refreshJourneryData()
            NotificationsManager.sharedInstance.setTodosAndPlaces(Array(self.todos.values), place: Array(self.todoPlaces.values))

        })
        
        //refreshJourneryData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DataService.sharedInstance.BASE_REF.removeObserver(withHandle: refHandler)
    }
    
    //MARK: ACTIONS
    @IBAction func refreshMap(_ sender: AnyObject) {
       // removeAllTodoMarkers()
       removeAllSearchMarkers()
       // reminders.clearEverything()
        
        refreshJourneryData()
    }
    
    
    //MARK: methods
    
    func createMarker(_ place:Place){
        let coordinate = CLLocationCoordinate2DMake(place.lat, place.lng)
        let marker = GMSMarker(position: coordinate)
        
        var markerInfo = [String:String]()
        markerInfo["type"] = place.type()
        markerInfo["place_id"] = place.id
        markerInfo["type_id"] = place.typeID
        marker.userData = markerInfo

        marker.title = place.name
        marker.snippet = place.address
        
        if place.type() == "search"{
            marker.icon = GMSMarker.markerImage(with: UIColor.yellow)
            searchMapMarkers[place.id] = marker
            marker.map = mapView
            return
        }
        
        todoMapMarkers[place.id] = marker
        marker.map = mapView
        
        print("todo markers count ", todoMapMarkers.count)
    }
    
    func removeMarker(_ marker:GMSMarker)
    {
        if let data = marker.userData as? [String:String]{
            if data["type"] == "todo"{
                todoMapMarkers[data["place_id"]!] = nil
            }else if data["type"] == "search"{
                searchMapMarkers[data["place_id"]!] = nil

            }
        }
        marker.map = nil
    }
    
    func removeAllTodoMarkers(){
        let values = Array(todoMapMarkers.values)
        
        for v in values{
            removeMarker(v)
        }
    }
    
    func removeAllSearchMarkers(){
        let values = Array(searchMapMarkers.values)
        
        for v in values{
            removeMarker(v)
        }
    }
    
    func makeTodoWithGMSPlace(_ place:GMSPlace){
        
        let todo = Todo(id: generateUniqueId(), name: "")
        var pName:String = "unknown location"
        var pAddy:String = "unknown address"
        let lat:Double = place.coordinate.latitude
        let lng:Double = place.coordinate.longitude
        pName = place.name
        
        if let ady = place.formattedAddress{
            pAddy = ady
        }
        
        let pl = TodoPlace(id: generateUniqueId(), name: pName, address: pAddy, lat: lat, lng: lng)
        pl.typeID = todo.id
        pl.googlePlaceId = place.placeID
        pl.categoryTypes = place.types
        pl.rating = Double(place.rating)
        
        if pl.name != "unknown location"{
            openTodoItem(todo, place: pl)
        }
    }
    
    func openTodoItem(_ todo:Todo, place:Place, journey:Journey? = nil){
        segueTodo = todo
        seguePlace = place
        
        if let jou = journey{
            segueJourney = jou
        }
        self.performSegue(withIdentifier: "MapOpenTodo", sender: self)
    }
    
    func loadSearchPlaceItems(_ places:[Place]){
        DispatchQueue.main.async(execute: {
            for place in places{
                self.searchPlaces[place.id] = place
                self.createMarker(place)
            }
        })
    }
    
    func createOrUpdateTodo(_ todo:Todo, place:Place, journey:Journey? = nil){
        todos[todo.id] = todo
        todoPlaces[place.id] = place
        if let j = journey{
            placeJourneys[place.id] = j
        }
        reminders.setReminder(todo, place: place)
        updateMapObject(place)
    }
    
    func deleteObject(_ marker:GMSMarker){
        removeMarker(marker)
        
        if let data = marker.userData as? [String:String]{
            if data["type"] == "todo"{
                DataService.sharedInstance.deleteTodo(data["type_id"]!)
                reminders.removeAllReminders(todos[data["type_id"]!]!)
                todos[data["type_id"]!] = nil
                todoPlaces[data["place_id"]!] = nil

            }else if data["type"] == "search"{
                searchPlaces[data["place_id"]!] = nil
            }
        }
    }
    
    func updateMapObject(_ place:Place){
        
        if searchPlaces[place.id] != nil{
            searchPlaces.removeValue(forKey: place.id)
        }
        
        if let mark = searchMapMarkers[place.id]{
            mark.map = nil
        }
        
        if todoMapMarkers[place.id] == nil{
            createMarker(place)
        }
    }
    
    
    
    func distanceApi(_ distanceApi: GoogleDistanceApi, distanceCalculationResponse data: [Journey]) {
        
        DispatchQueue.main.async(execute: {
            
            let keys = Array(self.todoPlaces.keys)
            var index = 0
            for key in keys{
                self.placeJourneys[key] = data[index]
                index = index + 1
            }
        })
        
    }
    
    
    
    
    
    //MARK: Methods
    
    func refreshJourneryData(){
        
        let places = Array(todoPlaces.values)
        let destination = placesToWaypointString(places)
        let origin = "\(currentLocation.latitude),\(currentLocation.longitude)"
        gda.requestDistanceWithDelegate(origin.stringByAddingPercentEncodingForURLQueryParameter()! , destinations: destination.stringByAddingPercentEncodingForURLQueryParameter()! )
        NotificationsManager.sharedInstance.setTodosAndPlaces(Array(todos.values), place: Array(todoPlaces.values))

    }
    
    
    
    

    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MapOpenTodo"{
            if let vc = segue.destination as? TodoItemViewController{
                vc.place = seguePlace
                vc.todo = segueTodo
                vc.journey = segueJourney
                vc.currentLocation = currentLocation
                vc.delegate = self
            }
        }
    }
}

extension MapViewController{
    func todo(_ controller: TodoItemViewController, didUpdateTodoItem todo: Todo, place: Place, journey: Journey?) {
        mapView.selectedMarker = nil
        //createOrUpdateTodo(todo, place: place, journey: journey)
       // DataService.sharedInstance.createNewTodo(saveObjectMake(todo, place: place))
        
    }
}
