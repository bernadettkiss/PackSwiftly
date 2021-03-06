//
//  NetworkManager.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 8/28/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import Foundation
import UIKit

typealias Parameters = [String: String]
typealias JSONObject = [String: AnyObject]

enum Client: String {
    case flickr
    case openWeatherMap
    case wikipedia
}

enum NetworkResponse {
    case success(response: Any)
    case failure(error: NSError)
}

class NetworkManager {
    
    static let shared = NetworkManager()
    
    var session = URLSession.shared
    
    func request(client: Client, pathExtension: String?, urlParameters: Parameters, completionHandler: @escaping (_ networkResponse: NetworkResponse) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url = buildURL(client: client, pathExtension: pathExtension, urlParameters: urlParameters)
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            guard error == nil else {
                let error = NetworkResponse.failure(error: error! as NSError)
                completionHandler(error)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let error = NetworkResponse.failure(error: NSError(domain: "GETRequest", code: 1, userInfo: [NSLocalizedDescriptionKey: "Request returned a status code other than 2xx"]))
                completionHandler(error)
                return
            }
            
            guard let jsonData = data else {
                let error = NetworkResponse.failure(error: NSError(domain: "GETRequest", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data was returned by the request"]))
                completionHandler(error)
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! JSONObject
                completionHandler(NetworkResponse.success(response: jsonObject))
            } catch {
                completionHandler(NetworkResponse.failure(error: error as NSError))
            }
        }
        task.resume()
    }
    
    private func buildURL(client: Client, pathExtension: String?, urlParameters: Parameters) -> URL {
        var components = URLComponents()
        
        var pathExtensionString = ""
        if let pathExtension = pathExtension {
            pathExtensionString = "/" + pathExtension
        }
        
        switch client {
        case .flickr:
            components.scheme = FlickrClient.Constants.ApiScheme
            components.host = FlickrClient.Constants.ApiHost
            components.path = FlickrClient.Constants.ApiPath + pathExtensionString
        case .openWeatherMap:
            components.scheme = OpenWeatherMapClient.Constants.ApiScheme
            components.host = OpenWeatherMapClient.Constants.ApiHost
            components.path = OpenWeatherMapClient.Constants.ApiPath + pathExtensionString
        case .wikipedia:
            components.scheme = WikipediaClient.Constants.ApiScheme
            components.host = WikipediaClient.Constants.ApiHost
            components.path = WikipediaClient.Constants.ApiPath + pathExtensionString
        }
        
        components.queryItems = [URLQueryItem]()
        for (key, value) in urlParameters {
            let queryItem = URLQueryItem(name: key, value: value)
            components.queryItems?.append(queryItem)
        }
        return components.url!
    }
    
    func downloadImage(imageURL: URL, completionHandler: @escaping (_ networkResponse: NetworkResponse) -> Void) {
        let request = URLRequest(url: imageURL)
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                let error = NetworkResponse.failure(error: error! as NSError)
                completionHandler(error)
                return
            }
            
            guard let imageData = data else {
                let error = NetworkResponse.failure(error: NSError(domain: "downloadImage", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data was returned by the request"]))
                completionHandler(error)
                return
            }
            completionHandler(NetworkResponse.success(response: imageData))
        }
        task.resume()
    }
}
