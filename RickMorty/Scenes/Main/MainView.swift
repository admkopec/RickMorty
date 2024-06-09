//
//  MainView.swift
//  RickMorty
//
//  Created by Adam Kopeć on 08/06/2024.
//

import SwiftUI
import ComposableArchitecture

struct MainView: View {
    @State
    private var isShowingOnboarding = true
    
    var body: some View {
        if isShowingOnboarding {
            OnboardingView(isPresented: $isShowingOnboarding)
                .transition(AnyTransition.move(edge: .top))
        } else {
            NavigationView {
                CharactersListView(store: Store(initialState: CharactersListReducer.State()) { CharactersListReducer() })
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                withAnimation {
                                    isShowingOnboarding = true
                                }
                            } label: {
                                Image(systemName: "chevron.up")
                                    .font(.body.bold())
                            }
                            .buttonStyle(.bordered)
                            .clipShape(Circle())
                        }
                    }
            }
            .navigationViewStyle(.stack)
            .transition(AnyTransition.move(edge: .bottom))
        }
    }
}

#Preview {
    MainView()
}
