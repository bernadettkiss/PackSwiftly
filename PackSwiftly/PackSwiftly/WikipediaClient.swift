//
//  WikipediaClient.swift
//  PackSwiftly
//
//  Created by Bernadett Kiss on 10/29/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import Foundation

enum WikipediaResult {
    case success(info: String)
    case failure
}

class WikipediaClient {
    
    static let shared = WikipediaClient()
    
    struct Constants {
        static let ApiScheme = "https"
        static let ApiHost = "en.wikipedia.org"
        static let ApiPath = "/w/api.php"
    }
    
    struct ParameterKeys {
        static let Format = "format"
        static let Action = "action"
        static let Prop = "prop"
        static let Exintro = "exintro"
        static let ExplainText = "explaintext"
        static let Titles = "titles"
        static let IndexPageIds = "indexpageids"
        static let Redirects = "redirects"
    }
    
    struct ParameterValues {
        static let JSON = "json"
        static let Query = "query"
        static let Extracts = "extracts"
        static let Redirects = "1"
    }
    
    struct ResponseKeys {
        static let Query = "query"
        static let PageIds = "pageids"
        static let Pages = "pages"
        static let PageId = "pageid"
        static let Extract = "extract"
    }
    
    func getInfo(about stringToSearch: String, completionHandler: @escaping (WikipediaResult) -> Void) {
        let urlParameters = wikipediaURLParameters(stringToSearch)
        NetworkManager.shared.request(client: .wikipedia, pathExtension: nil, urlParameters: urlParameters) { networkResponse in
            switch networkResponse {
            case .failure(error: let error):
                debugPrint(error)
                completionHandler(.failure)
                return
            case .success(response: let result):
                let parsedResult = self.process(result as! JSONObject)
                if parsedResult != nil {
                    completionHandler(WikipediaResult.success(info: parsedResult!))
                } else {
                    completionHandler(.failure)
                }
            }
        }
    }
    
    private func wikipediaURLParameters(_ stringToSearch: String) -> Parameters {
        let urlParameters = [
            ParameterKeys.Format: ParameterValues.JSON,
            ParameterKeys.Action: ParameterValues.Query,
            ParameterKeys.Prop: ParameterValues.Extracts,
            ParameterKeys.Exintro: "",
            ParameterKeys.ExplainText: "",
            ParameterKeys.Titles: stringToSearch,
            ParameterKeys.IndexPageIds: "",
            ParameterKeys.Redirects: ParameterValues.Redirects,
            ]
        return urlParameters
    }
    
    private func process(_ result: JSONObject) -> String? {
        guard let query = result[ResponseKeys.Query] as? [String: AnyObject],
            let pageIds = query[ResponseKeys.PageIds] as? [String] else { return (nil) }
        let pageId = pageIds[0]
        
        guard let pages = query[ResponseKeys.Pages] as? [String: AnyObject],
            let page = pages[pageId] as? [String: AnyObject],
            let extract = page[ResponseKeys.Extract] as? String else { return nil }
        return extract
    }
}
