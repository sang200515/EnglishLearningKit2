//
//  ContentView.swift
//  EnglishLearningKit2
//
//  Created by Em bé cute on 6/13/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            PartOfSpeechView()
                     .tabItem {
                         Label("PartOfSpeech", systemImage: "list.dash")
                     }

            TypingModifiersView()
                     .tabItem {
                         Label("Typing", systemImage: "square.and.pencil")
                     }
             }.colorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
