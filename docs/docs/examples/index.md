---
sidebar_position: 1
sidebar_label: "Overview"
---

# Examples

Complete Flutter apps that demonstrate riverpod_craft in practice. They're ordered from simple to complex — start at the top and work your way down.

| Example | What it covers | Key features |
|---------|---------------|--------------|
| [Counter](/docs/examples/counter) | Sync state management | `@provider`, `@settable`, class-based provider |
| [Quote](/docs/examples/quote) | Async fetching + side effects | `Future` provider, `@command`, `@keepAlive` |
| [Notes](/docs/examples/notes) | Full CRUD with filtering | Class commands, `@settable`, family providers, `reload()` |
| [Movies App](/docs/examples/movies-app) | Real API, pagination, streams | `Stream` provider, `Paged<T>`, `@restartable`, `@droppable` |
| [Command Strategies](/docs/examples/command-strategies) | All 4 command execution modes | `@concurrent`, `@sequential`, `@droppable`, `@restartable` |

All source code lives in the [`examples/`](https://github.com/Ahmed-Omar-Hommir/riverpod_craft/tree/master/examples) directory.
