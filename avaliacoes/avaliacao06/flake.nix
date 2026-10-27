{
  description = "Ambiente de desenvolvimento Flutter para Android";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };

        # Compõe um Android SDK com as versões que você precisa
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          buildToolsVersions = [ "34.0.0" "28.0.3" ];
          platformVersions = [ "34" "28" ];
          abiVersions = [ "armeabi-v7a" "arm64-v8a" ];
        };
        androidSdk = androidComposition.androidsdk;

      in {
        devShell = with pkgs; mkShell rec {
          # Variável essencial para o Flutter encontrar o Android SDK
          ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";

          buildInputs = [
            flutter
            androidSdk
            jdk17
          ];
        };
      });
}
