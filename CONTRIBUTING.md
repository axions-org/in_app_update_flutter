# Contributing to in_app_update_flutter

Thanks for considering contributing. Bug reports, feature requests, documentation improvements, and pull requests are all welcome.

If you have a question rather than a contribution, please use [GitHub Discussions](https://github.com/axions-org/in_app_update_flutter/discussions) instead of opening an issue.

---

## Table of contents

- [Ways to contribute](#ways-to-contribute)
- [Development setup](#development-setup)
- [Code conventions](#code-conventions)
- [Testing](#testing)
- [Pull request process](#pull-request-process)
- [Release process (maintainers)](#release-process-maintainers)

---

## Ways to contribute

### Report a bug

Open a [bug report](https://github.com/axions-org/in_app_update_flutter/issues/new?template=bug_report.yml) and include:

- Which platform (iOS, Android, or both)
- Steps to reproduce
- Expected vs actual behavior
- Package version, Flutter version, and OS/device details
- A minimal code sample if possible

### Suggest a feature

Open a [feature request](https://github.com/axions-org/in_app_update_flutter/issues/new?template=feature_request.yml) and describe:

- What problem you are trying to solve
- How you would like the API to work (if you have a specific design in mind)
- Any alternatives you have considered

### Improve documentation

Documentation issues can be reported using the [documentation template](https://github.com/axions-org/in_app_update_flutter/issues/new?template=documentation.yml). Pull requests that improve the README, API docs, code comments, or the example app are appreciated.

### Submit a pull request

See the [pull request process](#pull-request-process) below.

---

## Development setup

```bash
# Clone the repository
git clone https://github.com/axions-org/in_app_update_flutter.git
cd in_app_update_flutter

# Install Dart dependencies
flutter pub get

# Install example app dependencies
cd example
flutter pub get
cd ..
```

### Project structure

```
in_app_update_flutter/
  lib/
    in_app_update_flutter.dart          # Public API facade
    src/
      platform_interface/               # Abstract platform interface
      method_channel/                   # Default MethodChannel implementation
      models/                           # Android data models
  android/
    src/main/kotlin/.../                # Android Kotlin plugin (Play Core)
    src/test/kotlin/.../                # Android unit tests
  ios/
    in_app_update_flutter/              # iOS Swift plugin (StoreKit, SPM)
  example/
    lib/main.dart                       # Example Flutter app
    test/                               # Example widget tests
    integration_test/                   # Integration tests
  test/                                 # Dart unit tests
  doc/                                  # Additional docs
```

---

## Code conventions

### Dart

- Run `dart format .` before committing. The CI pipeline enforces formatting.
- Follow the style defined in `analysis_options.yaml` (based on `flutter_lints`).
- Write doc comments for all public API members.

### Kotlin

- Follow standard Kotlin conventions.
- Use Mockito for unit tests.

### Swift

- Follow standard Swift conventions.
- The iOS plugin uses Swift Package Manager (SPM) with CocoaPods backward compatibility.

### General

- Keep changes focused. A pull request should do one thing.
- Do not introduce new dependencies without good reason.
- Do not commit secrets, credentials, or generated files.

---

## Testing

All changes must keep existing tests passing.

```bash
# Run all Dart unit tests
flutter test

# Run Android unit tests
cd android && ./gradlew test && cd ..

# Run the example app widget tests
cd example && flutter test && cd ..
```

If you add new functionality, include tests that cover:

- The Dart API (using mock platform or method channel mocks)
- The native platform code (Kotlin unit tests for Android)
- Edge cases and error conditions

CI runs `flutter test --coverage` on every pull request and uploads coverage to Codecov.

---

## Pull request process

1. Create a branch from `production`. Use a descriptive name like `feat/description` or `fix/description`.

2. Make your changes. Keep commits small and descriptive.

3. Run the checks:

```bash
dart format .
flutter analyze
flutter test
```

4. Push your branch and open a pull request against `production`. Use the pull request template and fill in all relevant sections.

5. The CI pipeline will run four checks in parallel:
   - `flutter analyze` for lint and type errors
   - `dart format` for code formatting
   - `flutter test --coverage` for unit tests
   - `flutter pub publish --dry-run` to verify the package is publishable

6. A maintainer will review your changes. They may ask for changes or clarification.

7. Once all checks pass and the review is approved, a maintainer will merge your PR.

### Checklist for pull requests

- Changes tested on a real device or emulator (not just unit tests)
- Dart API changes reflected in both platforms (if applicable)
- Public API changes documented in the README
- `CHANGELOG.md` updated for user-facing changes
- Existing tests pass (`flutter test`)
- New tests added for new behavior

---

## Release process (maintainers)

1. Update `CHANGELOG.md` with the new version notes.
2. Update the `version` field in `pubspec.yaml`.
3. Merge to `production` via pull request.
4. Tag the release:

```bash
git checkout production
git pull
git tag vX.Y.Z
git push origin vX.Y.Z
```

5. The CD pipeline publishes the package to pub.dev and creates a GitHub Release automatically.

For details about the CI/CD pipeline, see the [CI/CD overview](doc/ci-cd-overview.md).
