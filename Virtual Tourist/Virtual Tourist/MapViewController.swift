//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Najd  on 20/11/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData
class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    var text: NSManagedObjectContext {
        return DataController.shared.viewContext
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetched()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let pin = fetchedResultsController.fetchedObjects?.filter {
            $0.compare(to: view.annotation!.coordinate)
            }.first!
        performSegue(withIdentifier: "ShowPhotos", sender: pin)
    }
    
    func ChangedContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        updateMapView()
    }
    
   
    @IBAction func longPressing(_ sender: Any) {
        if (sender as AnyObject).state != .began { return }
        let touchPoint = (sender as AnyObject).location(in: mapView)
        
        let pin = Pin(context: text)
        pin.coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        try? text.save()
    }
    
    func updateMapView() {
        guard let pins = fetchedResultsController.fetchedObjects else { return }
        
        for pin in pins {
            if mapView.annotations.contains(where: { pin.compare(to: $0.coordinate) }) { continue }
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotos" {
            let PhotoViewController = segue.destination as! PhotoViewController
            PhotoViewController.pin = sender as? Pin
            
            let goBackButton = UIBarButtonItem()
            goBackButton.title = "GoBack"
            navigationItem.backBarButtonItem = goBackButton

        }
    }
    
    func setupFetched() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false),
        ]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: text, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            updateMapView()
            
        } catch {
            fatalError("Ops The fetch could not be performd: \(error.localizedDescription)")
        }
    }


}

