//
//  EpisodeDetailsView.swift
//  RickMorty
//
//  Created by Adam Kopeć on 08/06/2024.
//

import SwiftUI
import ComposableArchitecture

struct EpisodeDetailsView: View {
    let episode: Episode
    
    var body: some View {
        ScrollView {
            WithPerceptionTracking {
                VStack {
                    Text(episode.name)
                        .font(.title)
                    Text(episode.episode)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, Margin.large)
                    GroupBox {
                        HStack {
                            Text("First aired")
                                .bold()
                            Spacer()
                            Text(episode.air_date)
                        }
                        HStack {
                            Text("Number of characters")
                                .bold()
                            Spacer()
                            Text(episode.characters.count, format: .number)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(episode.episode)
    }
}

#Preview {
    EpisodeDetailsView(episode: .preview)
}
