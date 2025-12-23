# Loading Wave
Multi-waveform waiting progress view: This is a lightweight Swift UI component we built for the migraine diary app, MigraineZen (https://migrainezen-app.com/).

https://github.com/user-attachments/assets/8a8a0a3a-893e-48de-b4b8-44f1520d314c

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