//
//  TypingModifierState.swift
//  EnglishLearningKit2
//
//  Created by Em bé cute on 6/13/24.
//

import Foundation
import SwiftUI
import AVFoundation
final class ModifierState: ObservableObject {
    @Published var items: [Detail] = []
    @Published private(set) var itemsDisplayed: [Detail] = []
    @Published var displayedItem: Detail = Detail( description: "", fullText: "", keyword: "", parent: "", ios: "")
    @Published var searchText = ""
    @Published var currentText = ""
    @Published var currentIndex: Int = 0
    @Published var onSuccess: Bool = false
    @Published var onAppear: Bool = false
    @Published var listWrongKeyWord: [String] = []
    @Published var onIndex: Int = 0
    @Published var shouldSpeak = false
    @Published private(set) var ipaPronunciation: String?
    init() {
        if SharingInputListString.listString.isEmpty {
            loadModifiersFromJSON()
        }
    }
    
    func update(){
        items = SharingInputListString.listString.map {
            .init(
                description: "",
                fullText: "",
                keyword: $0,
                parent: "",
                ios: ""
            )
        }
        if let item = items.first {
            displayedItem = item
        }
    }
    func removeRandomItem() {
        guard !items.isEmpty else { return }
        items.shuffle()
        
        displayedItem = items.removeFirst()
        
        textToSpeech(displayedItem.keyword)
        
        if displayedItem.keyword != "" {
            if itemsDisplayed.count > 0 {
                itemsDisplayed.insert(displayedItem, at: 0)
            } else {
                itemsDisplayed.append(displayedItem)
            }
        }
    }
    
    var validateColor: Color {
        return searchText.lowercased() == String(displayedItem.keyword.lowercased().prefix(searchText.lowercased().count)) ? Color.gray.opacity(0.2) : .red
    }
    
    func validateSuccessForTyping(){
        onSuccess = searchText.lowercased() == String(displayedItem.keyword.lowercased().dropFirst(1).dropLast(2)).lowercased()
    }
    
    func validateSuccessForPartOfSpeech(){
        onSuccess = searchText.lowercased() == String(displayedItem.keyword.lowercased())
    }
    
    @Published var onCompleted: Bool = false {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.resetState()
            }
        }
    }
    func textToSpeech(_ text: String){
        guard onAppear else {
            onAppear.toggle()
            return
        }
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: textForSpeech)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.3
        synthesizer.speak(utterance)
    }
    func resetState() {
        currentIndex = 0
        searchText = ""
    }
    
    var textForSpeech: String {
        var str: String {
            if !SharingInputListString.listNoun.isEmpty{
                return String(displayedItem.keyword.lowercased())
            } else {
               return String(displayedItem.keyword.dropFirst(1).dropLast(2))
            }
        }
        var words: [String] = []
        var currentWord = ""
        
        for char in str {
            if char.isUppercase {
                if !currentWord.isEmpty {
                    words.append(currentWord)
                }
                currentWord = ""
            }
            currentWord.append(char)
        }
        if !currentWord.isEmpty {
            words.append(currentWord)
        }
        let combinedString = words.joined(separator: " ")
        return combinedString
    }
    
    
    private func loadModifiersFromJSON() {
        if let url = Bundle.main.url(forResource: "modifier", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let modifiers = try JSONDecoder().decode(ModifierInfo.self, from: data)
                DispatchQueue.main.async {
                    if modifiers.modifiers.count > 0 {
                        print("parser success \(modifiers.modifiers.count)")
                    }
                    self.items = modifiers.modifiers
                    self.removeRandomItem()
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        } else {
            print("File not found")
        }
    }
}
struct ModifierInfo: Decodable {
    let modifiers: [Detail]
}

// MARK: - PropertyWrapper
struct Detail: Decodable {
    let description: String
    let fullText: String
    let keyword: String
    let parent: String
    let ios: String
}

