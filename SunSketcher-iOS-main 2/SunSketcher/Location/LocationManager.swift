//
//  LocationManager.swift
//  Sunsketcher
//
//  Created by Tameka Ferguson on 9/6/23.
//


/*
 This file is done to retrieve the location of the user as well for requesting  permission to
 use the user's location. From this you can get the user's latitude, longitude, and altitude.
 */

import Foundation
import MapKit
import CoreLocation

@MainActor
class LocationManager: NSObject, ObservableObject {
    @Published var location: CLLocation?
    @Published var region = MKCoordinateRegion()
    
    static let shared = LocationManager()
    
    var timer: Timer?
    
    private var locationCallback: ((CLLocation) -> Void)?
    private let locationManager = CLLocationManager()
    /*private let spoofedLocation = CLLocation(
                    coordinate: CLLocationCoordinate2D(
                        latitude: 40.53766,
                        longitude: -3.61249
                    ),
                    altitude: 0.0,
                    horizontalAccuracy: 1.0,
                    verticalAccuracy: 1.0,
                    timestamp: Date()
                )*/
    
    override init() {
        super.init()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // chooses how accurate you want the location to be
        locationManager.distanceFilter = kCLDistanceFilterNone // this is used to track all movements of the phone.
        //Note: that within the app the location is only saved in the database once so it doesn't keep changing.
        //The lat | lon keeps updating on the countdown screen but that does not alter what is recorded.
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation() // Remember to update Info.plist
        locationManager.delegate = self
        
    }
    
    func requestLocationUpdate(callback: @escaping (CLLocation) -> Void) {
        locationCallback = callback
        locationManager.startUpdatingLocation()
    }
    

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    
    
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        /*self.location = spoofedLocation
                    self.region = MKCoordinateRegion(
                        center: spoofedLocation.coordinate,
                        latitudinalMeters: 5000,
                        longitudinalMeters: 5000
                    )*/
        
        
        
        if let lastLocation = locations.last {
            let altitude = lastLocation.altitude
            self.location = lastLocation
            self.region = MKCoordinateRegion(center: lastLocation.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        }
        
        
    }
    
}
