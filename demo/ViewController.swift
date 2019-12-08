//
//  ViewController.swift
//  demo
//
//  Created by Kriti Agarwal on 23/07/19.
//  Copyright © 2019 Kriti Agarwal. All rights reserved.
//

import UIKit
import Mapbox

class ViewController: UIViewController {

    // MARK: - Class Variables
    var mapView = MGLMapView()
    var userCoordinates: CLLocationCoordinate2D?
    
    
    // MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    // MARK:- MapView methods
    func setupView() {
        
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      //  mapView.setCenter(CLLocationCoordinate2D(latitude: 40.74699, longitude: -73.98742), zoomLevel: 9, animated: false)
        mapView.styleURL = MGLStyle.lightStyleURL
        
        // Set the map view's delegate
        mapView.delegate = self
        
        // Allow the map view to display the user's location
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        view.addSubview(mapView)
    }
    
    func addAnnotation(lat: Double, lon: Double){
        let annotation = MGLPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        annotation.title = "My Marker"
        mapView.removeAnnotations(mapView.annotations ?? [])
        mapView.addAnnotation(annotation)
        polygonCircleForCoordinate(coordinate: annotation.coordinate, withMeterRadius: 100)
    }
    
    func plotPoint() {
        
        //Coordinate offsets in radians
        let dLat = dn/R
        let dLon = de / (R*cos(pi * (userCoordinates?.latitude ?? 0.0)/180))
        
        //OffsetPosition, decimal degrees
        let latO = Double(userCoordinates?.latitude ?? 0.0) + (dLat * 180/pi)
        let lonO = Double(userCoordinates?.longitude ?? 0.0) + (dLon * 180/pi)
        
        addAnnotation(lat: latO, lon: lonO)
    }
    
    func polygonCircleForCoordinate(coordinate: CLLocationCoordinate2D, withMeterRadius: Double) {
        let degreesBetweenPoints = 8.0
        //45 sides
        let numberOfPoints = floor(360.0 / degreesBetweenPoints)
        let distRadians: Double = withMeterRadius / 6371000.0
        // earth radius in meters
        let centerLatRadians: Double = coordinate.latitude * Double.pi / 180
        let centerLonRadians: Double = coordinate.longitude * Double.pi / 180
        var coordinates = [CLLocationCoordinate2D]()
        //array to hold all the points
        for index in 0 ..< Int(numberOfPoints) {
            let degrees: Double = Double(index) * Double(degreesBetweenPoints)
            let degreeRadians: Double = degrees * Double.pi / 180
            let pointLatRadians: Double = asin(sin(centerLatRadians) * cos(distRadians) + cos(centerLatRadians) * sin(distRadians) * cos(degreeRadians))
            let pointLonRadians: Double = centerLonRadians + atan2(sin(degreeRadians) * sin(distRadians) * cos(centerLatRadians), cos(distRadians) - sin(centerLatRadians) * sin(pointLatRadians))
            let pointLat: Double = pointLatRadians * 180 / Double.pi
            let pointLon: Double = pointLonRadians * 180 / Double.pi
            let point: CLLocationCoordinate2D = CLLocationCoordinate2DMake(pointLat, pointLon)
            coordinates.append(point)
        }
        let polygon = MGLPolygon(coordinates: &coordinates, count: UInt(coordinates.count))
        self.mapView.addAnnotation(polygon)
    }
    
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return 0.5
    }
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        return .white
    }
    
    func mapView(_ mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return UIColor.gray
    }
    
    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        return 2
    }
}


// MARK: - MapBoxDelegate
extension ViewController: MGLMapViewDelegate {
    
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        
        userCoordinates = CLLocationCoordinate2D(latitude: userLocation?.location?.coordinate.latitude ?? 40.74699, longitude: userLocation?.location?.coordinate.longitude ?? -73.98742)
        print(userCoordinates ?? "")
        
        guard let _ = userLocation else { return }
        
        plotPoint()
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped.
        return true
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        
        /// Change this dont user deprecaetd methods
        let camera = MGLMapCamera(lookingAtCenter: annotation.coordinate, acrossDistance: 5000, pitch: 15, heading: 180)
        mapView.fly(to: camera, withDuration: 4, peakAltitude: 3000, completionHandler: nil)
    }

}

