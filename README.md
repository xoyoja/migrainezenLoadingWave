# Loading Wave
- Multi-waveform waiting progress view
- Rainbow-colored shimmering skeleton progress view
- Text fade-in progress view

--Not-Boring Lightweight Swift UI progress view component we built for the migraine diary app, MigraineZen (https://migrainezen-app.com/).

https://github.com/user-attachments/assets/44d58802-61d1-4179-bad3-7287583443c6

https://github.com/user-attachments/assets/8a8a0a3a-893e-48de-b4b8-44f1520d314c

https://github.com/user-attachments/assets/93623fa8-2475-4c21-9482-d1ef1391a612

https://github.com/user-attachments/assets/a0f83547-6df8-46b1-a4e2-b7115c4678d1


A reusable, highly customizable loading component featuring organic sine wave animations
and cycling status text.

Designed for "Migraine Zen" style interfaces, but adaptable for any iOS 17+ application
requiring a calming, fluid loading state.

# Features
- Configurable wave count, speed, amplitude, and frequency.
- Cycling text with smooth content transitions.
- Modern Swift Concurrency handling (no legacy Timers).
- Fully adaptable colors and typography.

# Usage 
1.XCode > Settings > Components, Look for "Metal Shader Converter" or "Metal Developer Tools" in the list. Click the download arrow next to it.
2.Use the component in your SwiftUI view, example:

```swift
MigraineZenLoadingWave(
    texts: ["Waiting for AI response...", "Syncing Apple Health...", "Anylyzing Headache Triggers ..."],
    color: .gray,
    speed: 2.0
)
```

```swift
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
```