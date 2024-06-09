//
//  CharactersListReducer.swift
//  RickMorty
//
//  Created by Adam Kopeć on 08/06/2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct CharactersListReducer {
    @ObservableState
    struct State: Equatable {
        var searchQuery = ""
        var currentPage: Int?
        
        var isLoading = false
        var didReachEnd = false
        var errorMessage: String?
        
        var characters: IdentifiedArrayOf<Character> = []
        // Using a set to store favourite character IDs for faster lookups
        var favouriteCharacterIds: Set<Int> = []
    }
    
    enum Action {
        case fetchFavourites
        case fetchNextPage
        case favouritesResponse([Int])
        case pageResponse(([Character], moreAvailable: Bool))
        case networkError(Error)
        case searchQueryChanged(String)
    }
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.repositoryClient) var repositoryClient
    
    enum EffectID: Hashable {
        case searchQueryChanged
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchFavourites:
                // Fetch the favourite character IDs using repository client
                return .run { send in
                    let favouriteCharacterIds = try await self.repositoryClient.fetchFavouriteCharacterIds()
                    await send(.favouritesResponse(favouriteCharacterIds))
                }
            case let .favouritesResponse(favouriteCharacterIds):
                state.favouriteCharacterIds = Set(favouriteCharacterIds)
                return .none
            case .fetchNextPage:
                // Fetch the next page of characters using API client
                state.isLoading = true
                return .run { [currentPage = state.currentPage, query = state.searchQuery] send in
                    let nextPage = currentPage.map({ $0 + 1 })
                    do {
                        let fetchedCharacters = try await self.apiClient.fetchCharactersForPage(nextPage, query)
                        await send(.pageResponse(fetchedCharacters))
                    } catch {
                        await send(.networkError(error))
                    }
                }
            case let .pageResponse((characters, moreAvailable)):
                // Append the fetched characters to the list
                state.characters.append(contentsOf: characters)
                // Update the current page number
                state.currentPage = state.currentPage.map({ $0 + 1 }) ?? 1
                // Determine whether we should try to load more pages next time
                state.didReachEnd = !moreAvailable
                state.isLoading = false
                state.errorMessage = nil
                return .none
            case let .networkError(error):
                // Display the error message from the network call
                if let apiError = error as? APIError {
                    state.errorMessage = apiError.message
                } else {
                    state.errorMessage = error.localizedDescription
                }
                state.isLoading = false
                return .none
            case let .searchQueryChanged(query):
                // Fetch characters matching the search query
                if query != state.searchQuery {
                    state.searchQuery = query
                    state.characters = []
                    state.currentPage = nil
                    state.didReachEnd = false
                    state.isLoading = true

                    if query.isEmpty {
                        return .run { send in
                            await send(.fetchNextPage)
                        }
                    }
                    
                    return .run { [query = state.searchQuery] send in
                        do {
                            let fetchedCharacters = try await self.apiClient.fetchCharactersForPage(nil, query)
                            await send(.pageResponse(fetchedCharacters))
                        } catch {
                            await send(.networkError(error))
                        }
                    }.debounce(id: EffectID.searchQueryChanged, for: 0.5, scheduler: DispatchQueue.main)
                } else {
                    return .none
                }
            }
        }
    }
}
