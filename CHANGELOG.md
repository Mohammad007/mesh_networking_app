# Changelog

All notable changes to MeshNet will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- iOS support
- Media sharing (images/videos)
- Voice messages
- Group chats
- Voice/Video calls over mesh

---

## [1.0.0] - 2026-01-02

### 🎉 Initial Release

#### ✨ Added
- **Core Features**
  - Offline mesh networking using Wi-Fi Direct and Bluetooth
  - Auto-discovery of nearby devices
  - One-to-one encrypted messaging
  - Emergency broadcast to all nodes
  - Live network topology visualization
  
- **Security**
  - AES-256 end-to-end encryption
  - Message signature verification
  - Replay attack prevention
  - Local data encryption with Hive
  
- **Networking**
  - Wi-Fi Direct P2P (up to 200m range)
  - Bluetooth Low Energy mesh (up to 100m range)
  - TTL-based message forwarding (1-10 hops)
  - Duplicate message detection
  - Smart routing with signal strength awareness
  
- **UI/UX**
  - Splash screen with system checks
  - Permission request flow
  - Zero-login username setup
  - Home dashboard with mesh toggle
  - Discovery screen with radar animation
  - Chat list with last message preview
  - **Chat screen** with message bubbles
  - Broadcast screen with 6 emergency templates
  - Network map with animated topology
  - Settings screen with encryption/TTL controls
  
- **User Experience**
  - Beautiful dark theme with glassmorphic design
  - Smooth animations with `animate_do`
  - Online/Offline status indicators
  - Signal strength display
  - Distance estimation (RSSI-based)
  - Message delivery status (✓/✓✓)
  - Relay information (hop count)
  
- **Data Management**
  - Local Hive database for messages
  - Message queue for offline delivery
  - Chat history persistence
  - Settings persistence
  - Statistics tracking

#### 🛠️ Technical
- Flutter 3.24.5 framework
- Dart 3.5+ language
- MVVM architecture with Provider
- Comprehensive test suite (80+ tests)
- Full documentation (README, CONTRIBUTING, etc.)

#### 📱 Platforms
- Android 6.0+ (API level 23+)
- Physical device required (Wi-Fi Direct/BLE support)

---

## Version History

### Version Format
`MAJOR.MINOR.PATCH`

- **MAJOR**: Incompatible API changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Types
- 🎉 **Major Release** - New major version
- ✨ **Minor Release** - New features
- 🐛 **Patch Release** - Bug fixes
- 🔒 **Security Update** - Security patches

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to contribute to MeshNet.

---

## Links

- [Documentation](README.md)
- [Issue Tracker](https://github.com/Mohammad007/mesh_networking_app/issues)
- [Discussions](https://github.com/Mohammad007/mesh_networking_app/discussions)
- [Releases](https://github.com/Mohammad007/mesh_networking_app/releases)
