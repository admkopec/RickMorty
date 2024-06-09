//
//  CharacterDetailsReducerTests.swift
//  RickMortyTests
//
//  Created by Adam Kopeć on 09/06/2024.
//

import XCTest
import ComposableArchitecture

@testable import RickMorty

final class CharacterDetailsReducerTests: XCTestCase {

    @MainActor
    func testEpisodesFetching() async throws {
        let store = TestStore(initialState: CharacterDetailsReducer.State(character: .preview)) {
            CharacterDetailsReducer()
        } withDependencies: {
            $0.apiClient.fetchEpisode = { url in
                return Episode.preview
            }
            $0.repositoryClient.fetchIsFavouriteCharacterId = { _ in
                return false
            }
        }
        
        await store.send(.loadEpisodes) {
            $0.isLoading = true
        }
        await store.receive(\.episodesLoaded) {
            $0.isLoading = false
            $0.episodes = [.preview]
        }
    }
    
    @MainActor
    func testEpisodesFetchingError() async throws {
        let store = TestStore(initialState: CharacterDetailsReducer.State(character: .preview)) {
            CharacterDetailsReducer()
        } withDependencies: {
            $0.apiClient.fetchEpisode = { url in
                throw APIError(message: "Test error")
            }
            $0.repositoryClient.fetchIsFavouriteCharacterId = { _ in
                return false
            }
        }
        
        await store.send(.loadEpisodes) {
            $0.isLoading = true
        }
        
        await store.receive(\.networkError) {
            $0.isLoading = false
            $0.errorMessage = "Test error"
        }
    }
    
    @MainActor
    func testFavouriteToggling() async throws {
        let store = TestStore(initialState: CharacterDetailsReducer.State(character: .preview)) {
            CharacterDetailsReducer()
        } withDependencies: {
            $0.apiClient.fetchEpisode = { url in
                return Episode.preview
            }
            $0.repositoryClient.fetchIsFavouriteCharacterId = { _ in
                return false
            }
            $0.repositoryClient.addFavouriteCharacterId = { _ in }
            $0.repositoryClient.removeFavouriteCharacterId = { _ in }
        }
        
        await store.send(.toggleFavourite)
        await store.receive(\.updateIsFavourite) {
            $0.isFavourite = true
        }
        
        await store.send(.toggleFavourite)
        await store.receive(\.updateIsFavourite) {
            $0.isFavourite = false
        }
    }
    
    @MainActor
    func testFavouriteFetching() async throws {
        let store = TestStore(initialState: CharacterDetailsReducer.State(character: .preview)) {
            CharacterDetailsReducer()
        } withDependencies: {
            $0.apiClient.fetchEpisode = { url in
                return Episode.preview
            }
            $0.repositoryClient.fetchIsFavouriteCharacterId = { _ in
                return true
            }
        }
        
        await store.send(.fetchIsFavourite)
        await store.receive(\.updateIsFavourite) {
            $0.isFavourite = true
        }
    }
}
