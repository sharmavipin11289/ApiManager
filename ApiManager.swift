//
//  ApiManager.swift
//  DownloadManagerProject
//
//  Created by Vipin Sharma on 13/09/23.
//

import Foundation

class APIManager {
    static let shared = APIManager()
    
    private init() { }
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    struct APIResponse<T> {
        let data: T?
        let response: URLResponse?
    }
    
    func callAPI<T: Decodable>(
        url: URL,
        method: HTTPMethod = .get,
        headers: [String: String]? = nil,
        parameters: [String: Any]? = nil,
        files: [FileUpload]? = nil,
        showLoader: Bool = true
    ) async throws -> APIResponse<T> {
        // Show loader if required
        if showLoader {
            // Show loading indicator
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Set headers if provided
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Calculate the maximum width for the toast
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = createMultipartBody(parameters: parameters, files: files, boundary: boundary)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Parse the response data if T is Decodable
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(T.self, from: data)
            
            // Hide loader if required
            if showLoader {
                // Hide loading indicator
            }
            
            return APIResponse(data: decodedData, response: response)
        } catch {
            // Handle errors
            // Hide loader if required
            if showLoader {
                // Hide loading indicator
            }
            
            throw error
        }
    }
    
    private func createMultipartBody(parameters: [String: Any]?, files: [FileUpload]?, boundary: String) -> Data {
        var body = Data()
        
        // Add parameters if provided
        if let parameters = parameters {
            for (key, value) in parameters {
                body.append(createParameterPart(key: key, value: "\(value)", boundary: boundary))
            }
        }
        
        // Add files if provided
        if let files = files {
            for file in files {
                body.append(createFilePart(file: file, boundary: boundary))
            }
        }
    
        // Close the multipart body
        body.append("--\(boundary)\r\n".data(using: .utf8) ?? Data())
        
        
        return body
    }
    
    private func createParameterPart(key: String, value: String, boundary: String) -> Data {
        var part = Data()
        part.append("--\(boundary)\r\n".data(using: .utf8) ?? Data())
        part.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8) ?? Data())
        part.append("\(value)\r\n".data(using: .utf8) ?? Data())
        return part
    }
    
    private func createFilePart(file: FileUpload, boundary: String) -> Data {
        var part = Data()
        part.append("--\(boundary)\r\n".data(using: .utf8) ?? Data())
        part.append("Content-Disposition: form-data; name=\"\(file.name)\"; filename=\"\(file.fileName)\"\r\n".data(using: .utf8) ?? Data())
        part.append("Content-Type: \(file.mimeType)\r\n\r\n".data(using: .utf8) ?? Data())
        part.append(file.data)
        part.append("\r\n".data(using: .utf8) ?? Data())
        return part
    }
}

struct FileUpload {
    let name: String
    let fileName: String
    let mimeType: String
    let data: Data
}
