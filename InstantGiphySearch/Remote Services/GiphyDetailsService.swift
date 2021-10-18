//
//  GiphyDetailsService.swift
//  InstantGiphySearch
//
//  Created by Hem Sharma on 18/10/21.
//

import Foundation

class GiphyDetailsService : GiphyDetailsServiceProtocol{
    private let apiKey = "aLg1bNA4WsJuKJuk0Zbh1M4622bnRG8D"
    private let baseURL = "https://api.giphy.com/v1/gifs/search"
    private let urlSession : URLSession
    
    /// Intialize URLSession object
    /// - Parameter session: Injected session
    init(session : URLSession) {
        urlSession = session
    }

    func requestSearchResultsFor(searchedText : String, completionHandler: @escaping (String?, GiphyServiceError?) -> Void){

        guard let url = getURLFor(searchText: searchedText) else {
            completionHandler(nil, .badRequest)
            return
        }
        let request = URLRequest(url: url)

        let task = urlSession.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in

            guard error == nil else {
                //Log error
                return
            }

            let statusCode = (response as! HTTPURLResponse).statusCode
            switch statusCode {
            case 200..<300:
                //Parse data
                if let data = data {
                    let stringData = String(decoding: data, as: UTF8.self)
                    completionHandler(stringData,nil)
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
        urlSession.finishTasksAndInvalidate()
    }

    /// Construct URL with query parameters for fetching Giphy details
    /// - Parameter searchText: Text for which recommendations are requested
    /// - Returns: URL for fetching Giphy details
    private func getURLFor(searchText: String) -> URL?{
        guard let baseurl = URL(string: baseURL), let urlEncodedString = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        var urlComponents = URLComponents(url: baseurl, resolvingAgainstBaseURL: false)

        urlComponents?.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "q", value: urlEncodedString),
            URLQueryItem(name: "limit", value: "25"),
            URLQueryItem(name: "offset", value: "0"),
            URLQueryItem(name: "rating", value: "g"),
            URLQueryItem(name: "lang", value: "en"),
        ]

        return urlComponents?.url
    }
}
