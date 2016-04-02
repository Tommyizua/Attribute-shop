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
    
    enum RowName: Int {
        case Phone = 0
        case Email = 1
        case Address = 2
        case Map = 3
    }
    
    private let rowPhotoHeight: CGFloat = 50;
    private let rowAddressHeight: CGFloat = 80;
    
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
        
        let officeLatitude = 50.435578
        let officeLongitude = 30.48238
        
        let annotation = OfficeAnnotation(
            title: "ул. Стадионная 5, оф. 9",
            locationName: "Интернет магазин \"Attribute\"",
            discipline: "Attribute",
            coordinate: CLLocationCoordinate2D(latitude: officeLatitude, longitude: officeLongitude))
        
        mapView.addAnnotation(annotation)
        
        let initialLocation = CLLocation(latitude: officeLatitude, longitude: officeLongitude)
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
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.row {
            
        case RowName.Phone.rawValue, RowName.Email.rawValue:
            return self.rowPhotoHeight
            
        case RowName.Address.rawValue:
            return self.rowAddressHeight
            
        case RowName.Map.rawValue:
            return CGRectGetHeight(self.view.bounds) - self.rowPhotoHeight * 2 - self.rowAddressHeight
            
        default:
            return 50
        }
        
    }
    
}
