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
    struct State {
        var character: Character
        var isFavourite: Bool = false
        var episodes: [Episode] = []
    }
    
    enum Action {
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
                return .run { [characterId = state.character.id] send in
                    let isFavourite = try await self.repositoryClient.fetchIsFavouriteCharacterId(characterId)
                    await send(.updateIsFavourite(isFavourite))
                }
            case .toggleFavourite:
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
                return .run { [episodeURLs = state.character.episode] send in
                    do {
                        let fetchedEpisodes = try await episodeURLs.asyncMap({ try await self.apiClient.fetchEpisode($0) })
                        await send(.episodesLoaded(fetchedEpisodes))
                    } catch {
                        await send(.networkError(error))
                    }
                }
            case let .episodesLoaded(episodes):
                state.episodes = episodes
                return .none
            case let .networkError(error):
                return .none
            case let .updateIsFavourite(isFavourite):
                state.isFavourite = isFavourite
                return .none
            }
        }
    }
}
