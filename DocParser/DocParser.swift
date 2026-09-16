//
//  DocParser.swift
//  DocParser
//
//  Created by Prabhdeep Singh on 15/09/26.
//

import Foundation
import SwiftSoup

enum ApiError: Error {
    case invalidURL
    case wrongStatusCode
    case invalidStringData
    case invalidURLResponse
    case dataParseError(String)
}

class DocParser {
    static func parseData(url: String = "") async throws {
        let testUrl = "https://docs.google.com/document/d/e/2PACX-1vTMOmshQe8YvaRXi6gEPKKlsC6UpFJSMAk4mQjLm_u1gmHdVVTaeh7nBNFBRlui0sTZ-snGwZM4DBCT/pub"
        let url = "https://docs.google.com/document/d/e/2PACX-1vSvM5gDlNvt7npYHhp_XfsJvuntUhq184By5xO_pA4b_gCWeXb6dM6ZxwN8rE6S4ghUsCj2VKR21oEP/pub"
        
        guard let docUrl = URL(string: url) else {
            print("invalid url")
            throw ApiError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: docUrl)
            
            guard let response = response as? HTTPURLResponse else {
                print("invalidURLResponse")
                throw ApiError.invalidURLResponse
            }
            
            guard response.statusCode == 200 else {
                print("wrongStatusCode")
                throw ApiError.wrongStatusCode
            }
            
            guard let stringData = String(data: data, encoding: .utf8) else {
                print("invalidStringData")
                throw ApiError.invalidStringData
            }
            
            let document = try SwiftSoup.parse(stringData)
            let table = try document.select("table").first()
            
            print("Content is \n\n \(stringData) \n\n\n")
            print("------------------------")
            
            guard let rows = try table?.select("tr") else {
                return
            }
            
            let coordinates = try convertToCoordinates(from: rows)
            converToGrid(from: coordinates)
        } catch (let error) {
            print("error getting data \(error.localizedDescription)")
            throw ApiError.dataParseError(error.localizedDescription)
        }
    }
    
    static func convertToCoordinates(from input: Elements) throws -> [CharacterCoordinate] {
        var coordinates: [CharacterCoordinate] = []
        
        for row in input.dropFirst() {
            let cells = try row.select("td")
            
            guard cells.count == 3 else {
                continue
            }
            
            let x = try cells[0].text()
            var character = try cells[1].text()
            let y = try cells[2].text()
            
            guard let xCoordinate = Int(x), let yCoordinate = Int(y) else {
                continue
            }
            
            if character.isEmpty {
                character = " "
            }
            
            let characterCoordinate = CharacterCoordinate(x: xCoordinate, y: yCoordinate, character: character)
            coordinates.append(characterCoordinate)
        }
        print("cooridnate are \(coordinates)")
        return coordinates
    }
    
    static func converToGrid(from coordinates: [CharacterCoordinate]) {
        let maxX = coordinates.map(\.x).max() ?? 0
        let maxY = coordinates.map(\.y).max() ?? 0
        
        var grid = Array(repeating: Array(repeating: " ", count: maxX + 1), count: maxY + 1)
        
        for coordinate in coordinates {
            grid[coordinate.y][coordinate.x] = String(coordinate.character)
        }
        
        for row in grid.reversed() {
            print(row.joined())
        }
    }
    
}

struct CharacterCoordinate {
    let x: Int
    let y: Int
    let character: String
}

