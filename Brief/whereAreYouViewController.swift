import UIKit
import MapKit
import CoreLocation

class whereAreYouViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    var dropPin = MKPointAnnotation()
    let regionRadius: CLLocationDistance = 10000
    
   var locationDictionary = Dictionary<String, String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Where are you?"
        
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        nav?.titleTextAttributes = [NSFontAttributeName: UIFont(name: "avenirnext-demibold", size: 22)!]
        
        var saveButton : UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: "saveDataAndGoBack")
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        // Do any additional setup after loading the view.
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
            var locValue:CLLocationCoordinate2D = locationManager.location.coordinate
            var userLocation = CLLocationCoordinate2DMake(locValue.latitude, locValue.longitude)
            
            // Drop a pin
            dropPin = MKPointAnnotation()
            dropPin.coordinate = userLocation
            dropPin.title = "You are here"
            mapView.addAnnotation(dropPin)
            
            centerMapOnLocation(locationManager.location)
            
            var geocoder = CLGeocoder()
            
            let location = CLLocation(latitude: locationManager.location.coordinate.latitude, longitude: locationManager.location.coordinate.longitude)
            
            geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                let placeArray = placemarks as? [CLPlacemark]
                
                // Place details
                var placeMark: CLPlacemark!
                placeMark = placeArray?[0]
                
                // City
                let city = placeMark.addressDictionary["City"] as? NSString
                let country = placeMark.addressDictionary["CountryCode"] as? String//= placeMark.addressDictionary["Country"] as? NSString
                
                var сountryCode = ""
                var stateCode = ""
                var cityName = ""
                
                if placeMark.addressDictionary["CountryCode"] != nil {
                    сountryCode = placeMark.addressDictionary["CountryCode"] as! String
                }
                if placeMark.addressDictionary["State"] != nil {
                    stateCode = placeMark.addressDictionary["State"] as! String
                }
                if placeMark.addressDictionary["City"] != nil {
                    cityName = placeMark.addressDictionary["City"] as! String
                }
                
                self.locationDictionary = ["countryCode" : сountryCode, "stateCode" : stateCode, "cityName" : cityName]
                println("To save - \(self.locationDictionary)")
                
                self.searchField.text = "\(city!), \(country!)"
                self.navigationItem.rightBarButtonItem?.enabled = true
                
                var address = "\(city!), \(сountryCode)"
                var geocoder = CLGeocoder()
            })
        }
        
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        getLatitudeAndLongitudeFromAddress(searchField.text)
        
        return false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if count(textField.text) == 0 {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
        
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        return true
    }
   
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getLatitudeAndLongitudeFromAddress(addressString: NSString) {
        var geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(addressString as String, completionHandler: {(placemarks, error) -> Void in
            
            if((error) != nil){
                
                println("Error", error)
                
                let alert = UIAlertView()
                alert.title = "Nothing's found!"
                alert.message = "Please, provide more details and try again."
                alert.addButtonWithTitle("Ok")
                alert.show()
                
                self.navigationItem.rightBarButtonItem?.enabled = false
            }
                
            else if let placemark = placemarks?[0] as? CLPlacemark {
                
                var placemark:CLPlacemark = placemarks[0] as! CLPlacemark
                var coordinates:CLLocationCoordinate2D = placemark.location.coordinate
                
                var pointAnnotation:MKPointAnnotation = MKPointAnnotation()
                pointAnnotation.coordinate = coordinates
                
                let city = placemark.addressDictionary["City"] as? NSString
                let country = placemark.addressDictionary["CountryCode"] as? String//placemark.addressDictionary["Country"] as? NSString

                println(placemark.addressDictionary)
                
                var сountryCode = ""
                var stateCode = ""
                var cityName = ""
                
                if placemark.addressDictionary["CountryCode"] != nil {
                    сountryCode = placemark.addressDictionary["CountryCode"] as! String
                }
                if placemark.addressDictionary["State"] != nil {
                    stateCode = placemark.addressDictionary["State"] as! String
                }
                if placemark.addressDictionary["City"] != nil {
                    cityName = placemark.addressDictionary["City"] as! String
                }
                
                self.locationDictionary = ["countryCode" : сountryCode, "stateCode" : stateCode, "cityName" : cityName]
                
                println("To save - \(self.locationDictionary)")

                if city != nil && country != nil {
                    
                    println("\(city!), \(country!)")
                    
                    self.searchField.text = "\(city!), \(country!)"
                    
                    self.dropPin.title = "\(city!), \(country!)"
                    self.dropPin.coordinate = coordinates
                    
                    self.mapView?.centerCoordinate = coordinates
                    self.mapView?.selectAnnotation(self.dropPin, animated: true)
                    
                    self.navigationItem.rightBarButtonItem?.enabled = true
                }
                else if city == nil {
                    if country != nil {
                        println("\(country!)")
                        
                        self.searchField.text = "\(country!)"
                        
                        self.dropPin.title = "\(country!)"
                        self.dropPin.coordinate = coordinates
                        
                        self.mapView?.centerCoordinate = coordinates
                        self.mapView?.selectAnnotation(self.dropPin, animated: true)
                        
                        self.navigationItem.rightBarButtonItem?.enabled = true
                    }
                }
                else if country == nil {
                    if city != nil {
                        println("\(city!)")
                        
                        self.searchField.text = "\(city!)"
                        
                        self.dropPin.title = "\(city!)"
                        self.dropPin.coordinate = coordinates
                        
                        self.mapView?.centerCoordinate = coordinates
                        self.mapView?.selectAnnotation(self.dropPin, animated: true)
                        
                        self.navigationItem.rightBarButtonItem?.enabled = true
                    }
                }
            }
            
        })
    }
    
    func saveDataAndGoBack() {
        println(self.searchField.text)
        
        println(self.locationDictionary)
        
        NSUserDefaults.standardUserDefaults().setObject(self.locationDictionary, forKey: "locationDictionary")
        NSUserDefaults.standardUserDefaults().setObject(self.searchField.text, forKey: "address")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        self.navigationController!.popViewControllerAnimated(true)
    }
}
