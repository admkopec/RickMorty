//
//  CharacterListItemView.swift
//  RickMorty
//
//  Created by Adam Kopeć on 09/06/2024.
//

import SwiftUI

struct CharacterListItemView: View {
    let character: Character
    let isFavourite: Bool
    
    @State private var imageId = UUID()
    
    var body: some View {
        HStack {
            AsyncImage(url: character.image) { phase in
                if let image = phase.image {
                    // Loaded image
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } else if let error = phase.error {
                    // Error View
                    Color(uiColor: .systemFill)
                        .overlay(Image(systemName: "exclamationmark.triangle.fill"))
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .onAppear {
                            // Retry if loading gets cancelled by LazyVStack, but we're still visible
                            if (error as? URLError)?.code == .cancelled {
                                imageId = UUID()
                            }
                        }
                } else {
                    // Placeholder View
                    Color(uiColor: .systemFill)
                        .overlay(ProgressView())
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                }
            }
            .id(imageId)
            
            Text(character.name)
            
            Spacer()
            
            if isFavourite {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
            }
            
            // Disclosure Indicator
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, Margin.small)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    CharacterListItemView(character: Character.preview, isFavourite: false)
}
