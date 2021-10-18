//
//  SessionUtility.swift
//  InstantGiphySearch
//
//  Created by Hem Sharma on 18/10/21.
//

import Foundation

/// Utility class to configure a URLSession
class SessionUtility{
    static func getDefaultSessionConfig() -> URLSessionConfiguration{
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10.0
        sessionConfig.timeoutIntervalForResource = 10.0
        return sessionConfig
    }
}
