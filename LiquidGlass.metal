#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// iOS 26 "True Liquid" Interference Shader
// Uses multi-octave summation to prevent the "sliding sheet" effect.
[[ stitchable ]] float2 liquidGlassDistortion(float2 position, float2 size, float time, float intensity, float frequency) {
    
    // 1. Setup normalized coordinates
    float2 uv = position / size;
    
    // 2. Wave Layer 1: The "Swell" (Large, slow, moves diagonal)
    // We use a diagonal dot product to break the XY grid alignment
    float swell = sin(dot(uv, float2(1.0, 0.5)) * frequency + time) * 0.5;
    
    // 3. Wave Layer 2: The "Chop" (Medium, moves opposite diagonal)
    // Moving in reverse (-time) creates the interference pattern that prevents sliding
    float chop = cos(dot(uv, float2(0.5, 1.0)) * (frequency * 1.5) - (time * 1.2)) * 0.4;
    
    // 4. Wave Layer 3: "Surface Tension" (Fast, high frequency, horizontal)
    // This adds the detailed "glassy" texture
    float tension = sin(uv.y * (frequency * 3.0) + (time * 2.0)) * 0.2;
    
    // 5. Combine forces
    // We apply the distortion to X and Y differently to swirl rather than pan
    float2 displacement = float2(
        swell + tension,  // X is affected by swell and tension
        chop + tension    // Y is affected by chop and tension
    );
    
    // 6. Edge Damping (Crucial for UI components)
    // Prevents the edges of your view from glitching out
    float edgeSmoothness = 0.1; // How far from edge to start damping
    float2 edgeFade = smoothstep(0.0, edgeSmoothness, uv) * (1.0 - smoothstep(1.0 - edgeSmoothness, 1.0, uv));
    float damping = edgeFade.x * edgeFade.y;
    
    // Apply
    return position + (displacement * intensity * damping * 20.0);
}
