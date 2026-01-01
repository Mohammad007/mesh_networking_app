# Test Coverage Report
# Run: flutter test --coverage
# Generate HTML: genhtml coverage/lcov.info -o coverage/html

# Test Commands:
# Unit Tests: flutter test test/unit/
# Widget Tests: flutter test test/widget/
# Integration Tests: flutter test integration_test/
# All Tests: flutter test

## Test Structure

### Unit Tests (`test/unit/`)
- `encryption_service_test.dart` - Tests encryption, hashing, signatures
- `mesh_engine_test.dart` - Tests message routing, TTL, relaying

### Widget Tests (`test/widget/`)
- `home_dashboard_test.dart` - Tests home screen UI & state
- `broadcast_screen_test.dart` - Tests emergency broadcast UI
- `settings_screen_test.dart` - Tests settings screen & controls

### Integration Tests (`integration_test/`)
- `app_test.dart` - Tests complete user flows & navigation

## Test Coverage Goals

- **Unit Tests**: 80%+ coverage for services
- **Widget Tests**: All major screens tested
- **Integration Tests**: Key user journeys tested

## Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/encryption_service_test.dart

# Run integration tests
flutter test integration_test/

# Run tests in debug mode
flutter test --debug
```

## CI/CD Integration

Add to your CI/CD pipeline:

```yaml
- name: Run Tests
  run: flutter test --coverage
  
- name: Upload Coverage
  uses: codecov/codecov-action@v3
  with:
    files: coverage/lcov.info
```

## Test Mocking

For services that require mocking:
- Use `mockito` for service mocks
- Use `flutter_test` built-in mocking for simple cases
- Mock network calls, database, and device features

## Performance Benchmarks

Integration tests include:
- App launch time < 5 seconds
- Smooth screen transitions
- Responsive UI interactions
