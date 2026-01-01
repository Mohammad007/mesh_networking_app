# 🤝 Contributing to MeshNet

First off, thank you for considering contributing to MeshNet! It's people like you that make MeshNet such a great tool for offline communication.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Guidelines](#coding-guidelines)
- [Commit Messages](#commit-messages)
- [Pull Request Process](#pull-request-process)
- [Community](#community)

---

## 📜 Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

### Our Pledge

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on what is best for the community
- Show empathy towards other community members

---

## 🎯 How Can I Contribute?

### 🐛 Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates.

**When submitting a bug report, include:**

- **Clear title** - Descriptive summary of the issue
- **Steps to reproduce** - Detailed steps to recreate the bug
- **Expected behavior** - What you expected to happen
- **Actual behavior** - What actually happened
- **Screenshots** - If applicable
- **Environment**:
  - Device model
  - Android version
  - MeshNet version
  - Flutter/Dart version

### 💡 Suggesting Features

Feature requests are welcome! To suggest a feature:

1. Check if it's already suggested in [Issues](https://github.com/Mohammad007/mesh_networking_app/issues)
2. Open a new issue with the `enhancement` label
3. Provide:
   - **Clear use case** - Why is this feature needed?
   - **Proposed solution** - How should it work?
   - **Alternatives** - What other solutions did you consider?
   - **Mockups/Diagrams** - If applicable

### 🔧 Pull Requests

We actively welcome your pull requests!

**Good first issues** are labeled with `good first issue` - perfect for newcomers!

---

## 🛠️ Development Setup

### Prerequisites

```bash
# Required
- Flutter SDK 3.24.5+
- Dart SDK 3.5+
- Android Studio / VS Code
- Git

# Recommended
- Physical Android device (for testing mesh features)
- VS Code with Flutter extension
```

### Setup Steps

1. **Fork & Clone**
   ```bash
   git clone https://github.com/Mohammad007/mesh_networking_app.git
   cd meshnet
   ```

2. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/Mohammad007/mesh_networking_app.git
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Generate code**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Run tests**
   ```bash
   flutter test
   ```

6. **Run app**
   ```bash
   flutter run
   ```

---

## 📝 Coding Guidelines

### Dart Style Guide

Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines.

### Key Principles

1. **Formatting**
   ```bash
   # Format your code before committing
   dart format .
   ```

2. **Linting**
   ```bash
   # Run analyzer
   flutter analyze
   ```

3. **Naming Conventions**
   ```dart
   // Classes: PascalCase
   class MessageModel { }
   
   // Variables/Functions: camelCase
   void sendMessage() { }
   
   // Constants: camelCase with const
   const int maxRetries = 3;
   
   // Private: prefix with _
   String _privateVar;
   ```

4. **File Organization**
   ```
   lib/
   ├── core/           # Business logic
   ├── data/           # Models & database
   ├── services/       # External services
   ├── providers/      # State management
   └── ui/             # User interface
   ```

5. **Comments**
   ```dart
   /// Documentation comments for public APIs
   /// Use triple slash for doc comments
   void publicMethod() { }
   
   // Regular comments for implementation details
   // Use double slash for inline comments
   ```

### UI Guidelines

1. **Theme Consistency**
   - Use `AppTheme` constants for colors
   - Use predefined spacing (`AppTheme.spaceS, spaceM, spaceL`)
   - Use theme text styles

2. **Responsive Design**
   - Test on multiple screen sizes
   - Use `MediaQuery` for dynamic sizing
   - Avoid hardcoded dimensions

3. **Animations**
   - Keep animations subtle (<= 500ms)
   - Use `animate_do` for common animations
   - Ensure smooth 60 FPS

---

## 📝 Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples

```bash
# Good commits
feat(chat): add message editing functionality
fix(bluetooth): resolve connection timeout issue
docs(readme): update installation instructions
test(encryption): add AES-256 encryption tests

# Bad commits
update stuff
fix bug
changes
work in progress
```

### Detailed Example

```
feat(broadcast): add emergency template customization

- Allow users to create custom emergency templates
- Add template management screen
- Persist templates to local database
- Update broadcast screen UI

Closes #123
```

---

## 🔄 Pull Request Process

### Before Submitting

1. ✅ **Update from upstream**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. ✅ **Run tests**
   ```bash
   flutter test
   ```

3. ✅ **Format code**
   ```bash
   dart format .
   ```

4. ✅ **Check for warnings**
   ```bash
   flutter analyze
   ```

5. ✅ **Update documentation** if needed

### Submitting PR

1. **Create feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

2. **Make changes** and commit
   ```bash
   git add .
   git commit -m "feat: add amazing feature"
   ```

3. **Push to your fork**
   ```bash
   git push origin feature/amazing-feature
   ```

4. **Open Pull Request** on GitHub

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tested on physical device
- [ ] Added/updated tests
- [ ] All tests passing

## Screenshots (if applicable)
[Add screenshots here]

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-reviewed code
- [ ] Commented complex code
- [ ] Updated documentation
- [ ] No new warnings
```

### Review Process

1. **Automated checks** must pass (CI/CD)
2. **Code review** by maintainers
3. **Requested changes** must be addressed
4. **Approval** from at least 1 maintainer
5. **Merge** by maintainers

---

## 🧪 Testing Guidelines

### Writing Tests

```dart
// Unit Test Example
test('Should encrypt message correctly', () {
  // Arrange
  final service = EncryptionService();
  const message = 'Hello World';
  
  // Act
  final encrypted = service.encryptMessage(message);
  final decrypted = service.decryptMessage(encrypted);
  
  // Assert
  expect(decrypted, equals(message));
});
```

### Test Coverage

- Aim for **70%+** overall coverage
- **80%+** for core services
- Test edge cases and error handling

### Running Tests

```bash
# All tests
flutter test

# Specific file
flutter test test/unit/encryption_service_test.dart

# With coverage
flutter test --coverage
```

---

## 📚 Documentation

### Code Documentation

```dart
/// Sends a message to a specific user
///
/// [to] The recipient's user ID
/// [content] The message content
/// [isBroadcast] Whether this is a broadcast message
///
/// Returns a [Future] that completes when message is sent
/// Throws [MeshException] if mesh network is not active
Future<void> sendMessage({
  required String to,
  required String content,
  bool isBroadcast = false,
}) async {
  // Implementation
}
```

### README Updates

Update README.md when adding:
- New features
- New dependencies
- Breaking changes
- Installation steps

---

## 🌟 Recognition

Contributors will be:
- Added to `CONTRIBUTORS.md`
- Mentioned in release notes
- Featured on our website (coming soon)

### Top Contributors

Special recognition for:
- 🥇 Most commits
- 🥈 Most PRs
- 🥉 Best bug reports
- 🏆 Best feature suggestions

---

## 💬 Community

### Communication Channels

- 💬 **GitHub Discussions** - General discussions
- 🐛 **GitHub Issues** - Bug reports & features
- 📧 **Email** - support@meshnet.app
- 🐦 **Twitter** - [@meshnetapp](https://twitter.com/meshnetapp)

### Getting Help

- Check [Documentation](README.md)
- Search [existing issues](https://github.com/Mohammad007/mesh_networking_app/issues)
- Ask in [Discussions](https://github.com/Mohammad007/mesh_networking_app/discussions)
- Join our community chat (coming soon)

---

## 🎓 Learning Resources

New to Flutter or mesh networking?

### Flutter Resources
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Codelabs](https://flutter.dev/docs/codelabs)

### Mesh Networking
- [Mesh Network Basics](https://en.wikipedia.org/wiki/Mesh_networking)
- [Wi-Fi Direct Overview](https://www.wi-fi.org/discover-wi-fi/wi-fi-direct)
- [Bluetooth Low Energy](https://www.bluetooth.com/learn-about-bluetooth/bluetooth-technology/bluetooth-低能耗/)

---

## ❓ FAQ

**Q: I'm new to open source. Where do I start?**  
A: Look for issues labeled `good first issue`. These are beginner-friendly!

**Q: How long does PR review take?**  
A: Usually 2-5 days. Complex PRs may take longer.

**Q: Can I work on an issue someone else is assigned to?**  
A: Please ask first in the issue comments.

**Q: My PR was rejected. What now?**  
A: Don't be discouraged! Address the feedback and resubmit.

---

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

<div align="center">

### 🙏 Thank You for Contributing! 🙏

Your contributions make MeshNet better for everyone!

**Questions?** Open a [Discussion](https://github.com/Mohammad007/mesh_networking_app/discussions)

</div>
