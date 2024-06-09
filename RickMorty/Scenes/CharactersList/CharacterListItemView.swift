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
    
    var body: some View {
        HStack {
            AsyncImage(url: character.image) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } placeholder: {
                Color(uiColor: .systemFill)
                    .overlay(ProgressView())
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
            Text(character.name)
            Spacer()
            if isFavourite {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
            }
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    CharacterListItemView(character: Character.preview, isFavourite: false)
}
