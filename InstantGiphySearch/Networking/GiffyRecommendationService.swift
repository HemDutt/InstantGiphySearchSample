//
//  GiffyRecommendationService.swift
//  InstantGiphySearch
//
//  Created by Hem Sharma on 18/10/21.
//

import Foundation

enum GiffyServiceError
{
    case authenticationError
    case noInternet
    case timeOut
    case badResponseData
    case emptyResponseData
    case unknownError
}

class GiffyRecommendationService : GiffyRecommendationServiceProtocol{
    private let apiKey = "aLg1bNA4WsJuKJuk0Zbh1M4622bnRG8D"
    private let baseURL = "https://api.giphy.com/v1"
    private let recommendationURL = "/tags/related/"

    func requestRecommendationsFor(searchText : String, completionHandler: @escaping ([GiffyStruct]?, GiffyServiceError?) -> Void){
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10.0
        sessionConfig.timeoutIntervalForResource = 10.0
        let request = URLRequest(url: URL(string: "\(baseURL)\(recommendationURL)\(searchText)?api_key=\(apiKey)")!)

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
                        let decoder = JSONDecoder()
                        let searchSuggestions = try decoder.decode(SearchSuggestions.self, from: data)
                        completionHandler(searchSuggestions.data,nil)
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
