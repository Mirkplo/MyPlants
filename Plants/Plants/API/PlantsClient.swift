//
//  PlantsClient.swift
//  Plants
//
//  Created by Mirko Poli on 14/06/20.
//  Copyright © 2020 Mirko Poli. All rights reserved.
//

import Foundation

class PlantsClient {
    
    static let apiKey: String = "bUhtV1AyRzJJbkJ1M0UydEFtM09vZz09"
    static let numberPerPage = 5
    
    enum Endpoints {
        static let base: String = "https://trefle.io/api/"
        static let familiesAdd: String = "families"
        static let plantsAdd: String = "plants"
        static let tokenAdd: String = "?token=\(PlantsClient.apiKey)"
        
        case getPlantInfo(Int32)
        case getByName(String)
        
        var stringValue: String {
            switch self {
            case .getPlantInfo(let id):
                return Endpoints.base + Endpoints.plantsAdd + "/\(id)" + Endpoints.tokenAdd
            case .getByName (let name):
                return Endpoints.base + Endpoints.plantsAdd + Endpoints.tokenAdd + "&page_size=\(PlantsClient.numberPerPage)" + "&q=\(name)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
        
    }
    
    @discardableResult class func taskForGETRequest<ResponseType: Codable>(url: URL, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void ) -> URLSessionTask {
        let task = URLSession.shared.dataTask(with: url) {
            data, response, error in
            guard let data = data else {
                completion(nil, error)
                return
            }
            let decoder = JSONDecoder()
            do {
                print("Response Object: \(response)")
                print("Data: \(data)")
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        return task
    }

    class func getPlantInfo(id: Int32, completion: @escaping ([PlantInfo]?, Error?) -> Void){
        taskForGETRequest(url: Endpoints.getPlantInfo(id).url, response: [PlantInfo].self) { (response, error) in
            if let response = response {
                print("getPlantInfo success")
                completion(response, nil)
            } else {
                print("Error in getPlantInfo")
                print(error?.localizedDescription ?? "error unknown")
                completion(nil, error)
            }
        }
    }
    
    class func getPlants(name: String, completion: @escaping ([Plants]?, Error?) -> Void){
        taskForGETRequest(url: Endpoints.getByName(name).url, response: [Plants].self) { (response, error) in
            if let response = response {
                print("getPlants success")
                if response.count == 0 {
                    print("Empty array")
                } else {
                    print("Full array")
                }
                completion(response, nil)
            } else {
                print("Error in getPlants")
                print(error?.localizedDescription ?? "error unknown")
                completion(nil, error)
            }
        }
    }
}
