//
//  CharacterDetailsView.swift
//  RickMorty
//
//  Created by Adam Kopeć on 08/06/2024.
//

import SwiftUI
import ComposableArchitecture

struct CharacterDetailsView: View {
    let store: StoreOf<CharacterDetailsReducer>
    
    var body: some View {
        ScrollView {
            WithPerceptionTracking {
                VStack(alignment: .leading, spacing: 8*3) {
                    AsyncImage(url: store.character.image) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                            .shadow(radius: 10, y: 4)
                    } placeholder: {
                        Color(uiColor: .systemFill)
                            .overlay(ProgressView())
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                            .shadow(radius: 10, y: 4)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Text(store.character.name)
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity)
                    
                    GroupBox(label: Label("Info", systemImage: "person")) {
                        Text("Status")
                        Text("Gender")
                        Text("Origin")
                        Text("Location")
                    }
                    
                    GroupBox(label: Label("Episodes", systemImage: "tv")) {
                        ProgressView()
                            .padding()
                    }
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            store.send(.toggleFavourite)
                        } label: {
                            Image(systemName: store.isFavourite ? "heart.fill" : "heart")
                                .foregroundStyle(.red)
                        }
                    }
                }
                .onAppear {
                    store.send(.fetchIsFavourite)
                    store.send(.loadEpisodes)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        CharacterDetailsView(store: Store(initialState: CharacterDetailsReducer.State(character: Character.preview), reducer: {
            CharacterDetailsReducer()
        }))
    }
}
