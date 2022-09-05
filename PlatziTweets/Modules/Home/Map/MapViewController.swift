//
//  MapViewController.swift
//  PlatziTweets
//
//  Created by Margarita Xiques on 30/08/22.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var  mapContainer: UIView!
    
    
    // MARK: - Properties
    var posts = [Tweet]()
    private var map: MKMapView?
    

    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupMap()
    }
    private func setupMap() {
        map = MKMapView(frame: mapContainer.bounds)
        
        mapContainer.addSubview(map ?? UIView())
        
        setupMarkers()
    }
    
    private func setupMarkers() {
        posts.forEach { item in
            let marker = MKPointAnnotation()
            marker.coordinate = CLLocationCoordinate2D(latitude: item.location.latitude, longitude: item.location.longitude)
            
            marker.title = item.text
            marker.subtitle = item.author.names
            
            map?.addAnnotation(marker)
        }
        
        // Buscamos el ultimo post del arreglo
        guard let lastPosts = posts.last
        else {
            return
        }
        
        let lastPostLocation = CLLocationCoordinate2D(latitude: lastPosts.location.latitude,
                                                      longitude: lastPosts.location.longitude)
        
        guard let heading = CLLocationDirection(exactly: 12) else {
            return
        }
        
        map?.camera = MKMapCamera(lookingAtCenter: lastPostLocation, fromDistance: 50, pitch: .zero, heading: heading)
    }

}
