//
//  URLSessionHTTPClientTests.swift
//  URLSessionHTTPClientAsyncAwaitTests
//
//  Created by Srilatha Karancheti on 2022-05-17.
//

import XCTest
@testable import URLSessionHTTPClientAsyncAwait

class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromURL_performsGETRequestWithURL() async {
        
        URLProtocolStub.startInterceptingRequests()
        
        let url = URL(string: "http://any-url.com")!
        
        let _ = try? await URLSessionHTTPClient().get(from: url)
        
        URLProtocolStub.observerRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
        }
        
        URLProtocolStub.stopInterceptingRequests()
    }
}

private class URLProtocolStub: URLProtocol {
    private static var stub: Stub?
    private static var requestObserver:((URLRequest) -> Void)?
 
    private struct Stub {
        let error: Error?
        let data: Data?
        let response: URLResponse?
    }
    
    static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
        stub = Stub(error: error, data: data, response: response)
    }
    
    static func observerRequests(observer: @escaping (URLRequest) -> Void) {
        requestObserver = observer
    }

    
    static func startInterceptingRequests() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        stub = nil
        requestObserver = nil
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        requestObserver?(request)
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        
        if let data = URLProtocolStub.stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = URLProtocolStub.stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error  = URLProtocolStub.stub?.error {
            client?.urlProtocol(self, didFailWithError:  error)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}

