//
//  APIOperations.swift
//  SimplifiedNetworkSDK
//
//  Created by Dawinder on 09/02/24.
//

import Foundation
import Alamofire

class APIOperation: Operation {
    let url: String
    let method: HTTPMethod
    let parameters: Parameters?
    let completion: (Result<Data, Error>) -> Void
    
    init(url: String, method: HTTPMethod, parameters: Parameters?, completion: @escaping (Result<Data, Error>) -> Void) {
        self.url = url
        self.method = method
        self.parameters = parameters
        self.completion = completion
    }
    
    override func main() {
        guard !isCancelled else { return }
        
        AF.request(url, method: method, parameters: parameters)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    self.completion(.success(data))
                case .failure(let error):
                    self.completion(.failure(error))
                }
            }
    }
}
