//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Даниил Франк on 18.12.2021.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {

    var place = Place()
    let mapManager = MapManager()
    var mapViewControllerDelegate: MapViewControllerDelegate?
    
    let annotatuinIdentifire = "annotatuinIdentifire"
    var incomeSegueIdentifire = ""
   
    var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(
                for: mapView,
                   and: previousLocation) { (currentLocation) in
                       
                       self.previousLocation = currentLocation
                       
                       DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                           self.mapManager.showUserLocation(mapView: self.mapView)
                       }
                   }
                }
            }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressLabel.text = ""
        mapView.delegate = self
        setupMapView()
    }
    
    @IBAction func centerViewInUserLocation() { mapManager.showUserLocation(mapView: mapView) }
    
    @IBAction func closeButtonPressed() { dismiss(animated: true) }
    
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }
    
    @IBAction func goButtonPressed() {
        mapManager.getDirection(for: mapView) { (location) in
            self.previousLocation = location
        }
    }
    
    private func setupMapView() {
        
        goButton.isHidden = true
        
        mapManager.checkLocationAuthorization(manager: mapManager.locationManager, mapView: mapView, segueIdetifier: incomeSegueIdentifire)
        
        if incomeSegueIdentifire == "ShowPlace" {
            mapManager.setupPlacemark(place: place, mapView: mapView)
            addressLabel.isHidden = true
            doneButton.isHidden = true
            mapPinImage.isHidden = true
            goButton.isHidden = false
        }
    }
    
//    private func setupLocationManager(){
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//    }
    


}

extension MapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil}
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotatuinIdentifire) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation,
                                                    reuseIdentifier: annotatuinIdentifire)
            
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData{
            
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if incomeSegueIdentifire == "ShowPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: self.mapView)
            }
        }
        
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return}
            
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil{
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }

            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        
        return renderer
    }
}

extension MapViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        
        mapManager.checkLocationAuthorization(manager: mapManager.locationManager, mapView: mapView, segueIdetifier: incomeSegueIdentifire)
    }
}
