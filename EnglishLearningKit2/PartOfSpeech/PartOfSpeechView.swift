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
struct PartOfSpeechModel {
    let word: String
    let partOfSpeech: String
    let index: Int
}
class TextFieldObserver : ObservableObject {
    @Published var debouncedText = ""
    @Published var searchText = ""
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] t in
                self?.debouncedText = t
            } )
            .store(in: &subscriptions)
    }
}
struct TextFieldWithDebounce : View {
    @Binding var debouncedText : String
    @StateObject private var textObserver = TextFieldObserver()
    
    var body: some View {
        
        VStack {
            TextField("Typing some thing in English...", text: $textObserver.searchText)
                .frame(height: 30)
                .padding(.leading, 5)
        }.onReceive(textObserver.$debouncedText) { (val) in
            debouncedText = val
        }
    }
}

struct PartOfSpeechView: View {
    @State private var showTranslation = false
    @State private var showTranslationOrder = false
    @State private var showTranslationOther = false
    @State private var text: String = ""
    @State private var feedbackMessage: String = ""
    @State private var partOfSpeechTags: [PartOfSpeechModel] = [.init(word: "", partOfSpeech: "", index: 0)]
    @State private var partOfSpeechTagsOther: [PartOfSpeechModel] = []
    @State private var partOfSpeechMerged: [PartOfSpeechModel] = []
    
    @FocusState private var isFocused: Bool
   private let partOfSpeechOrder: [String] = ["Noun", "Verb", "Adjective", "Adverb","Pronoun"]
    private let partOfSpeechOther: [String] = ["ProperNoun", "Determiner", "Particle", "Preposition", "Conjunction", "Interjection", "Classifier", "Idiom", "OtherWord", "OtherWhitespace", "OtherPunctuation", "Other"]
    private  let modalVerbs: [String] = [ "can", "could", "may", "might", "will", "would", "shall", "should", "must", "ought to" ]
    private let tobeVerbs: [String] = ["am", "is", "are", "was", "were", "been", "being", "be"]
        
    @State private var isOnDuplicate: Bool = true
    @StateObject private var textObserver = TextFieldObserver()
    @State private var textSize: CGSize = .zero
    var body: some View {
        ScrollView(.vertical){
            VStack(alignment: .leading) {
                HStack {
                    TextFieldWithDebounce(debouncedText: $text)
                        .frame(height: 51)
                        .font(.title)
                        .padding()
                        .onChange(of: text) { oldValue, newValue in
                            analyzeText(inputText: newValue)
                        }
                    
                    Button(action: {
                        if let clipboardText = UIPasteboard.general.string {
                            text = clipboardText
                            analyzeText(inputText: text)
                        }
                    }) {
                        Image(systemName: "doc.on.clipboard")
                            .font(.subheadline)
                            .padding()
                    }
                }
                
                .onSubmit {
                    analyzeText(inputText: text)
                }
                
                if #available(iOS 17.4, *) {
                    Text(text)
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .onTapGesture {
                            showTranslation.toggle()
                        }
                        .translationPresentation(isPresented: $showTranslation,text: text)
                        .readSize { size in
                            self.textSize = size
                        }
                } else {
                    // Fallback on earlier versions
                }
                
                Group {
                    MultilineHStack(partOfSpeechMerged) { item in
                        Text("\(item.word) ")
                            .foregroundColor(colorForPartOfSpeech(item.partOfSpeech))
                            .font(.system(size: 16))
                    }
                }
                .frame(height: textSize.height)
                
                partOfSpeechToggle
                    .padding(.top, 8)
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
                analyzeText(inputText: text)
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
                let filteredItems = partOfSpeechTags.filter { $0.partOfSpeech == posTag }
                if !filteredItems.isEmpty {
                    VStack(spacing: 5) {
                        Text("\(posTag)")
                            .foregroundColor(colorForPartOfSpeech(posTag))
                            .font(.headline) + Text(displayCountString(posTag: posTag)).font(.headline)
                        ScrollView {
                            LazyVStack(spacing: 5) {
                                ForEach(Array(filteredItems.enumerated()), id: \.offset) { index, tag in
                                    HStack {
                                        let modalVerbString = modalVerbs.contains { $0.lowercased() == tag.word.lowercased() } ? " (m)" : ""
                                        let tobeVerbString = tobeVerbs.contains { $0.lowercased() == tag.word.lowercased() } ? " (be)" : ""
                                        Text("• \(tag.word)\(modalVerbString)\(tobeVerbString)")
                                            .foregroundColor(colorForPartOfSpeech(tag.partOfSpeech))
                                        Spacer()
                                        Text(" • \(tag.index)")
                                    }
//                                    .onTapGesture {
//                                        showTranslationOrder.toggle()
//                                    }
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
    
    private func displayCountStringOther(posTag: String) -> String {
        let count = partOfSpeechTagsOther.filter { $0.partOfSpeech == posTag }.count
        return count > 0 ? "(\(count))" : ""
    }
    
    private var listParthOfSpeechOther: some View {
        LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())], spacing: 8) {
            ForEach(partOfSpeechOther, id: \.self) { posTag in
                let filteredItems = partOfSpeechTagsOther.filter { $0.partOfSpeech == posTag }
                if !filteredItems.isEmpty {
                    VStack(spacing: 5) {
                        Text("\(posTag)")
                            .foregroundColor(colorForPartOfSpeech(posTag))
                            .font(.headline) + Text(displayCountStringOther(posTag: posTag)).font(.headline)
                        ScrollView {
                            LazyVStack(spacing: 5) {
                                ForEach(Array(filteredItems.enumerated()), id: \.offset) { index, tag in
                                    HStack {
                                        let text = "• \(tag.word)"
                                        if #available(iOS 17.4, *) {
                                            Text(text)
                                                .foregroundColor(colorForPartOfSpeech(tag.partOfSpeech))
//                                                .translationPresentation(isPresented: $showTranslationOther, text: text)
                                        }
                                        Spacer()
                                        Text(" • \(tag.index)")
                                    }
//                                    .onTapGesture {
//                                        showTranslationOther.toggle()
//                                    }
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
    private func analyzeText(inputText: String) {
        withAnimation {
            partOfSpeechTags.removeAll()
            partOfSpeechTagsOther.removeAll()
            partOfSpeechMerged.removeAll()
            let tagger = NLTagger(tagSchemes: [.lexicalClass])
            tagger.string = inputText
            
            let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation]
            var counter: Int = 0
            tagger.enumerateTags(in: inputText.startIndex..<inputText.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
                counter += 1
                if let tag {
                    let word = String(inputText[tokenRange])
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
