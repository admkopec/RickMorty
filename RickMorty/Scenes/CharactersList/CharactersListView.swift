//
//  CharactersListView.swift
//  RickMorty
//
//  Created by Adam Kopeć on 08/06/2024.
//

import SwiftUI
import ComposableArchitecture

struct CharactersListView: View {
    @Perception.Bindable var store: StoreOf<CharactersListReducer>
    
    var body: some View {
        ScrollView {
            WithPerceptionTracking {
                LazyVStack {
                    ForEach(store.characters) { character in
                        WithPerceptionTracking {
                            NavigationLink(destination: 
                                            CharacterDetailsView(store: Store(initialState: CharacterDetailsReducer.State(character: character), reducer: { CharacterDetailsReducer() }))
                            ) {
                                // Display favourite badge if character's ID is in favourites
                                CharacterListItemView(character: character, isFavourite: store.favouriteCharacterIds.contains(character.id))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    if let errorMsg = store.errorMessage {
                        VStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.largeTitle)
                                .padding(.bottom, Margin.extraSmall)
                            Text("Could not load data!")
                                .font(.subheadline)
                                .bold()
                            Text(errorMsg)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    } else if store.didReachEnd {
                        VStack {
                            Text("🎉")
                                .font(.headline)
                            Text("That's all!")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                        .padding(.top)
                    } else if store.isLoading {
                        ProgressView()
                    } else {
                        ProgressView()
                            .onAppear {
                                store.send(.fetchNextPage)
                            }
                    }
                }
                .padding()
                .onAppear {
                    store.send(.fetchFavourites)
                }
                .searchable(text: $store.searchQuery.sending(\.searchQueryChanged), prompt: "Search by name")
            }
        }
        .navigationTitle("Characters")
    }
}

#Preview {
    NavigationView {
        CharactersListView(
            store: Store(initialState: CharactersListReducer.State(),
                         reducer: {
                             CharactersListReducer()
                         })
        )
    }
}
