//
//  RickMortyNetworkWorkerTests.swift
//  RickMortyTests
//
//  Created by Adam Kopeć on 09/06/2024.
//

import XCTest

@testable import RickMorty

final class RickMortyNetworkWorkerTests: XCTestCase {

    func testFetchingCharacters() async throws {
        let worker = RickMortyNetworkWorker()
        let (characters, moreAvailable) = try await worker.fetchCharacters(page: 1, with: "")
        XCTAssertFalse(characters.isEmpty)
        XCTAssertTrue(moreAvailable)
    }
    
    func testFetchingEpisode() async throws {
        let worker = RickMortyNetworkWorker()
        let episode = try await worker.fetchEpisode(id: 1)
        XCTAssertEqual(episode.id, 1)
    }
}
