//
//  OnboardingView.swift
//  RickMorty
//
//  Created by Adam Kopeć on 09/06/2024.
//

import SwiftUI

struct OnboardingView: View {
    @Binding
    var isPresented: Bool
    
    var body: some View {
        VStack {
            Spacer()
            Text("Welcome to Rick & Morty")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom)
            Text("This is a simple app that uses the Rick & Morty API to display characters from the show.")
                .multilineTextAlignment(.center)
                .padding(.bottom)
            Text("Click the button below to view characters!")
            
            Spacer()
            
            Button {
                withAnimation {
                    isPresented = false
                }
            } label: {
                Label("Get Started", systemImage: "chevron.down")
            }
            .buttonStyle(.bordered)
            .clipShape(Capsule())
        }
        .padding()
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
