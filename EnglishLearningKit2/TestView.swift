//
//  TestView.swift
//  EnglishLearningKit2
//
//  Created by Em bé cute on 6/13/24.
//

import SwiftUI

#Preview {
    TestView()
}
struct TestView: View {
  @State private var scale: CGFloat = 1.0 
    var body: some View {
        Text("Nội dung")
            .contentMargins(.greatestFiniteMagnitude) // Thêm khoảng lề cho tất cả các cạnh
          
    }
}
