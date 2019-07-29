//
//  API.swift
//  Virtual Tourist
//
//  Created by Najd  on 20/11/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation
import UIKit
import MapKit

struct API {
    
    static func getPhotosUrls(with coordinate: CLLocationCoordinate2D, pageNumber: Int, completion: @escaping ([URL]?, Error?, String?) -> ()) {
        let methodParameters = [
            Constants.FlickrKeys.Method: Constants.FlickrValues.SearchMethod,
            Constants.FlickrKeys.APIKey: Constants.FlickrValues.APIKey,
            Constants.FlickrKeys.BoundingBox: bboxString(for: coordinate),
            Constants.FlickrKeys.SafeSearch: Constants.FlickrValues.UseSafeSearch,
            Constants.FlickrKeys.Extras: Constants.FlickrValues.MediumURL,
            Constants.FlickrKeys.Format: Constants.FlickrValues.ResponseFormat,
            Constants.FlickrKeys.NoJSONCallback: Constants.FlickrValues.DisableJSONCallback,
            Constants.FlickrKeys.Page: pageNumber,
            Constants.FlickrKeys.PerPage: Constants.FlickrValues.PerPage,
            ] as [String:Any]
        
        
        let requestUrl = URLRequest(url: getURL(from: methodParameters))
        
        let task = URLSession.shared.dataTask(with: requestUrl) { (data, response, error) in
            
            guard (error == nil) else {
                completion(nil, error, nil)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completion(nil, nil, "Sorry it's other than 2xx!")
                return
            }
            
            guard let data = data else {
                completion(nil, nil, "No data was returned !")
                return
            }
            
            //            print(String(data: data, encoding: .utf8)!)
            
            guard let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {
                completion(nil, nil, "Could not parse the data as JSON.")
                return
            }
            
            guard let stat = result["stat"] as? String, stat == "ok" else {
                completion(nil, nil, "Flickr API returned an error. See error code and message in \(result)")
                return
            }
            
            guard let photosDictionary = result["photos"] as? [String:Any] else {
                completion(nil, nil, "Cannot find key 'photos' in \(result)")
                return
            }
            
            guard let photosArray = photosDictionary["photo"] as? [[String:Any]] else {
                completion(nil, nil, "Cannot find key 'photo' in \(photosDictionary)")
                return
            }
            
            let photosURLs = photosArray.compactMap { photoDictionary -> URL? in
                guard let url = photoDictionary["url_m"] as? String else { return nil}
                return URL(string: url)
            }
            
            completion(photosURLs, nil, nil)
        }
        
        task.resume()
    }
    
    static func bboxString(for coordinate: CLLocationCoordinate2D) -> String {
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, -180)
        let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, -90)
        let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, 180)
        let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, 90)
        
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    
    
    static func getURL(from parameters: [String:Any]) -> URL {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest"
        components.queryItems = [URLQueryItem]()
        
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
}
