# Anonymous Forum UI — Logos Basecamp QML Module

QML user interface for the Anonymous Forum with Threshold Moderation, designed to run as a Logos Basecamp UI module.

## Overview

This module provides a **3-view interface** for interacting with the anonymous forum protocol:

1. **Forums / Register** — Member registration and aggregator setup
2. **Post** — Anonymous post creation with cryptographic proof generation
3. **Moderate** — Moderator login, strike issuance, and NSK reconstruction (slash)

All operations are dispatched to the [anonymous_forum_core](https://github.com/syafiqeil/anonymous_forum_core) backend module via Logos IPC.

### How It Works

```
┌─────────────────────────────────────────────────────────┐
│                    QML UI (this repo)                   │
│                                                         │
│  ┌──────────────┐  ┌─────────────┐  ┌────────────────┐  │
│  │   Forums /   │  │   Create    │  │  Moderation    │  │
│  │  Register    │  │ Anonymous   │  │  Dashboard     │  │
│  │   View       │  │   Post      │  │                │  │
│  └──────┬───────┘  └──────┬──────┘  └────────┬───────┘  │
│         │                 │                  │          │
│         └─────────────────┼──────────────────┘          │
│                           │                             │
│              logos.callModule(                          │
│                "anonymous_forum_core",                  │
│                "<method>", [args])                      │
│                          │                              │
└──────────────────────────┼──────────────────────────────┘
                           │ IPC (Qt RemoteObjects)
                           ▼
              ┌────────────────────────┐
              │  anonymous_forum_core  │
              │  (C++ Qt Plugin)       │
              │         │ FFI          │
              │         ▼              │
              │  liblogos_moderation_  │
              │  sdk.so (Rust)         │
              └────────────────────────┘
```

## Project Structure

```
anonymous_forum_ui/
├── flake.nix         # Nix build — uses mkLogosQmlModule + core dependency
├── metadata.json     # Module config (type: ui_qml, depends on core)
└── qml/
    └── Main.qml      # Complete 3-view UI (374 lines)
```

## Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- `anonymous_forum_core` cloned as a sibling directory:

```
parent/
├── anonymous_forum_core/   # Core module (must exist)
└── anonymous_forum_ui/     # This repo
```

## Build & Run

### Standalone App (Development & Demo)

The recommended way to run — launches a standalone Logos container with both modules bundled:

```bash
nix run --impure
```

> **Note:** `--impure` is required because the core module is referenced via a local `path:` input. After pushing to GitHub, you can replace the path with a GitHub URL to avoid this flag.

### Build Outputs

```bash
# Build the QML module
nix build

# Build .lgx package (for distribution)
nix build .#lgx

# Build install bundle
nix build .#install
```

## UI Views

### 1. Forums / Register

- **Register Member** — Enter NSK (hex), configure K-strikes and N-of-M parameters
- **Moderator Setup** — Input moderator public keys (JSON array), create aggregator

### 2. Create Anonymous Post

- **Message** — Free-text content to post anonymously
- **Post Salt** — 32-byte hex salt (unique per post, ensures unlinkability)
- **Output** — Full PostPayload JSON including tracing tag and encrypted shares

### 3. Moderation Dashboard

- **Moderator Login** — Authenticate with private key
- **Issue Strike** — Submit tracing tag + encrypted share to generate a ModerationCertificate
- **Reconstruct Strike (Tier 1)** — Combine N certificates to reconstruct per-post secret
- **Reconstruct NSK (Tier 2 — Slash)** — Combine K strikes to recover member's NSK

## Customizing the Core Module Source

By default, `flake.nix` references the core module as a sibling directory:

```nix
anonymous_forum_core.url = "path:../anonymous_forum_core";
```

To use a GitHub-hosted core module instead:

```nix
anonymous_forum_core.url = "github:syafiqeil/anonymous_forum_core";
```

## Related Repositories

- **[logos-execution-zone](https://github.com/syafiqeil/logos-execution-zone)** — On-chain programs + Rust SDK
- **[anonymous_forum_core](https://github.com/syafiqeil/anonymous_forum_core)** — Core module (backend dependency)

## License

See repository root for license information.
