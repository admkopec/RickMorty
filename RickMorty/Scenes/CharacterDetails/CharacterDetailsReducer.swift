//
//  CharacterDetailsReducer.swift
//  RickMorty
//
//  Created by Adam Kopeć on 09/06/2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct CharacterDetailsReducer {
    @ObservableState
    struct State: Equatable, Sendable {
        var character: RickMorty.Character
        var isFavourite: Bool = false
        var episodes: [Episode] = []
        
        var isLoading = false
        var errorMessage: String?
    }
    
    enum Action: Sendable {
        case fetchIsFavourite
        case loadEpisodes
        case toggleFavourite
        case updateIsFavourite(Bool)
        case episodesLoaded([Episode])
        case networkError(Error)
    }
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.repositoryClient) var repositoryClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchIsFavourite:
                // Fetch the favourite status for the character using repository client
                return .run { [characterId = state.character.id] send in
                    let isFavourite = try await self.repositoryClient.fetchIsFavouriteCharacterId(characterId)
                    await send(.updateIsFavourite(isFavourite))
                }
            case .toggleFavourite:
                // Toggle the favourite status for the character using repository client
                return .run { [character = state.character, isFavourite = state.isFavourite] send in
                    if isFavourite {
                        try await self.repositoryClient.removeFavouriteCharacterId(character.id)
                        await send(.updateIsFavourite(false))
                    } else {
                        try await self.repositoryClient.addFavouriteCharacterId(character.id)
                        await send(.updateIsFavourite(true))
                    }
                }
            case .loadEpisodes:
                // Fetch episodes for the character using API client
                state.isLoading = true
                return .run { [episodeURLs = state.character.episode] send in
                    do {
                        let fetchedEpisodes = try await episodeURLs.asyncMap({ try await self.apiClient.fetchEpisode($0) })
                        // Sort the episodes by episode number
                        await send(.episodesLoaded(fetchedEpisodes.sorted(by: { $0.episode < $1.episode })))
                    } catch {
                        await send(.networkError(error))
                    }
                }
            case let .episodesLoaded(episodes):
                // Update the state with the fetched episodes
                state.isLoading = false
                state.episodes = episodes
                return .none
            case let .networkError(error):
                // Display error message from the network call
                state.isLoading = false
                if let apiError = error as? APIError {
                    state.errorMessage = apiError.message
                } else {
                    state.errorMessage = error.localizedDescription
                }
                return .none
            case let .updateIsFavourite(isFavourite):
                // Update the isFavourite status in the state
                state.isFavourite = isFavourite
                return .none
            }
        }
    }
}
