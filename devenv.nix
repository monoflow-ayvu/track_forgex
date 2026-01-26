{ pkgs, lib, ... }:
let
  commonPackages = with pkgs; [
    # utils for dependencies
    git
    openssh
    gh
  ];

  mcp_proxy_rust = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "mcp-proxy";
    version = "0.2.2";

    src = pkgs.fetchurl {
      url = "https://github.com/tidewave-ai/mcp_proxy_rust/releases/download/v${version}/mcp-proxy-x86_64-unknown-linux-gnu.tar.gz";
      sha256 = "sha256-0zrNKf1PtMdbI2sEQqlqlK+5pDguPoNTGYSlRNyO930=";
    };

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
    ];

    # Common runtime libs (adjust if not needed)
    buildInputs = [
      pkgs.stdenv.cc.cc.lib
      pkgs.zlib
      pkgs.openssl
    ];

    # Don’t rely on default unpack; just untar the payload.
    unpackPhase = ''
      runHook preUnpack
      mkdir source
      cd source
      tar -xzf ${src}
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      # Find the binary inside the tarball (adjust if it has a different name/path)
      bin="$(find . -maxdepth 2 -type f -name 'mcp-proxy' | head -n1)"
      if [ -z "$bin" ]; then
        echo "mcp-proxy binary not found in archive"
        exit 1
      fi
      install -m755 "$bin" $out/bin/mcp-proxy
      runHook postInstall
    '';

    meta = {
      description = "Prebuilt mcp-proxy binary";
      platforms = [ "x86_64-linux" ];
    };
  };


  linuxOnly = lib.optionals pkgs.stdenv.isLinux [
    pkgs.inotify-tools
    (pkgs.lib.getBin mcp_proxy_rust)
  ];

  basePackages = commonPackages ++ linuxOnly;

in {
  languages = {
    elixir.enable = true;
    erlang.enable = true;
    rust.enable = true;
  };

  cachix = {
    enable = true;
    pull = [ "pre-commit-hooks" "fermuch" ];
  };

  # Enable devcontainer to generate a devcontainer.json file
  devcontainer.enable = true;

  # Install packages
  packages = basePackages;

  # publish the libraries to the environment
  env.LIBRARY_PATH = pkgs.lib.makeLibraryPath basePackages;
  env.LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath basePackages;
  env.PKG_CONFIG_PATH = pkgs.lib.makeSearchPath "lib/pkgconfig" basePackages;

  # Enable shell history for erlang/elixir
  env.ERL_AFLAGS = "-kernel shell_history enabled";

  # Configure UTF-8 locale for proper Unicode support
  env.LC_ALL = "en_US.UTF-8";
  env.LANG = "en_US.UTF-8";
}
