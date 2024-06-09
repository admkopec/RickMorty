//
//  CharactersListReducer.swift
//  RickMorty
//
//  Created by Adam Kopeć on 08/06/2024.
//

import ComposableArchitecture

@Reducer
struct CharactersListReducer {
    @ObservableState
    struct State {
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
    }
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.repositoryClient) var repositoryClient
    
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
                return .run { [currentPage = state.currentPage] send in
                    let nextPage = currentPage.map({ $0 + 1 })
                    do {
                        let fetchedCharacters = try await self.apiClient.fetchCharactersForPage(nextPage)
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
                return .none
            case let .networkError(error):
                // Display the error message from the network call
                state.errorMessage = error.localizedDescription
                state.isLoading = false
                return .none
            }
        }
    }
}
