{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  chromium,
}:
let
  source = import ./version.nix;
in
buildNpmPackage {
  pname = "playwright-cli";
  inherit (source) version;

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "playwright-cli";
    rev = "v${source.version}";
    inherit (source) hash;
  };

  inherit (source) npmDepsHash;
  dontNpmBuild = true;

  makeWrapperArgs = [
    "--set-default"
    "NO_UPDATE_NOTIFIER"
    "true"
    "--set-default"
    "PLAYWRIGHT_MCP_BROWSER"
    "chromium"
    "--set-default"
    "PLAYWRIGHT_MCP_EXECUTABLE_PATH"
    (lib.getExe chromium)
  ];

  meta = {
    description = "CLI for common Playwright browser automation actions";
    homepage = "https://github.com/microsoft/playwright-cli";
    license = lib.licenses.asl20;
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
    mainProgram = "playwright-cli";
  };
}
