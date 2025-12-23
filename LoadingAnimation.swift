//
//  LoadingAnimation.swift
//
//  Created by xoyoja on 12/23/25. 
//  
//  https://github.com/xoyoja/migrainezenLoadingWave
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
//  A comprehensive suite of SwiftUI loading indicators designed for flexibility
//  and accessibility. Includes circular spinners, linear progress bars, and a
//  shimmering skeleton loader wrapper.
//
//  FEATURES:
//  - 3 Distinct Styles: Circular, Linear, and Skeleton.
//  - Accessibility First: Supports Reduce Motion and Differentiate Without Color.
//  - Dynamic Type: Scales automatically with system font sizes.
//  - Deterministic & Indeterminate: Handles both specific progress (%) and
//    infinite loading states.
//

import SwiftUI

/// A versatile loading indicator component supporting multiple visual styles.
///
/// Use `LoadingIndicator` to provide visual feedback during asynchronous operations.
/// It supports both determinate (progress-based) and indeterminate (infinite) states.
///
/// ```swift
/// // Example: Indeterminate Circular Spinner
/// LoadingIndicator(style: .circular, message: "Syncing...", tint: .blue)
///
/// // Example: Determinate Linear Bar
/// LoadingIndicator(style: .linear, progress: 0.7, tint: .green)
/// ```

struct LoadingIndicator: View {
    enum Style {
        case circular
        case linear
        case skeleton
    }
    
    let style: Style
    let message: String?
    let progress: Float?
    let tint: Color
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    init(
        style: Style = .circular,
        message: String? = nil,
        progress: Float? = nil,
        tint: Color = .blue
    ) {
        self.style = style
        self.message = message
        self.progress = progress
        self.tint = tint
    }
    
    var body: some View {
        VStack(spacing: 10) {
            switch style {
            case .circular:
                circularIndicator
            case .linear:
                linearIndicator
            case .skeleton:
                skeletonIndicator
            }
            
            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(differentiateWithoutColor ? .primary : .secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .transition(.opacity)
                    .dynamicTypeSize(.medium ... .accessibility3)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(accessibilityValue)
    }
    
    private var circularIndicator: some View {
        ZStack {
            if let progress = progress {
                // Determinate progress
                Circle()
                    .stroke(tint.opacity(differentiateWithoutColor ? 0.3 : 0.2), lineWidth: 4)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                    .stroke(
                        differentiateWithoutColor ? tint.opacity(0.9) : tint,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                    .animation(
                        reduceMotion ? .easeOut(duration: 0.2) : .linear,
                        value: progress
                    )
                
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(differentiateWithoutColor ? .primary : tint)
                    .dynamicTypeSize(.medium ... .accessibility3)
            } else {
                // Indeterminate progress
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: differentiateWithoutColor ? tint.opacity(0.9) : tint))
                    .scaleEffect(1.5)
            }
        }
    }
    
    private var linearIndicator: some View {
        VStack(spacing: 8) {
            if let progress = progress {
                // Determinate progress
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(tint.opacity(differentiateWithoutColor ? 0.3 : 0.2))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(differentiateWithoutColor ? tint.opacity(0.9) : tint)
                            .frame(width: geometry.size.width * CGFloat(min(progress, 1.0)), height: 8)
                            .cornerRadius(4)
                            .animation(
                                reduceMotion ? .easeOut(duration: 0.2) : .linear,
                                value: progress
                            )
                    }
                }
                .frame(height: 8)
                
                if let message = message {
                    HStack {
                        Text(message)
                            .font(.caption)
                            .foregroundColor(differentiateWithoutColor ? .primary : .secondary)
                            .dynamicTypeSize(.medium ... .accessibility3)
                        
                        Spacer()
                        
                        Text("\(Int(progress * 100))%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(differentiateWithoutColor ? .primary : tint)
                            .dynamicTypeSize(.medium ... .accessibility3)
                    }
                }
            } else {
                // Indeterminate progress
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(tint.opacity(differentiateWithoutColor ? 0.3 : 0.2))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(differentiateWithoutColor ? tint.opacity(0.9) : tint)
                            .frame(width: geometry.size.width * 0.3, height: 8)
                            .cornerRadius(4)
                            .offset(x: geometry.size.width * animationValue)
                    }
                }
                .frame(height: 8)
                .onAppear {
                    // Use simpler animation for reduced motion
                    let animation = reduceMotion
                        ? Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)
                        : Animation.linear(duration: 1.5).repeatForever(autoreverses: false)
                    
                    withAnimation(animation) {
                        animationValue = reduceMotion ? 0.7 : 1.0
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
    
    @State private var animationValue: CGFloat = -0.3
    
    // MARK: - Accessibility Properties
    
    private var accessibilityLabel: String {
        message ?? "loading"
    }
    
    private var accessibilityValue: String {
        if let progress = progress {
            return "\(Int(progress * 100))% complete"
        }
        return "In progress"
    }
    
    private var skeletonIndicator: some View {
        VStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 8)
                    .fill(tint.opacity(differentiateWithoutColor ? 0.3 : 0.2))
                    .frame(height: 24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.clear,
                                        Color.red.opacity(0.6),
                                        Color.orange.opacity(0.6),
                                        Color.yellow.opacity(0.6),
                                        Color.green.opacity(0.6),
                                        Color.blue.opacity(0.6),
                                        Color.purple.opacity(0.6),
                                        Color.clear
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .offset(x: -100 + 300 * animationValue)
                    )
                    .clipped()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .onAppear {
            let animation = reduceMotion
                ? Animation.easeIn(duration: 0.8).repeatForever(autoreverses: true)
                : Animation.linear(duration: 1.5).repeatForever(autoreverses: false)
            
            withAnimation(animation) {
                animationValue = reduceMotion ? 0.5 : 1.0
            }
        }
    }

}

struct ProgressOverlay: View {
    let progress: Float
    let message: String
    let tint: Color
    
    init(progress: Float, message: String, tint: Color = .blue) {
        self.progress = progress
        self.message = message
        self.tint = tint
    }
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            // Progress container
            VStack(spacing: 20) {
                // Progress indicator
                ZStack {
                    Circle()
                        .stroke(tint.opacity(0.2), lineWidth: 6)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                        .stroke(tint, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear, value: progress)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                // Message
                Text(message)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6).opacity(0.8))
                    .background(
                        VisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
                            .cornerRadius(20)
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        return UIVisualEffectView(effect: effect)
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
}

struct SkeletonView<Content: View>: View {
    let isLoading: Bool
    let content: () -> Content
    let tint: Color
    
    @State private var animationValue: CGFloat = -0.3
    
    init(isLoading: Bool, tint: Color = .blue, @ViewBuilder content: @escaping () -> Content) {
        self.isLoading = isLoading
        self.content = content
        self.tint = tint
    }
    
    var body: some View {
        ZStack {
            if isLoading {
                content()
                    .redacted(reason: .placeholder)
                    .overlay(
                        GeometryReader { geometry in
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.clear,
                                            Color.red.opacity(0.3),
                                            Color.orange.opacity(0.3),
                                            Color.yellow.opacity(0.3),
                                            Color.green.opacity(0.3),
                                            Color.blue.opacity(0.3),
                                            Color.purple.opacity(0.3),
                                            Color.clear
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * 0.7)
                                .offset(x: -geometry.size.width * 0.3 + geometry.size.width * animationValue)
                        }
                    )
                    .clipped()
                    .task {
                        while isLoading {
                            withAnimation(.linear(duration: 1.5)) {
                                animationValue = 1.0
                            }
                            try? await Task.sleep(nanoseconds: 1_500_000_000)
                            animationValue = 0
                        }
                    }
//                    .onAppear {
//                        animationValue = -0.3
//                        withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
//                            animationValue = 1.0
//                        }
//                    }
//                    .onDisappear {
//                        animationValue = -0.3
//                    }
            } else {
                content()
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
//        LoadingIndicator(
//            style: .circular,
//            message: "Loading...",
//            progress: nil,
//            tint: .blue
//        )
//        
//        LoadingIndicator(
//            style: .circular,
//            message: "Processing image...",
//            progress: 0.65,
//            tint: .green
//        )
//        
//        LoadingIndicator(
//            style: .linear,
//            message: "Generating tutorial...",
//            progress: 0.35,
//            tint: .orange
//        )
//        
        LoadingIndicator(
            style: .skeleton,
            tint: .purple
        )
        
        SkeletonView(isLoading: true) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
//                    Circle()
                    ConcentricCirclesView(color1: .gray.opacity(0.5), color2: .black.opacity(0.5), outFrame: 30, innerFrame: 20)
                    
                    Text("Mock name")
                        .font(.title)
                }
                
                Text("")
                    .font(.headline)
                
                Text("Mock Tutorial  ")
                    .font(.headline)
                
                Text("Mock Tutorial Title terer")
                    .font(.headline)
                                
                Text("Mock This")
                    .font(.subheadline)
                
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
        }
        
//        ProgressOverlay(
//            progress: 0.75,
//            message: "Generating tutorial..."
//        )
//        .frame(height: 200)
    }
    .padding()
}

struct ConcentricCirclesView: View {
    let color1: Color
    let color2: Color
    let outFrame: CGFloat
    let innerFrame: CGFloat
    
    var body: some View {
        ZStack {
            // Outer thick ring
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [color1, color2],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: outFrame, height: outFrame)
            
            // Inner thin ring
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [color1, color2],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .frame(width: innerFrame, height: innerFrame)
            
        }
        .padding(1)
    }
}


