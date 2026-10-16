# NetworkKit

Small async/await HTTP client for iOS built on top of [Alamofire](https://github.com/Alamofire/Alamofire).
It is **host-agnostic**: the app injects an `ApiConfiguration` (scheme, host, base path,
default headers, timeout); the library never reads `Bundle.main` or build settings itself.

## Requirements

- iOS 17+
- Swift 5.9+
- Depends on [Alamofire](https://github.com/Alamofire/Alamofire) 5.10+

## Installation

Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/CarlitosDroid/network-kit-ios.git", from: "1.0.0"),
]
```

Then add the `NetworkKit` product to your target.

### Tuist

```swift
// Tuist/Package.swift
#if TUIST
import struct ProjectDescription.PackageSettings

let packageSettings = PackageSettings(
    productTypes: [
        "Alamofire": .framework,
    ]
)
#endif

let package = Package(
    name: "MyApp",
    dependencies: [
        .package(url: "https://github.com/CarlitosDroid/network-kit-ios.git", from: "1.0.0"),
    ]
)
```

```swift
// Project.swift
dependencies: [
    .external(name: "NetworkKit"),
]
```

## Usage

```swift
import NetworkKit

let client = ApiClient(
    configuration: ApiConfiguration(
        host: "api.example.com",
        basePath: "/api",
        defaultHeaders: ["Accept": "application/json"],
        timeout: 30
    )
)

struct LoginRequest: Encodable { let email: String; let password: String }
struct LoginResponse: Decodable { let accessToken: String }

// Relative endpoint: https://api.example.com/api/v1/auth/login
let result: Result<LoginResponse, Error> = await client.request(
    endpoint: Endpoint("/v1/auth/login"),
    method: .post,
    parameters: LoginRequest(email: "user@example.com", password: "secret")
)

// Full URL (third-party API); default headers are NOT applied
let countries: Result<[Country], Error> = await client.request(
    url: URL(string: "https://restcountries.com/v3.1/all")!,
    method: .get
)
```

Failures are reported as `NetworkError`: `.invalidURL`, `.transport`, `.decoding` and
`.server(status:message:code:)`. Server errors are decoded from a JSON body shaped as
`{ "detail": String, "code": String?, "status": Int }`.

In `DEBUG` builds, requests and responses are logged through `OSLog` (subsystem `NetworkKit`).

## Branch model & publishing

Versioning is automatic via [semantic-release](https://semantic-release.gitbook.io)
driven by [Conventional Commits](https://www.conventionalcommits.org):

| Branch | Workflow | What happens |
|--------|----------|--------------|
| `develop` | `develop.yml` | Build + test. No publish. |
| `main` | `release.yml` | Tests, then semantic-release decides the version from commits; if warranted, it tags, writes the changelog and publishes the release. |

You do NOT create tags manually. Merge to `main` with conventional commits:

- `feat: ...` → minor bump
- `fix: ...` / `perf:` / `refactor:` → patch bump
- `BREAKING CHANGE:` → major bump
- `docs:` / `chore:` / `test:` / `ci:` → no release

## Local development

```bash
swift build
swift test
```

## License

MIT. See [LICENSE](LICENSE).
