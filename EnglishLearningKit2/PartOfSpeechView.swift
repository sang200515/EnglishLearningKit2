//
//  PartOfSpeechView.swift
//  EnglishLearningKit2
//
//  Created by Em bé cute on 6/16/24.
//

import Foundation


import SwiftUI
import NaturalLanguage
struct PartOfSpeechModel {
    let word: String
    let partOfSpeech: String
    let index: Int
}

struct PartOfSpeechView: View {
    @State private var text: String = ""
    @State private var feedbackMessage: String = ""
    @State private var partOfSpeechTags: [PartOfSpeechModel] = [.init(word: "", partOfSpeech: "", index: 0)]
    @State private var partOfSpeechTagsOther: [PartOfSpeechModel] = []
    @State private var partOfSpeechMerged: [PartOfSpeechModel] = []
    
    @FocusState private var isFocused: Bool
    let partOfSpeechOrder: [String] = ["Noun", "Verb", "Adjective", "Adverb","Pronoun"]
    let partOfSpeechOther: [String] = ["ProperNoun", "Determiner", "Particle", "Preposition", "Conjunction", "Interjection", "Classifier", "Idiom", "OtherWord", "OtherWhitespace", "OtherPunctuation", "Other"]
    
    @State private var isOnDuplicate: Bool = true
    var body: some View {
        ScrollView(.vertical){
            VStack(alignment: .leading) {
                HStack {
                    TextField("Type something in English", text: $text)
                        .frame(height: 51)
                        .font(.title)
                        .padding()
                        .onChange(of: text) { oldValue, newValue in
                            analyzeText(text: newValue)
                        }
                    
                    Button(action: {
                        if let clipboardText = UIPasteboard.general.string {
                            text = clipboardText
                            analyzeText(text: text)
                        }
                    }) {
                        Image(systemName: "doc.on.clipboard")
                            .font(.subheadline)
                            .padding()
                    }
                }
              
                .onSubmit {
                    analyzeText(text: text)
                }
                
                Text(text)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                
                MultilineHStack(partOfSpeechMerged) { item in
                    Text("\(item.word) ")
                        .foregroundColor(colorForPartOfSpeech(item.partOfSpeech))
                        .font(.system(size: 16))
                }
                
                partOfSpeechToggle
                    .padding(.top, 24)
                listPartOfSpeech
                listParthOfSpeechOther
                

            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .colorScheme(.dark)
    }
    
    private var partOfSpeechToggle: some View {
        HStack {
            Toggle(isOn: $isOnDuplicate, label: {
                Text("")
            }).onChange(of: isOnDuplicate) { _,newValue in
                analyzeText(text: text)
            }
            .frame(width: 45)
            Spacer()
        }
        
    }
    private func displayCountString(posTag: String) -> String {
        let count = partOfSpeechTags.filter { $0.partOfSpeech == posTag }.count
        return count > 0 ? "(\(count))" : ""
    }
    
    private var listPartOfSpeech: some View {
        LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())], spacing: 8) {
            ForEach(partOfSpeechOrder, id: \.self) { posTag in
                VStack(spacing: 5) {
                    Text("\(posTag)")
                        .foregroundColor(colorForPartOfSpeech(posTag))
                        .font(.headline) + Text(displayCountString(posTag: posTag)).font(.headline)
                    ScrollView {
                        LazyVStack(spacing: 5) {
                            ForEach(Array(partOfSpeechTags.filter { $0.partOfSpeech == posTag }.enumerated()), id: \.offset) { index, tag in
                                HStack {
                                    Text("• \(tag.word)")
                                        .foregroundColor(colorForPartOfSpeech(tag.partOfSpeech))
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
    
    private func displayCountStringOther(posTag: String) -> String {
        let count = partOfSpeechTagsOther.filter { $0.partOfSpeech == posTag }.count
        return count > 0 ? "(\(count))" : ""
    }
    
    private var listParthOfSpeechOther: some View {
        LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())], spacing: 8) {
            ForEach(partOfSpeechOther, id: \.self) { posTag in
                VStack(spacing: 5) {
                    Text("\(posTag)")
                        .foregroundColor(colorForPartOfSpeech(posTag))
                        .font(.headline) + Text(displayCountStringOther(posTag: posTag)).font(.headline)
                    ScrollView {
                        LazyVStack(spacing: 5) {
                            ForEach(Array(partOfSpeechTagsOther.filter { $0.partOfSpeech == posTag }.enumerated()), id: \.offset) { index, tag in
                                HStack { 
                                    Text("• \(tag.word)")
                                        .foregroundColor(colorForPartOfSpeech(tag.partOfSpeech))
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
    private func analyzeText(text: String) {
        partOfSpeechTags.removeAll()
        partOfSpeechTagsOther.removeAll()
        partOfSpeechMerged.removeAll()
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        
        let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation]
        var counter: Int = 0
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            counter += 1
            if let tag = tag {
                let word = String(text[tokenRange])
                let partOfSpeech = tag.rawValue
                let newEntry = (word: word, partOfSpeech: partOfSpeech)
                self.partOfSpeechMerged.append(.init(word: newEntry.word, partOfSpeech: newEntry.partOfSpeech, index: counter))
                if partOfSpeechOrder.contains(partOfSpeech) {
                    if isOnDuplicate {
                        if !self.partOfSpeechTags.contains(where: { $0.word == newEntry.word && $0.partOfSpeech == newEntry.partOfSpeech }) {
                            self.partOfSpeechTags.append(.init(word: newEntry.word, partOfSpeech: newEntry.partOfSpeech, index: counter))
                        }
                        
                    } else {
                        self.partOfSpeechTags.append(.init(word: newEntry.word, partOfSpeech: newEntry.partOfSpeech, index: counter))
                        
                    }
                } else {
                    if isOnDuplicate {
                        if !self.partOfSpeechTagsOther.contains(where: { $0.word == newEntry.word && $0.partOfSpeech == newEntry.partOfSpeech }) {
                            self.partOfSpeechTagsOther.append(.init(word: newEntry.word, partOfSpeech: newEntry.partOfSpeech, index: counter))
                        }
                    }else {
                        self.partOfSpeechTagsOther.append(.init(word: newEntry.word, partOfSpeech: newEntry.partOfSpeech, index: counter))
                    }
                }
            }
            return true
        }
        
        // Sort partOfSpeechTags based on lexical classes: Noun > Verb >  Adjective > Adverb > Pronoun
        self.partOfSpeechTags.sort { (first, second) -> Bool in
            return sortOrder(for: first.partOfSpeech) < sortOrder(for: second.partOfSpeech)
        }
    }
    
    private func sortOrder(for partOfSpeech: String) -> Int {
        switch partOfSpeech {
        case "Noun":
            return 0
        case "Verb":
            return 1
        case "Adjective":
            return 2
        case "Adverb":
            return 3
        case "Pronoun":
            return 4
        case "ProperNoun":
            return 5
        case "Determiner":
            return 6
        case "Particle":
            return 7
        case "Preposition":
            return 8
        case "Conjunction":
            return 9
        case "Interjection":
            return 10
        case "Classifier":
            return 11
        case "Idiom":
            return 12
        case "OtherWord":
            return 13
        case "OtherWhitespace":
            return 14
        case "OtherPunctuation":
            return 15
        case "Other":
            return 16
        default:
            return 17
        }
    }
    
    private func colorForPartOfSpeech(_ partOfSpeech: String) -> Color {
        switch partOfSpeech {
        case "Noun":
            return .blue
        case "Verb":
            return .green
        case "Adverb":
            return .purple
        case "Adjective":
            return .yellow
        case "Pronoun":
            return .pink
        case "Preposition":
            return .cyan
        case "Determiner":
            return .orange
        default:
            return .white
        }
    }
}

struct PartOfSpeechView_Previews: PreviewProvider {
    static var previews: some View {
        PartOfSpeechView()
    }
}
