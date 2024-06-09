//
//  APIClient.swift
//  RickMorty
//
//  Created by Adam Kopeć on 08/06/2024.
//

import Foundation
import ComposableArchitecture

struct APIClient {
    var fetchCharactersForPage: (Int?) async throws -> ([Character], moreAvailable: Bool)
    var fetchEpisode: (URL) async throws -> Episode
}

extension APIClient: DependencyKey {
    static let liveValue: APIClient = Self(
        fetchCharactersForPage: { page in
            let worker = RickMortyNetworkWorker()
            return try await worker.fetchCharacters(page: page)
        },
        fetchEpisode: { url in
            let worker = RickMortyNetworkWorker()
            return try await worker.fetchEpisode(url: url)
        }
    )
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}
