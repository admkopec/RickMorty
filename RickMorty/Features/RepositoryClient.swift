//
//  RepositoryClient.swift
//  RickMorty
//
//  Created by Adam Kopeć on 09/06/2024.
//

import Foundation
import ComposableArchitecture

struct RepositoryClient {
    var fetchFavouriteCharacterIds: () async throws -> [Int]
    var fetchIsFavouriteCharacterId: (Int) async throws -> Bool
    var addFavouriteCharacterId: (Int) async throws -> Void
    var removeFavouriteCharacterId: (Int) async throws -> Void
}

extension RepositoryClient: DependencyKey {
    static let liveValue: RepositoryClient = Self(
        fetchFavouriteCharacterIds: {
            let repository = FavouriteCharacterRepository()
            return try await repository.fetchFavouriteCharacterIds()
        },
        fetchIsFavouriteCharacterId: { id in
            let repository = FavouriteCharacterRepository()
            return try await repository.fetchIsFavourite(for: id)
        },
        addFavouriteCharacterId: { id in
            let repository = FavouriteCharacterRepository()
            return try await repository.addFavourite(for: id)
        },
        removeFavouriteCharacterId: { id in
            let repository = FavouriteCharacterRepository()
            return try await repository.removeFavourite(for: id)
        }
    )
}

extension DependencyValues {
    var repositoryClient: RepositoryClient {
        get { self[RepositoryClient.self] }
        set { self[RepositoryClient.self] = newValue }
    }
}
