//
//  GiffyDetailsService.swift
//  InstantGiphySearch
//
//  Created by Hem Sharma on 18/10/21.
//

import Foundation

class GiffyDetailsService : GiffyDetailsServiceProtocol{
    private let apiKey = "aLg1bNA4WsJuKJuk0Zbh1M4622bnRG8D"
    private let baseURL = "https://api.giphy.com/v1"
    private let searchURL = "/gifs/search"
    //For simplicity keeping these hardcoded for now
    private let searchURLHardcodedSettings = "&limit=25&offset=0&rating=g&lang=en"

    func requestSearchResultsFor(searchText : String, completionHandler: @escaping (String?, GiffyServiceError?) -> Void){
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10.0
        sessionConfig.timeoutIntervalForResource = 10.0
        let request = URLRequest(url: URL(string: "\(baseURL)\(searchURL)?api_key=\(apiKey)&q=\(searchText)\(searchURLHardcodedSettings)")!)

        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        let task = session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in

            guard error == nil else {
                //Log error
                return
            }

            let statusCode = (response as! HTTPURLResponse).statusCode
            switch statusCode {
            case 200..<300:
                //Parse data
                if let data = data {
                    do {
                        // make sure this JSON is in the format we expect
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? String {
                            completionHandler(json, nil)
                        }
                    } catch {
                        completionHandler(nil, .badResponseData)
                    }
                } else {
                    completionHandler(nil, .badResponseData)
                }
            case 408:
                completionHandler(nil, .timeOut)
            case 401:
                completionHandler(nil, .authenticationError)
            default:
                completionHandler(nil, .unknownError)
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
}
