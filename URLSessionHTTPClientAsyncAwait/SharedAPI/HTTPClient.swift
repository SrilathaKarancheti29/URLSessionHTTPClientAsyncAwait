//
//  HTTPClient.swift
//  URLSessionHTTPClientAsyncAwait
//
//  Created by Srilatha Karancheti on 2022-05-17.
//

import Foundation

protocol HTTPClient {
    func get(from url: URL) async throws -> (Data, HTTPURLResponse)
}
