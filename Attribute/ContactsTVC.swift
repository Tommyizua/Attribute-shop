//
//  ContactsVC.swift
//  Attribute
//
//  Created by Yaroslav on 30/11/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit
import MapKit

class ContactsTVC: UITableViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
 
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        checkLocationAuthorizationStatus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Контакты"
        
        mapView.delegate = self
        
        let annotation = OfficeAnnotation(
            title: "ул. Стадионная 5, оф. 9",
            locationName: "Интернет магазин \"Attribute\"",
            discipline: "Attribute",
            coordinate: CLLocationCoordinate2D(latitude: 50.435578, longitude: 30.48238))
        
        mapView.addAnnotation(annotation)
        
        let initialLocation = CLLocation(latitude: 50.435578, longitude: 30.48238)
        let regionRadius: CLLocationDistance = 1000
       
        centerMapOnLocation(initialLocation, regionRadius: regionRadius)
    }
    
    // MARK: - Help Methods
    
    func checkLocationAuthorizationStatus() {
        
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            
            mapView.showsUserLocation = true
            
        } else {
            
            locationManager.requestWhenInUseAuthorization()
            
        }
    }

    func centerMapOnLocation(location: CLLocation, regionRadius: CLLocationDistance) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)

        self.mapView.setRegion(coordinateRegion, animated: true)
    }

}
