//
//  RickMortyNetworkWorker.swift
//  RickMorty
//
//  Created by Adam Kopeć on 08/06/2024.
//

import Foundation

class RickMortyNetworkWorker {
    private let baseURL = URL(string: "https://rickandmortyapi.com/api/")!
    
    /// Fetches a list of characters from the API
    /// - Parameter page: The page number to fetch. If `nil`, fetches the first page.
    /// - Throws: Error if fetching from the API fails
    /// - Returns: Tuple containing an array of characters and a boolean indicating if there are more pages to fetch
    func fetchCharacters(page: Int? = nil) async throws -> ([Character], moreAvailable: Bool) {
        let url = baseURL.appendingPathComponent("character")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        if let page {
            components.queryItems = [URLQueryItem(name: "page", value: "\(page)")]
        }
        let request = URLRequest(url: components.url!)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(APIResponse<Character>.self, from: data)
        
        if response.info.next == nil {
            // We reached the end of the list
            return (response.results, false)
        } else {
            // Still more to fetch
            return (response.results, true)
        }
    }
    
    /// Fetches an episode from the API
    /// - Parameter id: The ID of the episode to fetch
    /// - Throws: Error if fetching from the API fails
    /// - Returns: The fetched episode
    func fetchEpisode(id: Int) async throws -> Episode {
        let url = baseURL.appendingPathComponent("episode").appendingPathComponent("\(id)")
        return try await fetchEpisode(url: url)
    }
    
    /// Fetches an episode from the API given its full URL
    /// - Parameter url: The URL of the episode to fetch
    /// - Throws: Error if fetching from the API fails
    /// - Returns: The fetched episode
    func fetchEpisode(url: URL) async throws -> Episode {
        let request = URLRequest(url: url)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(Episode.self, from: data)
    }
}
