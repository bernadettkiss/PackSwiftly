//
//  FlickrClient.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 8/28/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import Foundation

enum FlickrResult {
    case success(photos: [Photo])
    case failure
}

struct Photo {
    let remoteURL: URL
    var imageData: Data?
}

class FlickrClient {
    
    static let shared = FlickrClient()
    
    func getPhotos(latitude: Double, longitude: Double, text: String, completionHandler: @escaping (FlickrResult) -> Void) {
        if verifyCoordinate(latitude: latitude, longitude: longitude) {
            let urlParameters = flickrURLParameters(latitude: latitude, longitude: longitude, text: text)
            NetworkManager.shared.request(client: .flickr, pathExtension: nil, urlParameters: urlParameters) { networkResponse in
                switch networkResponse {
                case .failure(error: let error):
                    debugPrint(error)
                    completionHandler(.failure)
                    return
                case .success(response: let result):
                    let parsedResult = self.process(result as! JSONObject)
                    if let parsedPhotos = parsedResult {
                        completionHandler(FlickrResult.success(photos: parsedPhotos))
                    } else {
                        completionHandler(.failure)
                    }
                }
            }
        }
    }
    
    private func verifyCoordinate(latitude: Double, longitude: Double) -> Bool {
        if latitude > Constants.SearchLatRange.0 && latitude < Constants.SearchLatRange.1 && longitude > Constants.SearchLonRange.0 && longitude < Constants.SearchLonRange.1 {
            return true
        } else {
            return false
        }
    }
    
    private func flickrURLParameters(latitude: Double, longitude: Double, text: String) -> Parameters {
        let urlParameters = [
            ParameterKeys.Method: ParameterValues.SearchMethod,
            ParameterKeys.APIKey: ParameterValues.APIKey,
            ParameterKeys.BoundingBox: boundingBoxString(latitude: latitude, longitude: longitude),
            ParameterKeys.SafeSearch: ParameterValues.UseSafeSearch,
            ParameterKeys.Extras: ParameterValues.MediumURL,
            ParameterKeys.Format: ParameterValues.ResponseFormat,
            ParameterKeys.NoJSONCallback: ParameterValues.DisableJSONCallback,
            ParameterKeys.PerPage: ParameterValues.PerPage,
            ParameterKeys.Text: text,
            ParameterKeys.Sort: ParameterValues.Sort
        ]
        return urlParameters
    }
    
    private func boundingBoxString(latitude: Double, longitude: Double) -> String {
        let minimumLon = max(longitude - FlickrClient.Constants.SearchBBoxHalfWidth, FlickrClient.Constants.SearchLonRange.0)
        let minimumLat = max(latitude - FlickrClient.Constants.SearchBBoxHalfHeight, FlickrClient.Constants.SearchLatRange.0)
        let maximumLon = min(longitude + FlickrClient.Constants.SearchBBoxHalfWidth, FlickrClient.Constants.SearchLonRange.1)
        let maximumLat = min(latitude + FlickrClient.Constants.SearchBBoxHalfHeight, FlickrClient.Constants.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    private func process(_ result: JSONObject) -> [Photo]? {
        guard let status = result[ResponseKeys.Status] as? String, status == ResponseValues.OKStatus,
            let photosDictionary = result[ResponseKeys.Photos] as? [String: AnyObject], let photoArray = photosDictionary[ResponseKeys.Photo] as? [[String: AnyObject]] else {
                return (nil)
        }
        var parsedPhotos = [Photo]()
        for photoJSON in photoArray {
            if let parsedPhoto = self.photo(fromJSON: photoJSON) {
                parsedPhotos.append(parsedPhoto)
            }
        }
        return (parsedPhotos)
    }
    
    private func photo(fromJSON json: [String: AnyObject]) -> Photo? {
        guard let remoteURLString = json[ResponseKeys.MediumURL] as? String,
            let remoteURL = URL(string: remoteURLString) else {
                return nil
        }
        return Photo(remoteURL: remoteURL, imageData: nil)
    }
}
