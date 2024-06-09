//
//  FavouriteCharacterRepositoryTests.swift
//  RickMortyTests
//
//  Created by Adam Kopeć on 09/06/2024.
//

import XCTest

@testable import RickMorty

final class FavouriteCharacterRepositoryTests: XCTestCase {
    
    func testFetchingFavouriteCharacterIds() async throws {
        let testContext = PersistenceController.preview.container.viewContext
        let repository = FavouriteCharacterRepository(context: testContext)
        let favouriteCharacterIds = try await repository.fetchFavouriteCharacterIds()
        XCTAssertEqual(favouriteCharacterIds.sorted(), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
    }
    
    func testAddingFavouriteCharacter() async throws {
        let testContext = PersistenceController.preview.container.viewContext
        let repository = FavouriteCharacterRepository(context: testContext)
        try await repository.addFavourite(for: 10)
        let favouriteCharacterIds = try await repository.fetchFavouriteCharacterIds()
        XCTAssertEqual(favouriteCharacterIds.sorted(), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        
        try await repository.removeFavourite(for: 10)
    }
    
    func testRemovingFavouriteCharacter() async throws {
        let testContext = PersistenceController.preview.container.viewContext
        let repository = FavouriteCharacterRepository(context: testContext)
        try await repository.removeFavourite(for: 9)
        let favouriteCharacterIds = try await repository.fetchFavouriteCharacterIds()
        XCTAssertEqual(favouriteCharacterIds.sorted(), [0, 1, 2, 3, 4, 5, 6, 7, 8])
        
        try await repository.addFavourite(for: 9)
    }
    
    func testCheckingIfCharacterIsFavourite() async throws {
        let testContext = PersistenceController.preview.container.viewContext
        let repository = FavouriteCharacterRepository(context: testContext)
        let isFavourite = try await repository.fetchIsFavourite(for: 1)
        XCTAssertTrue(isFavourite)
    }
}
