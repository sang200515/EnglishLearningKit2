//
//  TextFieldDebounce.swift
//  EnglishLearningKit2
//
//  Created by Em bé cute on 6/19/24.
//

import Foundation
import SwiftUI
import Combine

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
