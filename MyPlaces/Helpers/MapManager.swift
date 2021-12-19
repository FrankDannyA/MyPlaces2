//
//  MapManager.swift
//  MyPlaces
//
//  Created by Даниил Франк on 19.12.2021.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()
    private var placeCoordinate: CLLocationCoordinate2D?
    private let regionInMeters = 1000.00
    private var directionsArray: [ MKDirections] = []
    
    //Маркер заведения
    func setupPlacemark(place: Place, mapView: MKMapView){
        
        guard let location = place.location else { return }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    //Проверка доступности сервисов геолокации
    func checkLocationServices(mapView: MKMapView, locationManager: CLLocationManager, segueIdentifier: String, closure: () -> ()) {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(manager: locationManager, mapView: mapView, segueIdetifier: segueIdentifier)
            closure()
            
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Ой", message: "Кажется вы забыли включить геолокацию")
            }
        }
    }
    
    //Проверка авторизации приложения для использования сервисов геолокации
    func checkLocationAuthorization(manager: CLLocationManager, mapView: MKMapView, segueIdetifier: String){
        switch manager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            showAlert(title: "Ой", message: "Кажется вы забыли включить геолокацию")
            break
        case .denied:
            showAlert(title: "Ой", message: "Кажется вы забыли включить геолокацию")
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdetifier == "GetAdress" { showUserLocation(mapView: mapView) }
            break
        @unknown default:
            showAlert(title: "Ой", message: "Кажется в IOS добавли что- то новое, скоро и мы обновимся")

        }
    }
    
    //Фокус карты на местопложении пользователя
    func showUserLocation(mapView: MKMapView ){
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters:  regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    //Строим маршрут от местоположеня пользователя до заведения
    func getDirection(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        
        guard let location = locationManager.location?.coordinate
        else { showAlert(title: "Ошибка", message: "Локация не определенна"); return}
        
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDitectionRequest(from: location)
        else { showAlert(title: "Ошибка", message: "Локация не определенна"); return}
        
        let directions = MKDirections(request: request)
        
        resetMapView(withNew: directions, mapView: mapView)
        
        directions.calculate { (response, error) in
            
        if let error = error {
            print(error)
            return
        }
            
        guard let response = response
        else { self.showAlert(title: "Ошибка", message: "Маршрут не найден"); return}

        for route in response.routes {
            mapView.addOverlay(route.polyline)
            mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
            let distance = String(format: "%.1f", route.distance / 1000)
            let timeIntervar = route.expectedTravelTime
                
            print("Расстояние до места: \(distance) км")
            print("Время в пути: \(timeIntervar * 60) мин")
            }
        }
    }
    
    //Настройка запроса для расчета маршрута
    func createDitectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destanationCoordinate = placeCoordinate else { return nil}
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destanation = MKPlacemark(coordinate: destanationCoordinate)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destanation)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    //Меняем отображаемую зону области карты в соответствии с перемещение пользователя
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        
        guard let location = location else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else { return }
        
        closure(center)
    }
    
    //Сброс всех ранее постоенных маршрутов перед постоение нового
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
        
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
    
    //Определение центра отображаемой области карты
    func getCenterLocation( for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    //Вызов Алёрта
    func showAlert(title: String?, message: String?){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
    }
}
