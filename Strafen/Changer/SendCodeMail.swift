//
//  SendCodeMail.swift
//  Strafen
//
//  Created by Steven on 11.07.20.
//

import Foundation

/// Used to send code mail
struct SendCodeMail {
    
    /// State of data task
    enum TaskState {
        
        /// Data task passed
        case passed
        
        /// Data task failed
        case failed
    }
    
    /// Shared instance for singelton
    static var shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    /// Sended Code
    var code: String?
    
    /// Send code mail
    mutating func sendMail(to address: String, completionHandler: @escaping (TaskState) -> ()) {
        code = generatedCode
        
        // Get POST parameters
        let parameters: [String : Any] = [
            "email": address,
            "code": code!,
            "key": AppUrls.shared.key
        ]
        
        // Url Request
        var request = URLRequest(url: AppUrls.shared.changer.mailCode)
        request.setValue("Basic \(AppUrls.shared.loginString)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = parameters.percentEncoded
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        // Execute dataTask
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard error == nil else { return completionHandler(.failed) }
            guard let data = data else { return completionHandler(.failed) }
            completionHandler(String(data: data, encoding: .utf8) ?? "" == "success" ? .passed : .failed)
        }.resume()
    }
    
    /// Generates new code
    var generatedCode: String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<8).map{ _ in letters.randomElement()! })
    }
}