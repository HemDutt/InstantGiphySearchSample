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
    case badRequest
    case emptyResponseData
    case unknownError
}

class GiffyRecommendationService : GiffyRecommendationServiceProtocol{
    private let apiKey = "aLg1bNA4WsJuKJuk0Zbh1M4622bnRG8D"
    private let baseURL = "https://api.giphy.com/v1/tags/related/"
    private let urlSession : URLSession

    init(session : URLSession) {
        urlSession = session
    }

    func requestRecommendationsFor(searchedText : String, completionHandler: @escaping ([GiffyStruct]?, GiffyServiceError?) -> Void){
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
        urlSession.finishTasksAndInvalidate()
    }

    private func getURLFor(searchText: String) -> URL?{
        guard let baseurl = URL(string: baseURL), let urlEncodedString = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }

        var urlComponents = URLComponents(url: baseurl.appendingPathComponent(urlEncodedString), resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
        ]

        return urlComponents?.url
    }
}
