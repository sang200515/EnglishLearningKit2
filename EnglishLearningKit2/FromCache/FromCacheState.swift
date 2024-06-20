//
//  FromCacheState.swift
//  EnglishLearningKit2
//
//  Created by Em bé cute on 6/20/24.
//

import Foundation
import SwiftUI
import AVFoundation
var postag: String = ""
final class FromCacheState: ObservableObject {
    @Published var items: [String] = []
    @Published private(set) var itemsDisplayed: [String] = []
    @Published var displayedString: String = ""
    @Published var searchText = ""
    @Published var currentText = ""
    @Published var currentIndex: Int = 0
    @Published var onSuccess: Bool = false
    @Published var onAppear: Bool = false
    @Published var listWrongKeyWord: [String] = []
    @Published var onIndex: Int = 0
    @Published var shouldSpeak = false
    @Published private(set) var ipaPronunciation: String?
    
    var listNoun : [String] { SharingInputListString.listNoun }
    var listVerb : [String] { SharingInputListString.listVerb }
    var listAdjective : [String] { SharingInputListString.listAdjective }
    var listAdverb : [String] { SharingInputListString.listAdverb }
    var listPronoun : [String] { SharingInputListString.listPronoun }
    
    
    func removeRandomItem() {
        guard !items.isEmpty else { return }
        textToSpeech(displayedString)
    }
    
    var validateColor: Color {
        return searchText.lowercased() == String(displayedString.lowercased().prefix(searchText.lowercased().count)) ? Color.gray.opacity(0.2) : .red
    }
    func validateSuccessForPartOfSpeech(){
        onSuccess = searchText.lowercased() == String(displayedString.lowercased())
    }
    
    func textToSpeech(_ text: String){
        guard onAppear else {
            onAppear.toggle()
            return
        }
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: displayedString)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.3
        synthesizer.speak(utterance)
    }
    
    func resetState() {
        currentIndex = 0
        searchText = ""
    }
}
