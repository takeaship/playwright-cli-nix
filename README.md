# playwright-cli-nix

`playwright-cli-nix` packages Microsoft's official
[`@playwright/cli`](https://github.com/microsoft/playwright-cli) npm release as a
reusable Nix flake for x86_64 and ARM64 Linux.

## Use

Run Playwright CLI directly:

```sh
nix run github:takeaship/playwright-cli-nix -- --help
```

Or add it as a flake input:

```nix
inputs.playwright-cli.url = "github:takeaship/playwright-cli-nix";
```

Then install `inputs.playwright-cli.packages.${pkgs.system}.default`.

The wrapper uses nixpkgs Chromium by default, so it does not download a browser
into `~/.cache/ms-playwright`. You can override `PLAYWRIGHT_MCP_BROWSER` and
`PLAYWRIGHT_MCP_EXECUTABLE_PATH` when another browser is required. Upstream's
update notifier is disabled because upgrades are managed by this flake.

## Platform scope

The package supports `x86_64-linux` and `aarch64-linux`. macOS is not exposed
because this flake deliberately supplies Chromium as part of the Nix closure;
nixpkgs does not provide the same Chromium package on macOS.

## Security and updates

`version.nix` pins the upstream version, GitHub source archive hash, and complete
npm dependency hash. The scheduled/manual workflow resolves the latest npm
release, requires the matching GitHub tag, and rejects downgrades. A read-only
job builds the candidate and launches Chromium against `https://example.com`.
Only after validation succeeds does a separate write-enabled job re-resolve the
same inputs, ensure `main` has not moved, and commit `version.nix` without
executing the candidate CLI.

The source tag, npm metadata, and npm dependencies ultimately share upstream
publisher trust. Their pinned hashes make an accepted release reproducible but
do not independently authenticate a compromised upstream release.
