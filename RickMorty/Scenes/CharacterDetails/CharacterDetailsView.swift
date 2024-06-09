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
    
    @State
    private var size: CGSize = .zero
    
    var statusSymbol: String {
        if store.character.status == "Alive" {
            return "heart.fill"
        } else if store.character.status == "Dead" {
            return "heart.slash.fill"
        } else {
            return ""
        }
    }
        
    var genderSymbol: String {
        if store.character.gender == "Male" {
            return "♂︎ "
        } else if store.character.gender == "Female" {
            return "♀︎ "
        }
        return ""
    }
    
    var body: some View {
        ScrollView {
            WithPerceptionTracking {
                VStack(alignment: .leading, spacing: Margin.large) {
                    AsyncImage(url: store.character.image) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                            .defaultShadow()
                    } placeholder: {
                        Color(uiColor: .systemFill)
                            .overlay(ProgressView())
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                            .defaultShadow()
                    }
                    .frame(maxWidth: .infinity)
                    
                    Text(store.character.name)
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity)
                    
                    GroupBox(label: Label("Info", systemImage: "person.fill")) {
                        VStack {
                            HStack {
                                Text("Status")
                                    .bold()
                                Spacer()
                                Text(store.character.status)
                                Image(systemName: statusSymbol)
                            }
                            .frame(minHeight: size.height)
                            HStack {
                                Text("Gender")
                                    .bold()
                                Spacer()
                                
                                Text(store.character.gender)
                                Text(genderSymbol)
                                    .font(.title)
                            }
                            .geometry(size: $size)
                            HStack {
                                Text("Origin")
                                    .bold()
                                Spacer()
                                Text(store.character.origin.name)
                            }
                            .frame(minHeight: size.height)
                            HStack {
                                Text("Location")
                                    .bold()
                                Spacer()
                                Text(store.character.location.name)
                            }
                            .frame(minHeight: size.height)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    
                    GroupBox(label: Label("Episodes", systemImage: "tv")) {
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
                            .padding()
                        } else if store.isLoading {
                            ProgressView()
                                .padding()
                        } else {
                            VStack {
                                ForEach(store.episodes) { episode in
                                    WithPerceptionTracking {
                                        NavigationLink(destination: EpisodeDetailsView(episode: episode)) {
                                            HStack {
                                                Text("Episode \(episode.episode)")
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .foregroundStyle(.secondary)
                                            }
                                            .padding(.horizontal, Margin.small)
                                            .padding(.vertical, Margin.extraSmall)
                                            .background {
                                                Color(uiColor: .secondarySystemBackground)
                                            }
                                        }
                                        .buttonStyle(.plain)
                                        if episode != store.episodes.last {
                                            Divider()
                                        }
                                    }
                                }
                            }
                            .padding(.top)
                        }
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
                                .accessibilityLabel("Toggle Favourite")
                        }
                        .scaleEffect(store.isFavourite ? 1.2 : 1)
                        .animation(.interpolatingSpring(stiffness: 170, damping: 10), value: store.isFavourite)
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
