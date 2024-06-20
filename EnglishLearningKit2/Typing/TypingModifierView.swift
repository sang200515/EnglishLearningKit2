//
//  TypingModifierView.swift
//  EnglishLearningKit2
//
//  Created by Em bé cute on 6/13/24.
//x

import Foundation
import SwiftUI
import NaturalLanguage

struct TypingModifiersView: View {
    @ObservedObject private var state = ModifierState()
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
            state.currentText = state.displayedItem.keyword
            state.update()
            state.textToSpeech(state.displayedItem.keyword)
            state.onAppear = true
        }
    }
}

private extension TypingModifiersView {
    var titleView: some View {
        Text("Text editing")
            .font(.largeTitle)
            .frame(maxWidth: .infinity, alignment: .center)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    var contentView: some View {
        VStack {
            Text(state.displayedItem.keyword)
                .font(.system(size: 50))
                .bold()
            Text(state.textForSpeech)
            Text(state.displayedItem.ios)
            Text(state.displayedItem.fullText)
            Text(state.displayedItem.description)
        }
        .font(.system(size: 30))
    }
    
    var searchTextField: some View {
        TextField(state.displayedItem.keyword, text: $state.searchText)
            .autocorrectionDisabled(true)
            .font(.system(size: 50, weight: .bold))
            .padding()
            .frame(width: 650, height: 60)
            .textInputAutocapitalization(.never)
            .focused($isFocused)
            .onChange(of: state.searchText) { newValue in
                
                if !SharingInputListString.listString.isEmpty {
                    state.validateSuccessForPartOfSpeech()
                } else {
                    state.validateSuccessForTyping()
                }
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
    
    var popupView: some View {
        VStack(spacing: 20) {
            Text("This is a popup")
                .font(.title)
                .bold()
            
            Text("You're success")
            
            Button("Close") {
                state.onCompleted = false
            }
        }
        .padding()
        .keyboardShortcut(.escape, modifiers: [])
    }
}

extension TypingModifiersView {
    var listView: some View {
        ScrollView(.vertical) {
            LazyVStack {
                ForEach(Array(state.itemsDisplayed.enumerated()), id: \.offset) { index, item in
                    if index == 0 {
                        Text("got: \(state.itemsDisplayed.count - 1) - have: \(state.items.count)")
                            .font(.system(size: 30))
                    } else {
                        fullView(item: item)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .background(Color.secondary)
    }
    
    func fullView(item: Detail) -> some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(item.keyword)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(item.ios)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(item.description)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(hexString: "#1C1C1E"))
        .cornerRadius(20)
        .colorScheme(.dark)
    }
}

#Preview {
    TypingModifiersView()
}
