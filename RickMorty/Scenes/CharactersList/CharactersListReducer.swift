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
                return .run { send in
                    let favouriteCharacterIds = try await self.repositoryClient.fetchFavouriteCharacterIds()
                    await send(.favouritesResponse(favouriteCharacterIds))
                }
            case let .favouritesResponse(favouriteCharacterIds):
                state.favouriteCharacterIds = Set(favouriteCharacterIds)
                return .none
            case .fetchNextPage:
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
                state.characters.append(contentsOf: characters)
                state.currentPage = state.currentPage.map({ $0 + 1 }) ?? 1
                state.didReachEnd = !moreAvailable
                state.isLoading = false
                return .none
            case let .networkError(error):
                state.errorMessage = error.localizedDescription
                state.isLoading = false
                return .none
            }
        }
    }
}
