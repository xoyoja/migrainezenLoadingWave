import SwiftUI

/// A reusable, highly customizable loading component featuring organic sine wave animations
/// and cycling status text.
///
/// Designed for "Migraine Zen" style interfaces, but adaptable for any iOS 17+ application
/// requiring a calming, fluid loading state.
///
/// **Features:**
/// - Configurable wave count, speed, amplitude, and frequency.
/// - Cycling text with smooth content transitions.
/// - Modern Swift Concurrency handling (no legacy Timers).
/// - Fully adaptable colors and typography.
///
/// **Usage:**
/// ```swift
/// MigraineZenLoadingWave(
///     texts: ["Loading...", "Syncing Weather..."],
///     color: .cyan,
///     speed: 2.0
/// )
/// ```
public struct MigraineZenLoadingWave: View {
    
    // MARK: - Configuration Properties
    
    /// The array of messages to cycle through while loading.
    var texts: [String]
    
    /// The primary color of the waves.
    var color: Color
    
    /// The font style for the cycling text.
    var textFont: Font
    
    /// The number of overlapping sine waves to render.
    var waveCount: Int
    
    /// The vertical amplitude (height) of the waves.
    var amplitude: Double
    
    /// The frequency (width tightness) of the waves.
    var frequency: Double
    
    /// The duration (in seconds) for one full wave animation cycle.
    var speed: Double
    
    /// The duration (in seconds) each text string is displayed before switching.
    var textCycleInterval: TimeInterval
    
    // MARK: - Internal State
    
    /// Controls the horizontal phase shift of the sine waves.
    @State private var phase: Double = 0.0
    
    /// Tracks the currently displayed text index.
    @State private var textIndex: Int = 0
    
    // MARK: - Initializer
    
    /// Creates a new Migraine Zen Loading Wave component.
    ///
    /// - Parameters:
    ///   - texts: List of strings to cycle through. Defaults to generic loading messages.
    ///   - color: Base color for the waves. Opacity is handled automatically per wave layer.
    ///   - textFont: Font for the status text. Defaults to `.caption`.
    ///   - waveCount: Number of layered waves. Higher counts create a denser "mesh" effect. Defaults to 3.
    ///   - amplitude: Vertical strength of the wave. Defaults to 12.
    ///   - frequency: How tight the waves are. Defaults to 8.
    ///   - speed: Animation loop duration in seconds. Lower is faster. Defaults to 2.0.
    ///   - textCycleInterval: Time in seconds between text updates. Defaults to 2.5.
    public init(
        texts: [String] = ["Loading...", "Please wait..."],
        color: Color = Color.gray,
        textFont: Font = .caption,
        waveCount: Int = 3,
        amplitude: Double = 12,
        frequency: Double = 8,
        speed: Double = 2.0,
        textCycleInterval: TimeInterval = 2.5
    ) {
        self.texts = texts
        self.color = color
        self.textFont = textFont
        self.waveCount = max(1, waveCount) // Ensure at least 1 wave
        self.amplitude = amplitude
        self.frequency = frequency
        self.speed = speed
        self.textCycleInterval = textCycleInterval
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(spacing: 16) {
            // 1. Wave Visualization
            ZStack {
                ForEach(0..<waveCount, id: \.self) { index in
                    // Calculate variations based on index to create depth
                    let progress = Double(index) / Double(waveCount)
                    let waveOpacity = 0.1 + (0.15 * progress) // 0.1 to 0.25 opacity
                    let waveFrequency = frequency + (Double(index) * 1.5) // Vary frequency slightly
                    let wavePhaseOffset = Double(index) * 5.0 // Offset starting phase
                    let waveLineWidth = 3.0 - (progress * 1.0) // Thinner lines in front
                    
                    SineWaveShape(
                        strength: amplitude,
                        frequency: waveFrequency,
                        phase: phase + wavePhaseOffset
                    )
                    .stroke(color.opacity(waveOpacity), lineWidth: waveLineWidth)
                }
            }
            .frame(height: amplitude * 4) // Ensure container fits the wave height
            
            // 2. Cycling Text
            if !texts.isEmpty {
                Text(texts[textIndex])
                    .font(textFont)
                    .foregroundStyle(.secondary)
                    // Numeric text transition handles character swapping smoothly
                    .contentTransition(.numericText())
                    .id(textIndex) // Explicit ID to force transition on change
            }
        }
        .onAppear {
            // Start Wave Animation
            withAnimation(.linear(duration: speed).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
        .task {
            // Start Text Cycling Loop (Modern Concurrency)
            // This replaces the old Timer logic and automatically cancels when the view disappears.
            if texts.count > 1 {
                // Infinite loop until task is cancelled
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(textCycleInterval))
                    
                    // Update UI on Main Actor
                    withAnimation(.snappy) {
                        textIndex = (textIndex + 1) % texts.count
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(texts.isEmpty ? "Loading" : texts[textIndex])
        .accessibilityAddTraits(.updatesFrequently)
    }
}

// MARK: - Helper Shape

/// A pure mathematical shape representing a sine wave.
///
/// Logic: `y = A * sin(kx + p)`
internal struct SineWaveShape: Shape {
    /// The amplitude (height) of the wave.
    var strength: Double
    /// The frequency (width/tightness) of the wave.
    var frequency: Double
    /// The phase shift (horizontal position).
    var phase: Double
    
    /// Allows SwiftUI to interpolate values for smooth animation.
    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath()
        let width = Double(rect.width)
        let height = Double(rect.height)
        let midHeight = height / 2
        
        // Ensure we don't divide by zero if width is tiny
        let wavelength = width > 0 ? width / frequency : 1.0
        
        // Calculate start point to avoid "vertical line" artifact at x=0
        let startX: Double = 0
        let startRelativeX = startX / wavelength
        let startSine = sin(startRelativeX + phase)
        let startY = midHeight + (startSine * strength)
        
        path.move(to: CGPoint(x: startX, y: startY))
        
        // Plot points across the width
        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / wavelength
            let sine = sin(relativeX + phase)
            let y = midHeight + (sine * strength)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return Path(path.cgPath)
    }
}

// MARK: - Previews

#Preview("Standard Configuration") {
    MigraineZenLoadingWave()
        .padding()
}

#Preview("Custom - Weather Style") {
    MigraineZenLoadingWave(
        texts: ["Locating local sensors...", "Analyzing forecast...", "Checking pressure..."],
        color: Color.teal,
        waveCount: 2,
        amplitude: 10,
        frequency: 10,
        speed: 3.0
    )
    .padding()
    .background(Color.black)
    .colorScheme(.dark)
}

#Preview("Custom - High Energy") {
    MigraineZenLoadingWave(
        texts: ["Syncing HealthKit...", "Processing Vitals..."],
        color: .pink,
        waveCount: 5,
        amplitude: 15,
        frequency: 4,
        speed: 0.5, // Very fast
        textCycleInterval: 1.0
    )
    .padding()
}

#Preview("Minimal (No Text)") {
    MigraineZenLoadingWave(
        texts: [],
        color: .indigo,
        waveCount: 3
    )
    .frame(width: 100)
    .padding()
}
