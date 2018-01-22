//
//  Extension.swift
//  Attribute
//
//  Created by Yaroslav on 06/12/15.
//  Copyright © 2015 Yaroslav Chyzh. All rights reserved.
//

import MapKit

extension ContactsTVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      
        if let annotation = annotation as? OfficeAnnotation {
           
            let identifier = "pin"
            var view: MKPinAnnotationView
          
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView {
                
                    dequeuedView.annotation = annotation
                    view = dequeuedView
          
            } else {
                
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure) as UIView
            }
            
            view.pinTintColor = UIColor.orange
            
            return view
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl) {
            
            let location = view.annotation as! OfficeAnnotation
          
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            
            location.mapItem().openInMaps(launchOptions: launchOptions)
    }
    
}
