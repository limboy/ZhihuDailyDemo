//
//  Networking.swift
//  ZhihuDaily
//
//  Created by limboy on 08/06/2017.
//  Copyright © 2017 limboy. All rights reserved.
//

// See the accompanying blog post: http://chris.eidhof.nl/posts/tiny-networking-in-swift.html

import Foundation

public enum Method: String { // Bluntly stolen from Alamofire
    case OPTIONS = "OPTIONS"
    case GET = "GET"
    case HEAD = "HEAD"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
    case TRACE = "TRACE"
    case CONNECT = "CONNECT"
}

public struct Resource<A> {
    let path: String
    let method : Method
    let requestBody: NSData?
    let headers : [String:String]
    let parse: (NSData) -> A?
}

public enum Reason: Error {
    case CouldNotParseJSON
    case NoData
    case NoSuccessStatusCode(statusCode: Int)
    case Other(NSError?)
}

public func apiRequest<A>(modifyRequest: ((NSMutableURLRequest) -> ())? = nil, baseURL: URL, resource: Resource<A>, failure: @escaping (Reason, NSData?) -> (), success: @escaping (A) -> ()) {
    let session = URLSession.shared
    let url = baseURL.appendingPathComponent(resource.path)
    let request = NSMutableURLRequest(url: url)
    request.httpMethod = resource.method.rawValue
    request.httpBody = resource.requestBody as Data?
    modifyRequest?(request)
    for (key, value) in resource.headers {
        request.setValue(value, forHTTPHeaderField: key)
    }
    let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                if let responseData = data {
                    if let result = resource.parse(responseData as NSData) {
                        success(result)
                    } else {
                        failure(Reason.CouldNotParseJSON, data as NSData?)
                    }
                } else {
                    failure(Reason.NoData, data! as NSData)
                }
            } else {
                failure(Reason.NoSuccessStatusCode(statusCode: httpResponse.statusCode), data! as NSData)
            }
        } else {
            failure(Reason.Other(error as NSError?), data! as NSData)
        }
    }
    task.resume()
}

// Here are some convenience functions for dealing with JSON APIs
public typealias JSONDictionary = [String:AnyObject]

func decodeJSON(data: NSData) -> JSONDictionary? {
    return (try? JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions())) as? JSONDictionary
}

func encodeJSON(dict: JSONDictionary) -> Data? {
    return dict.count > 0 ? (try? JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions())) : nil
}

public func jsonResource<A>(path: String, method: Method, requestParameters: JSONDictionary = [:], parse: @escaping (JSONDictionary) -> A?) -> Resource<A> {
    
    let f = { decodeJSON(data: $0).flatMap(parse) }
    let jsonBody = encodeJSON(dict: requestParameters)
    let headers = ["Content-Type": "application/json"]
    return Resource(path: path, method: method, requestBody: jsonBody! as NSData, headers: headers, parse: f)
}
