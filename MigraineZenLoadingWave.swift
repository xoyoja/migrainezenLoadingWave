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
    
    var texts: [String]
    var color: Color
    var textFont: Font
    var waveCount: Int
    var amplitude: Double
    var frequency: Double
    var speed: Double
    var textCycleInterval: TimeInterval
    
    // MARK: - Internal State
    
    @State private var phase: Double = 0.0
    @State private var textIndex: Int = 0
    
    // MARK: - Initializer
    
    public init(
        texts: [String] = ["Loading...", "Please wait..."],
        color: Color = Color.blue,
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
        self.waveCount = max(1, waveCount)
        self.amplitude = amplitude
        self.frequency = frequency
        self.speed = speed
        self.textCycleInterval = textCycleInterval
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(spacing: 16) {
            
            // THE LIQUID WAVE CONTAINER
            ZStack {
                // Layer A: The "Fluid" Background
                // We use a gradient that is distorted by the LiquidGlass modifier
                // to create the illusion of water volume.
                fluidBackgroundLayer
                    .mask {
                        // Mask the liquid to the shape of the largest wave
                        // to prevent it from looking like a square box
                        SineWaveShape(strength: amplitude, frequency: frequency, phase: phase)
                            // Close the path to make it a fillable mask
                            .fill(Color.black)
                            // Extend downwards to cover the area "under" the water
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .frame(height: amplitude * 2) // Approximate depth
                                    .offset(y: amplitude)
                            }
                    }
                
                // Layer B: The "Harmonic" Lines
                ForEach(0..<waveCount, id: \.self) { index in
                    // CENTERED MATH: Calculate deviation from the center index
                    // This allows the waves to "breathe" around a central core rather than stacking linearly
                    let deviation = Double(index) - Double(waveCount) / 2.0
                    
                    // 1. Frequency: Reduced spread to 2% (0.02)
                    // previously this was `+ (index * 1.5)`, which caused the unnatural gaps.
                    let waveFreq = frequency * (1.0 + (deviation * 0.02))
                    
                    // 2. Phase: Tight locking
                    // Small offset ensures they don't look like a single line, but stay "bundled"
                    let wavePhase = phase + (deviation * 0.2)
                    
                    // 3. Amplitude Tapering
                    // Outer waves are 10% smaller to create a 3D cylindrical feel
                    let waveAmp = amplitude * (1.0 - (abs(deviation) * 0.1))
                    
                    // 4. Opacity Falloff
                    // Center wave is brightest (0.6), edges fade out
                    let opacity = 0.6 - (abs(deviation) * 0.15)
                    
                    SineWaveShape(
                        strength: waveAmp,
                        frequency: waveFreq,
                        phase: wavePhase
                    )
                    .stroke(
                        color.opacity(max(0.1, opacity)), // Ensure min opacity
                        lineWidth: 1.5 // Thinner lines for organic feel
                    )
                    .blendMode(.plusLighter)
                }
            }
            .frame(height: amplitude * 5) // Container height
            .drawingGroup() // Optimizes complex alpha blending
            
            // TEXT INDICATOR
            if !texts.isEmpty {
                Text(texts[textIndex])
                    .font(textFont)
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .id(textIndex)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: speed).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
        .task {
            if texts.count > 1 {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(textCycleInterval))
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
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var fluidBackgroundLayer: some View {
        // Creates the "Water" texture that gets distorted
        LinearGradient(
            colors: [
                color.opacity(0.15), // Slightly increased opacity for better visibility
                color.opacity(0.35),
                color.opacity(0.05)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        // UPDATED PARAMETERS FOR NEW SHADER:
        // Intensity: Reduced to 3.0 (was 20.0 scale in shader, so we feed small nums)
        // Frequency: Increased to 8.0 to create more "peaks"
        // Speed: Slower (0.5) looks more viscous/glassy. Fast looks like water.
        .liquidGlass(intensity: 3.0, frequency: 8.0, speed: 0.8)
        
        // Optional: Add a subtle blend mode to make the colors "pop" like refracted light
        .blendMode(.overlay)
    }
}

// MARK: - 3. Helper Shape

struct SineWaveShape: Shape {
    var strength: Double
    var frequency: Double
    var phase: Double
    
    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath()
        let width = Double(rect.width)
        let height = Double(rect.height)
        let midHeight = height / 2
        
        let wavelength = width > 0 ? width / frequency : 1.0
        
        let startX: Double = 0
        let startRelativeX = startX / wavelength
        let startSine = sin(startRelativeX + phase)
        let startY = midHeight + (startSine * strength)
        
        path.move(to: CGPoint(x: startX, y: startY))
        
        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / wavelength
            let sine = sin(relativeX + phase)
            let y = midHeight + (sine * strength)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return Path(path.cgPath)
    }
}


// MARK: - Helper Shape

/// Applies a refractive, moving liquid texture to any view.
struct LiquidGlassModifier: ViewModifier {
    var intensity: Double // How strong the ripple is (Refractive Index)
    var frequency: Double // How tight the ripples are
    var speed: Double     // Viscosity (lower is thicker/slower)
    
    // The "Start Date" allows the shader to animate continuously over time
    @State private var startDate = Date()
    
    func body(content: Content) -> some View {
        TimelineView(.animation) { context in
            content
                // Apply the Metal Distortion Shader
                .visualEffect { content, proxy in
                    content
                        .distortionEffect(
                            ShaderLibrary.liquidGlassDistortion(
                                .float2(proxy.size),
                                .float(startDate.timeIntervalSinceNow * -speed), // Time driver
                                .float(intensity),
                                .float(frequency)
                            ),
                            maxSampleOffset: .zero // Optimization: Clip sampling to bounds
                        )
                }
        }
    }
}

extension View {
    /// Upgrades the view to the iOS 26 "Liquid Glass" material standard.
    /// - Parameters:
    ///   - intensity: Strength of the refraction (Default: 1.5).
    ///   - frequency: Density of the ripples (Default: 5.0).
    ///   - speed: Flow rate of the liquid (Default: 2.0).
    func liquidGlass(intensity: Double = 1.5, frequency: Double = 5.0, speed: Double = 2.0) -> some View {
        self.modifier(LiquidGlassModifier(intensity: intensity, frequency: frequency, speed: speed))
    }
}


// MARK: - Previews

#Preview("Liquid Glass Style") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        MigraineZenLoadingWave(
            texts: ["Hydrating surfaces...", "Refracting light..."],
            color: .cyan,
            waveCount: 5,
            amplitude: 15,
            frequency: 8,
            speed: 4.0
        )
        .padding()
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
