//
//  PartOfSpeechView.swift
//  EnglishLearningKit2
//
//  Created by Em bé cute on 6/16/24.
//

import Foundation
import Translation
import SwiftUI
import NaturalLanguage
import Combine

struct PartOfSpeechView: View {
    @ObservedObject private var state = PartOfSpeechState()
    @StateObject private var textObserver = TextFieldObserver()
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                inputTextFieldView
                inputCopyTextFieldView
                partOfSpeechToggleView
                listPartOfSpeech
                listParthOfSpeechOther
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .colorScheme(.dark)
    }
    
    private var inputTextFieldView: some View {
        HStack {
            TextFieldWithDebounce(debouncedText: $state.typingText)
                .frame(height: 51)
                .font(.title)
                .padding()
                .onChange(of: state.typingText) { oldValue, newValue in
                    state.analyzeText(inputText: newValue)
                }.onSubmit {
                    state.analyzeText(inputText: state.typingText)
                }
            
            Button(action: {
                if let clipboardText = UIPasteboard.general.string {
                    state.typingText = clipboardText
                    state.analyzeText(inputText: state.typingText)
                }
            }) {
                Image(systemName: "doc.on.clipboard")
                    .font(.subheadline)
                    .padding()
            }
        }
    }
    
    @ViewBuilder
    private var inputCopyTextFieldView: some View {
        if #available(iOS 17.4, *) {
            Text(state.typingText)
                .foregroundColor(.white)
                .font(.system(size: 16))
                .onTapGesture {
                    state.showTranslation.toggle()
                }
                .translationPresentation(isPresented: $state.showTranslation,text: state.typingText)
                .readSize { size in
                    state.textSize = size
                }
        } else {
            Text(state.typingText)
                .foregroundColor(.white)
                .font(.system(size: 16))
                .onTapGesture {
                    state.showTranslation.toggle()
                }
                .readSize { size in
                    state.textSize = size
                }
        }
    }
    
    private var wrappingTextView: some View {
        Group {
            MultilineHStack(state.partOfSpeechMerged) { item in
                Text("\(item.word) ")
                    .foregroundColor(state.colorForPartOfSpeech(item.partOfSpeech))
                    .font(.system(size: 16))
            }
        }
        .frame(height: state.textSize.height)
    }
    
    private var partOfSpeechToggleView: some View {
        HStack {
            Toggle(isOn: $state.isOnDuplicate, label: {
                Text("")
            }).onChange(of: state.isOnDuplicate) { _,newValue in
                state.analyzeText(inputText: state.typingText)
            }
            .frame(width: 45)
            Spacer()
        }
    }
    
    private var listPartOfSpeech: some View {
        LazyVGrid(columns: state.columns, spacing: 8) {
            ForEach(state.listMainPartOfSpeech, id: \.self) { posTag in
                let filteredItems = state.partOfSpeechTags.filter { $0.partOfSpeech == posTag }
                if !filteredItems.isEmpty {
                    VStack(spacing: 5) {
                        Group { 
                            Text("\(posTag)")
                                .foregroundColor(state.colorForPartOfSpeech(posTag))
                                .font(.headline) + Text(state.displayCountString(posTag: posTag)).font(.headline)
                        }.onTapGesture {
                            state.isOnDuplicate = true
                            SharingInputListString.listString = state.partOfSpeechTags.filter { $0.partOfSpeech == posTag }.map { $0.word }
                        }
                            
                        ScrollView {
                            LazyVStack(spacing: 5) {
                                ForEach(Array(filteredItems.enumerated()), id: \.offset) { index, tag in
                                    HStack {
                                        Text(state.displayMainOptionString(text: tag.word))
                                            .foregroundColor(state.colorForPartOfSpeech(tag.partOfSpeech))
                                        Spacer()
                                        Text(" • \(tag.index)")
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
            }
        }
    }
    
    private var listParthOfSpeechOther: some View {
        LazyVGrid(columns: state.columns, spacing: 8) {
            ForEach(state.listSubPartOfSpeech, id: \.self) { posTag in
                let filteredItems = state.partOfSpeechTagsOther.filter { $0.partOfSpeech == posTag }
                if !filteredItems.isEmpty {
                    VStack(spacing: 5) {
                        Text("\(posTag)")
                            .foregroundColor(state.colorForPartOfSpeech(posTag))
                            .font(.headline) + Text(state.displayCountStringOther(posTag: posTag)).font(.headline)
                        ScrollView {
                            LazyVStack(spacing: 5) {
                                ForEach(Array(filteredItems.enumerated()), id: \.offset) { index, tag in
                                    HStack {
                                        let text = "• \(tag.word)"
                                        if #available(iOS 17.4, *) {
                                            Text(text)
                                                .foregroundColor(state.colorForPartOfSpeech(tag.partOfSpeech))
                                        }
                                        Spacer()
                                        Text(" • \(tag.index)")
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                } else {
                    EmptyView()
                }
            }
        }
    }
}

struct PartOfSpeechView_Previews: PreviewProvider {
    static var previews: some View {
        PartOfSpeechView()
    }
}
