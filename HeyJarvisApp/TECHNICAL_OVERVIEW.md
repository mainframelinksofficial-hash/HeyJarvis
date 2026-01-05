# JARVIS Technical Overview: The Living System (v3.6)

## 🧬 Architecture Philosophy

The JARVIS app has been evolved from a simple assistant into a **Living System**. This architecture prioritizes reactive visuals, real-time telemetry, and persistent consciousness.

## 🧠 Core Components

### 1. The Mind (JarvisMindView)

The visual centerpiece of the application.

- **Reactive Engine**: Animates based on `AppState` (Idle, Listening, Processing, Speaking).
- **Aesthetic**: Dynamic Arc Reactor pulses using SwiftUI `@State` animations and rhythmic data shifting.

### 2. Telemetry Core (SystemMonitor)

A centralized diagnostic engine isolated to the `@MainActor`.

- **Real-Time Tracking**: Monitors `UIDevice` battery levels and simulates memory pressure.
- **AI Integration**: Telemetry data is injected directly into the `JarvisAI` system prompt, allowing the AI to be "self-aware."

### 3. Protocol Engine (ProtocolManager)

A macro-based command sequencer.

- **Persistence**: Custom protocols (triggers + action arrays) are stored in `UserDefaults` via Codable.
- **Expansion**: Designed to handle complex "Action Workflows" triggered by specific voice patterns.

### 4. Tactile Audio (SoundManager)

A multi-layered audio system.

- **Physicality**: Uses `AudioServices` system sound IDs for zero-latency mechanical click/impact feedback.
- **Immersive**: Theme-based soundscapes (Jarvis, Friday, Sci-Fi) for high-level events (Startup, Success, Error).

## 🛡️ Reliability & Safety

- **Threading**: All managers are `@MainActor` isolated to prevent race conditions.
- **Memory Safety**: Unbounded history arrays are capped at 50 items.
- **Self-Healing**: `MetaGlassesManager` implements an auto-reconnect loop to maintain peripheral status.

## 💾 Persistence of Consciousness

The `JarvisAI` module now persists the last 10 conversation exchanges across app lifecycle events, providing a continuous experience rather than a stateless interaction.
