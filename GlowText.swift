//
//  GlowText.swift
//  Created by xoyoja on 12/23/25. 
//  
//  https://github.com/xoyoja/migrainezenLoadingWave
//
//  ------------------------------------------------------------------------
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  ------------------------------------------------------------------------
//
//  DESCRIPTION:
//  A text animation component that reveals characters one by one with a
//  glowing effect. It supports a "typing" animation style where text
//  transitions from a dim base color to a glowing primary color.
//
//  FEATURES:
//  - Multiline Support: Correctly animates text across multiple lines.
//  - Two-Stage Reveal: Supports an optional secondary text block that begins
//    typing after the first block completes.
//  - Configurable Speed: Adjustable typing interval.
//  - Spring Animation: Smooth scale and color transitions per character.
//

import SwiftUI

/// A view that animates text character-by-character with a glowing reveal effect.
///
/// `GlowText` is ideal for onboarding screens, loading states, or AI responses where
/// you want to mimic a digital typing interface.
///
/// ```swift
/// GlowText(
///     "Welcome back.",
///     fullText2: "\nSynchronizing data...",
///     baseColor: .gray,
///     glowColor: .white
/// )
/// ```

struct GlowText: View {
    let fullText: String
    let fullText2: String
    let baseColor: Color
    let glowColor: Color
    let interval: TimeInterval
    
    @State private var revealedCount = 0
    @State private var isPlayingSecondText = false
    @State private var combinedText = ""
    
    init(
        _ text: String,
        fullText2: String = "",
        baseColor: Color = .gray.opacity(0.45),
        glowColor: Color = .primary,
        interval: TimeInterval = 0.5
    ) {
        self.fullText = text
        self.fullText2 = fullText2
        self.baseColor = baseColor
        self.glowColor = glowColor
        self.interval = interval
    }
    
    private var lines: [String] {
        combinedText.components(separatedBy: .newlines)
    }
    
    private var totalChars: Int {
        lines.reduce(0) { $0 + $1.count }
    }
    
    private var firstTextCharCount: Int {
        fullText.components(separatedBy: .newlines).reduce(0) { $0 + $1.count }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(Array(line.enumerated()), id: \.offset) { charIndex, ch in
                        let flatIndex = flatIndex(of: line, charIndex: charIndex)
                        
                        Text(String(ch))
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(flatIndex < revealedCount ? glowColor : baseColor)
                            .scaleEffect(flatIndex < revealedCount ? 1 : 0.8, anchor: .bottom)
                            .animation(
                                .spring(response: 0.35, dampingFraction: 0.65, blendDuration: 0),
                                value: revealedCount
                            )
                    }
                }
            }
        }
        .task {
            // Reset state
            revealedCount = 0
            isPlayingSecondText = false
            combinedText = fullText
            
            // Play first text
            for _ in 0..<firstTextCharCount {
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                revealedCount += 1
            }
            
            // If we have second text, continue playing it
            if !fullText2.isEmpty {
                isPlayingSecondText = true
                combinedText = fullText + fullText2
                
                // Continue from where we left off, but more slower
                if firstTextCharCount < totalChars {
                    for _ in firstTextCharCount..<totalChars {
                        try? await Task.sleep(nanoseconds: UInt64(interval * 2_000_000_000))
                        revealedCount += 1
                    }
                }
            }
        }
    }
    
    private func flatIndex(of line: String, charIndex: Int) -> Int {
        let lineStart = lines
            .prefix(while: { $0 != line })
            .reduce(0) { $0 + $1.count }
        return lineStart + charIndex
    }
}


#Preview("Multiline GlowText") {
    GlowText("Syncing\nwith\nApple health\n...",
             fullText2: "\n\nSeems something happened\nneeds more time ")
        .padding()
}

