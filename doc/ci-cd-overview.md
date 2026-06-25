# CI/CD Overview

## 1. What checks are in the CI/CD pipeline?

### CI (Continuous Integration) with `ci.yml`

| Check | What it does |
|-------|-------------|
| **analyze** | Runs `flutter analyze` to catch lint warnings, type errors, and style violations defined in `analysis_options.yaml`. |
| **format** | Runs `dart format --set-exit-if-changed .` to ensure all Dart code follows the standard Dart formatting rules. Fails if any file is not properly formatted. |
| **test** | Runs `flutter test --coverage` to execute all unit tests and generate a coverage report. Uploads coverage data to Codecov. |
| **dry-run-publish** | Runs `flutter pub publish --dry-run` to verify the package is in a valid, publishable state (correct pubspec, no missing files, etc.) without actually publishing. |

### CD (Continuous Deployment) with `cd.yml`

| Check | What it does |
|-------|-------------|
| **publish** | Runs `dart pub publish --force` to publish the package to pub.dev using the stored authentication token. |
| **github-release** | Extracts the latest version's notes from `CHANGELOG.md` and creates a GitHub Release with those notes. Runs only after `publish` succeeds. |

---

## 2. When does CI run?

CI runs automatically on:

- **Every pull request** targeting the `production` branch

This means every change gets validated before it can be merged into `production`.

---

## 3. When does CD run?

CD runs **only** when a git tag matching `v*` is pushed. For example:

```bash
git tag v1.0.0
git push origin v1.0.0
```

This triggers the publish to pub.dev and the GitHub Release creation. Merging to `production` alone does **not** trigger a publish. You must explicitly tag a release.

---

## 4. How many checks run?

| Trigger | Number of checks | Checks |
|---------|-----------------|--------|
| PR to `production` | 4 | analyze, format, test, dry-run-publish |
| Push a `v*` tag | 2 | publish, github-release |

All 4 CI checks run in parallel. In the CD pipeline, `github-release` runs sequentially after `publish` succeeds.

---

## 5. Branch protection rules

The following rules are applied to the `production` branch in GitHub Settings:

| Rule | Why | When it applies |
|------|-----|-----------------|
| **Require a pull request before merging** | Prevents direct pushes to `production`. All changes must go through a PR, providing a clear review trail and ensuring CI runs before merge. | Every time someone tries to push or merge into `production`. |
| **Require status checks to pass** (`analyze`, `format`, `test`) | Ensures no broken, unformatted, or failing code reaches `production`. The three checks must all pass before the PR merge button becomes available. | When a PR targets `production`. GitHub blocks the merge until all three checks are green. |
| **Require branches to be up to date before merging** | Ensures the PR has been tested against the latest `production` code, not a stale version. Prevents cases where two PRs pass individually but conflict when both are merged. | When merging a PR. If `production` has moved ahead since the branch was last updated, you must update your branch first. |
| **Do not allow force pushes** | Protects the commit history of `production` from being rewritten. Force pushes can destroy commits and break other contributors' branches. | Any time someone attempts `git push --force` to `production`. |
| **Do not allow deletions** | Prevents accidental or intentional deletion of the `production` branch. | Any time someone attempts to delete the `production` branch. |

---

## 6. Contributing workflow

Here is the recommended workflow for contributing to this project:

```mermaid
graph LR
    A[Fork repo] --> B[Create branch from production]
    B --> C[Make changes]
    C --> D[Write / update tests]
    D --> E[Run dart format .]
    E --> F[Run flutter analyze]
    F --> G[Run flutter test]
    G --> H[Push branch]
    H --> I[Open PR against production]
    I --> J[CI runs: analyze, format, test, dry-run]
    J --> K[Code review]
    K --> L[Merge to production]
```

### Quick reference

```bash
# Create a feature branch
git checkout -b feat/my-feature production

# Format your code
dart format .

# Analyze
flutter analyze

# Run tests
flutter test

# Run Android unit tests (from project root)
cd android && ./gradlew test && cd ..
```

### Release process (maintainers only)

1. Update `CHANGELOG.md` with the new version notes.
2. Update `pubspec.yaml` version number.
3. Merge to `production` via PR.
4. Tag the release:
   ```bash
   git checkout production
   git pull
   git tag vX.Y.Z
   git push origin vX.Y.Z
   ```
5. CD automatically publishes to pub.dev and creates a GitHub Release.
