//
//  RussianCitiesJSONParser.swift
//  Coda
//
//  Created by Matoi on 25.02.2023.
//

import SwiftUI

struct City: Codable {
    let coords: Coords
    let district: String
    let name: String
    let population: Int
    let subject: String
}

struct Coords: Codable {
    let lat: String
    let lon: String
}

class RussianCitiesJSONParser {
    static func readLocalJSONFile(forName name: String) -> Data? {
        do {
            if let filePath = Bundle.main.path(forResource: name, ofType: "json") {
                let fileUrl = URL(fileURLWithPath: filePath)
                let data = try Data(contentsOf: fileUrl)
                return data
            }
        } catch {
            print("error: \(error)")
        }
        return nil
    }
    
    static func parse(jsonData: Data) -> [City]? {
        do {
            let decodedData = try JSONDecoder().decode([City].self, from: jsonData)
            return decodedData
        } catch {
            print("error: \(error)")
        }
        return nil
    }
}

