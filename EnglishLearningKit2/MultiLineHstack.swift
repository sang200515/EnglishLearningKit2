//
//  MultiLineHstack.swift
//  EnglishLearningKit2
//
//  Created by Em bé cute on 6/16/24.
//

import Foundation
import SwiftUI

public struct MultilineHStack: View {
    struct SizePreferenceKey: PreferenceKey {
        typealias Value = [CGSize]
        static var defaultValue: Value = []
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value.append(contentsOf: nextValue())
        }
    }
    private let items: [Any]
    @State private var sizes: [CGSize] = []
    
    public init<Data: RandomAccessCollection, Content: View>(
        _ data: Data,
        @ViewBuilder content: (Data.Element) -> Content
    ) {
        self.items = data.map { content($0) as Any }
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ForEach(0..<self.items.count, id: \.self) { index in
                    if let view = self.items[index] as? Text {
                        view.background(self.backgroundView())
                            .offset(self.getOffset(at: index, geometry: geometry))
                    }
                }
            }
        }.onPreferenceChange(SizePreferenceKey.self) {
            self.sizes = $0
        }
    }
    
    private func getOffset(at index: Int, geometry: GeometryProxy) -> CGSize {
        guard index < sizes.endIndex else { return .zero }
        let frame = sizes[index]
        var (x, y, maxHeight) = sizes[..<index].reduce((CGFloat.zero, CGFloat.zero, CGFloat.zero)) {
            var (x, y, maxHeight) = $0
            x += $1.width
            if x > geometry.size.width {
                x = $1.width
                y += maxHeight
                maxHeight = 0
            }
            maxHeight = max(maxHeight, $1.height)
            return (x, y, maxHeight)
        }
        if x + frame.width > geometry.size.width {
            x = 0
            y += maxHeight
        }
        return .init(width: x, height: y)
    }
    
    private func backgroundView() -> some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.clear)
                .preference(
                    key: SizePreferenceKey.self,
                    value: [geometry.frame(in: CoordinateSpace.global).size]
                )
        }
    }
}
