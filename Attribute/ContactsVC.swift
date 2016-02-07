//
//  ContactsVC.swift
//  Attribute
//
//  Created by Yaroslav on 30/11/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import UIKit
import MapKit

class ContactsVC: UIViewController {
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Контакты"
        mapView.delegate = self
        let annotation = Office(title: "ул. Стадионная 5, оф. 9",
            locationName: "Интернет магазин \"Attribute\"",
            discipline: "Attribute",
            coordinate: CLLocationCoordinate2D(latitude: 50.435578, longitude: 30.48238))
        
        mapView.addAnnotation(annotation)
        
        let initialLocation = CLLocation(latitude: 50.435578, longitude: 30.48238)
        let regionRadius: CLLocationDistance = 1000
        func centerMapOnLocation(location: CLLocation) {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                regionRadius * 2.0, regionRadius * 2.0)
            mapView.setRegion(coordinateRegion, animated: true)
        }
        centerMapOnLocation(initialLocation)
        
    }
}
