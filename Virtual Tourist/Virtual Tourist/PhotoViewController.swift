//
//  PhotoViewController.swift
//  Virtual Tourist
//
//  Created by Najd  on 20/11/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoViewController: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var theactivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var button: UIBarButtonItem!
    @IBOutlet weak var altMassage: UILabel!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var pin: Pin!
    var pageNumber = 1
    var isDeletingEverything = false
    var context: NSManagedObjectContext {
        return DataController.shared.viewContext
    }
    var checkAvailblePhotos: Bool {
        return (fetchedResultsController.fetchedObjects?.count ?? 0) != 0
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        fetchedResultsController = nil

    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupResults()
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    func updateUI(processing: Bool) {
        collectionView.isUserInteractionEnabled = !processing
        if processing {
            button.title = ""
            theactivityIndicator.startAnimating()
            
    } else {
            theactivityIndicator.stopAnimating()
            button.title = "New Collection"
        }
    }
    @IBAction func buttonTapped(_ sender: Any) {
        updateUI(processing: true)
        
        if checkAvailblePhotos {
            isDeletingEverything = true
            for photo in fetchedResultsController.fetchedObjects! {
                context.delete(photo)
            }
            try? context.save()
            isDeletingEverything = false
        }
        
        API.getPhotosUrls(with: pin.coordinate, pageNumber: pageNumber) { (urls, error, errorMessage) in
            DispatchQueue.main.async {
                
                self.updateUI(processing: false)
                
                guard (errorMessage == nil) && (error == nil)   else {
                    self.alert(title: "Error",
                               message: error?.localizedDescription ?? errorMessage)
                    return
                }
                
                guard let urls = urls, !urls.isEmpty else {
                    self.altMassage.isHidden = false
                    return
                }
                
                for url in urls {
                    let photo = Photo(context: self.context)
                    photo.imageURL = url
                    photo.pin = self.pin
                }
                
                try? self.context.save()
            }
        }
        pageNumber += 1
        
    }
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionView.reloadData()
    }
    
    
    
    func setupResults() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            if checkAvailblePhotos {
                updateUI(processing: false)
            } else {
                buttonTapped(self)
            }
            
        } catch {
            fatalError("Error \(error.localizedDescription)")
        }
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photosCollectionViewCell", for: indexPath) as! photosCollectionViewCell
        let photo = fetchedResultsController.object(at: indexPath)
        cell.imageView.setPhoto(photo)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        context.delete(photo)
        try? context.save()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width-20) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if let indexPath = indexPath, type == .delete && !isDeletingEverything {
            collectionView.deleteItems(at: [indexPath])
            return
        }
        
        if let indexPath = indexPath, type == .insert {
            collectionView.insertItems(at: [indexPath])
            return
        }
        
        if let newIndexPath = newIndexPath, let oldIndexPath = indexPath, type == .move {
            collectionView.moveItem(at: oldIndexPath, to: newIndexPath)
            return
        }
        
        if type != .update {
            collectionView.reloadData()
        }
    }
    
    
    
    func setEmptyMessage(_ message: String) {
        let altMassage = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        altMassage.text = message
        altMassage.textAlignment = .center;
        altMassage.sizeToFit()
        
    }


    
}
