//
//  CharactersListReducerTests.swift
//  RickMortyTests
//
//  Created by Adam Kopeć on 09/06/2024.
//

import XCTest
import ComposableArchitecture

@testable import RickMorty

final class CharactersListReducerTests: XCTestCase {

    @MainActor
    func testFetchFavourites() async throws {
        let store = TestStore(initialState: CharactersListReducer.State()) {
            CharactersListReducer()
        } withDependencies: {
            $0.repositoryClient.fetchFavouriteCharacterIds = {
                return [1, 2, 3]
            }
            $0.repositoryClient.fetchIsFavouriteCharacterId = { _ in
                return false
            }
        }
        
        await store.send(.fetchFavourites)
        await store.receive(\.favouritesResponse) {
            $0.favouriteCharacterIds = [1, 2, 3]
        }
    }
    
    @MainActor
    func testFetchNextPage() async throws {
        let store = TestStore(initialState: CharactersListReducer.State()) {
            CharactersListReducer()
        } withDependencies: {
            $0.apiClient.fetchCharactersForPage = { page, query in
                return ([.preview], moreAvailable: false)
            }
            $0.repositoryClient.fetchFavouriteCharacterIds = {
                return []
            }
            $0.repositoryClient.fetchIsFavouriteCharacterId = { _ in
                return false
            }
        }
        
        await store.send(.fetchNextPage) {
            $0.isLoading = true
        }
        await store.receive(\.pageResponse) {
            $0.isLoading = false
            $0.currentPage = 1
            $0.characters = [.preview]
            $0.didReachEnd = true
        }
    }
    
    @MainActor
    func testFetchNextPageError() async throws {
        let store = TestStore(initialState: CharactersListReducer.State()) {
            CharactersListReducer()
        } withDependencies: {
            $0.apiClient.fetchCharactersForPage = { page, query in
                throw APIError(message: "Test error")
            }
            $0.repositoryClient.fetchFavouriteCharacterIds = {
                return []
            }
            $0.repositoryClient.fetchIsFavouriteCharacterId = { _ in
                return false
            }
        }
        
        await store.send(.fetchNextPage) {
            $0.isLoading = true
        }
        
        await store.receive(\.networkError) {
            $0.isLoading = false
            $0.errorMessage = "Test error"
        }
    }
    
    @MainActor
    func testSearchQueryChanged() async throws {
        let store = TestStore(initialState: CharactersListReducer.State()) {
            CharactersListReducer()
        } withDependencies: {
            $0.apiClient.fetchCharactersForPage = { page, query in
                return ([.preview], moreAvailable: false)
            }
            $0.repositoryClient.fetchFavouriteCharacterIds = {
                return []
            }
            $0.repositoryClient.fetchIsFavouriteCharacterId = { _ in
                return false
            }
        }
        
        await store.send(.searchQueryChanged("Rick")) {
            $0.searchQuery = "Rick"
            $0.characters = []
            $0.currentPage = nil
            $0.didReachEnd = false
            $0.isLoading = true
        }
        await store.receive(\.pageResponse) {
            $0.isLoading = false
            $0.currentPage = 1
            $0.characters = [.preview]
            $0.didReachEnd = true
        }
    }
}
