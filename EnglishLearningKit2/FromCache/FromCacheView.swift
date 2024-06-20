//
//  FromCacheView.swift
//  EnglishLearningKit2
//
//  Created by Em bé cute on 6/20/24.
//

import Foundation
import SwiftUI
import NaturalLanguage

struct FromCacheView: View {
    @ObservedObject private var state = FromCacheState()
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            listView
            Spacer()
            contentView
            searchTextField
                .padding()
                .background(state.validateColor)
                .cornerRadius(10)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(ignoresSafeAreaEdges: .top)
        .preferredColorScheme(.dark)
        .onAppear {
            switch postag {
            case "Noun":
                state.items = state.listNoun
            case "Verb":
                state.items = state.listVerb
            case "Adjective":
                state.items = state.listAdjective
            case "Adverb":
                state.items = state.listAdverb
            case "Pronoun":
                state.items = state.listPronoun
            default:
                state.items = state.listNoun
            }
            state.currentText = state.displayedString
            state.textToSpeech(state.displayedString)
            state.onAppear = true
        }
    }
}

private extension FromCacheView {
    var titleView: some View {
        Text("Text editing")
            .font(.largeTitle)
            .frame(maxWidth: .infinity, alignment: .center)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    var contentView: some View {
        Text(state.displayedString)
            .font(.system(size: 50))
            .bold()
            .font(.system(size: 30))
    }
    
    var searchTextField: some View {
        TextField(state.displayedString, text: $state.searchText)
            .autocorrectionDisabled(true)
            .font(.system(size: 50, weight: .bold))
            .padding()
            .frame(width: 650, height: 60)
//            .textInputAutocapitalization(.never)
            .focused($isFocused)
            .onChange(of: state.searchText) { newValue in
                state.validateSuccessForPartOfSpeech()
                if state.onSuccess {
                    state.removeRandomItem()
                    state.searchText = ""
                }
            }
            .onSubmit {
                state.removeRandomItem()
                state.searchText = ""
                isFocused = true
            }
    }
}

extension FromCacheView {
    var listView: some View {
        ScrollView(.vertical) {
            LazyVStack {
                ForEach(Array(state.itemsDisplayed.enumerated()), id: \.offset) { index, item in
                    if index == 0 {
                        Text("got: \(state.itemsDisplayed.count - 1) - have: \(state.items.count)")
                            .font(.system(size: 30))
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .background(Color.secondary)
    }
}

#Preview {
    FromCacheView()
}
