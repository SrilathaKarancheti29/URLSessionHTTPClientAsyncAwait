//
//  URLSessionHTTPClient.swift
//  URLSessionHTTPClientAsyncAwait
//
//  Created by Srilatha Karancheti on 2022-05-17.
//

import Foundation

enum ItemLoaderError: Swift.Error {
    case requestFailed
}

class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, response) = try await session.data(from: url)
            if let response = response as? HTTPURLResponse, response.isOK {
                return (data, response)
            } else { throw ItemLoaderError.requestFailed }
        } catch {
            throw error
        }
    }
}


extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }
    
    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
