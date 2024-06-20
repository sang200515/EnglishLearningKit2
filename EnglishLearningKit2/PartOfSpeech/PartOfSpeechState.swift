//
//  PartOfSpeechswift
//  EnglishLearningKit2
//
//  Created by Em bé cute on 6/19/24.
//

import Foundation
import SwiftUI
import NaturalLanguage

final class PartOfSpeechState: ObservableObject {
    @Published var showTranslation = false
    @Published var typingText: String = ""
    @Published var partOfSpeechTags: [PartOfSpeechModel] = [.init(word: "", partOfSpeech: "", index: 0)]
    @Published var partOfSpeechTagsOther: [PartOfSpeechModel] = []
    @Published var partOfSpeechMerged: [PartOfSpeechModel] = []
    @Published var isOnDuplicate: Bool = true
    @Published var textSize: CGSize = .zero
    
    init(
        showTranslation: Bool = false,
        typingText: String = ""
    ) {
        self.showTranslation = showTranslation
        self.typingText = typingText
    }
    
    func displayMainOptionString(text: String) -> String {
        let modalVerbString = Verb.modalVerbs.contains { $0.lowercased() == text.lowercased() } ? " (m)" : ""
        let tobeVerbString = Verb.tobeVerbs.contains { $0.lowercased() == text.lowercased() } ? " (be)" : ""
        let noundCountable = Nound.listUncountable.contains { $0.lowercased() == text.lowercased() } ? " (u)" : ""
        return "• \(text)\(modalVerbString)\(tobeVerbString)\(noundCountable)"
    }
    
    var columns: [GridItem] {
        [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())]
    }
    
    func analyzeText(inputText: String) {
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
                    partOfSpeechMerged.append(.init(word: newEntry.word, partOfSpeech: newEntry.partOfSpeech, index: counter))
                    if listMainPartOfSpeech.contains(partOfSpeech) {
                        if isOnDuplicate {
                            if !partOfSpeechTags.contains(where: { $0.word == newEntry.word && $0.partOfSpeech == newEntry.partOfSpeech }) {
                                partOfSpeechTags.append(.init(word: newEntry.word, partOfSpeech: newEntry.partOfSpeech, index: counter))
                            }
                            
                        } else {
                            partOfSpeechTags.append(.init(word: newEntry.word, partOfSpeech: newEntry.partOfSpeech, index: counter))
                            
                        }
                    } else {
                        if isOnDuplicate {
                            if !partOfSpeechTagsOther.contains(where: { $0.word == newEntry.word && $0.partOfSpeech == newEntry.partOfSpeech }) {
                                partOfSpeechTagsOther.append(.init(word: newEntry.word, partOfSpeech: newEntry.partOfSpeech, index: counter))
                            }
                        }else {
                            partOfSpeechTagsOther.append(.init(word: newEntry.word, partOfSpeech: newEntry.partOfSpeech, index: counter))
                        }
                    }
                }
                return true
            }
            partOfSpeechTags.sort { (first, second) -> Bool in
                return sortOrder(for: first.partOfSpeech) < sortOrder(for: second.partOfSpeech)
            }
        }
    }
    
    func displayCountString(posTag: String) -> String {
        let count = partOfSpeechTags.filter { $0.partOfSpeech == posTag }.count
        return count > 0 ? "(\(count))" : ""
    }
    
    func displayCountStringOther(posTag: String) -> String {
        let count = partOfSpeechTagsOther.filter { $0.partOfSpeech == posTag }.count
        return count > 0 ? "(\(count))" : ""
    }
    
    func sortOrder(for partOfSpeech: String) -> Int {
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
    
    func colorForPartOfSpeech(_ partOfSpeech: String) -> Color {
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

extension PartOfSpeechState {
    var listMainPartOfSpeech: [String] {
        [
            "Noun",
            "Verb",
            "Adjective",
            "Adverb",
            "Pronoun"
        ]
    }
    var listSubPartOfSpeech: [String] {
        [
            "ProperNoun",
            "Determiner",
            "Particle",
            "Preposition",
            "Conjunction",
            "Interjection",
            "Classifier",
            "Idiom",
            "OtherWord",
            "OtherWhitespace",
            "OtherPunctuation",
            "Other"
        ]
    }
    
}
