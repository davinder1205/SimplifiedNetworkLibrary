//
//  NetworkManager.swift
//  SimplifiedNetworkSDK
//
//  Created by Dawinder on 09/02/24.
//

import Foundation
import Alamofire

class NetworkManager {
    public static let shared = NetworkManager()
        
        private var baseURL: String?
        private var apiHeaders: HTTPHeaders?
                
        // Method to configure base URL and API headers
        public func configure(baseURL: String, apiHeaders: HTTPHeaders) {
            self.baseURL = baseURL
            self.apiHeaders = apiHeaders
        }
    
    private var currentRequest: DataRequest?
    
    private init() {}
    
    func hitApiWithBlobData(APIName: String, method: HTTPMethod, params: [String: Any]? = nil, loaderHidden: Bool = false, successCallback: @escaping ((Data) -> Void)) {
        guard let url = URL(string: "\(baseURL ?? "")\(APIName)") else {
            print("Invalid URL")
            return
        }
        
        AF.request(url, method: method, parameters: params, headers: apiHeaders)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    successCallback(data)
                    
                case .failure(let error):
                    print("Error:", error.localizedDescription)
                }
            }
    }
    
    func cancelCurrentRequest() {
        currentRequest?.cancel()
    }
    
    func hitAPI(APIName: String, method: HTTPMethod, params: [String: Any]? = nil, successCallback: @escaping ((Data) -> Void)) {
        guard let url = URL(string: "\(baseURL ?? "")\(APIName)") else {
            print("Invalid URL")
            return
        }
        
        AF.request(url, method: method, parameters: params, encoding: JSONEncoding.default, headers: apiHeaders)
            .responseString { response in
                switch response.result {
                case .success:
                    successCallback(response.data ?? Data())
                    
                case .failure(let error):
                    print("Error:", error.localizedDescription)
                }
            }
    }
    
    func uploadDocAPI(APIName: String, method: HTTPMethod, params: [String: Any]? = nil, docType: String = "jpeg", docName: String, successCallback: @escaping ((Data) -> Void)) {
        let stringWithSuffixDropped = docName.split(separator: ".").dropLast().joined(separator: "")
        guard let url = URL(string: "\(baseURL ?? "")\(APIName)") else {
            print("Invalid URL")
            return
        }
        
        AF.upload(multipartFormData: { multipartFormData in
            for data in (params?.enumerated())! {
                let value = data.element
                if value.value is Data {
                    let name = stringWithSuffixDropped.isEmpty ? "\(Int(Date().timeIntervalSince1970))" : stringWithSuffixDropped
                    multipartFormData.append(value.value as! Data, withName: value.key, fileName: "\(name).\(docType)", mimeType: "image/jpeg")
                } else {
                    if let data = (value.value as? String ?? "").data(using: .utf8) {
                        multipartFormData.append(data, withName: value.key)
                    }
                }
            }
        }, to: url, method: .post, headers: apiHeaders)
        .responseString { response in
            switch response.result {
            case .success:
                successCallback(response.data ?? Data())
                
            case .failure(let error):
                print("Error:", error.localizedDescription)
            }
        }
    }
    
    func hitApiWithResponseModel<T: Decodable>(APIName: String, method: HTTPMethod, params: [String: Any]? = nil, loaderHidden: Bool = false, successCallback: @escaping ((T) -> Void), errorCallback: @escaping ((Error) -> Void)) {
        
        guard let url = URL(string: "\(baseURL ?? "")\(APIName)") else {
            print("Invalid URL")
            return
        }
        
        AF.request(url, method: method, parameters: params, headers: apiHeaders)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                        successCallback(decodedResponse)
                    } catch {
                        errorCallback(error)
                    }
                    
                case .failure(let error):
                    errorCallback(error)
                }
            }
    }
}
