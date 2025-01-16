{
  description = "Google Cloud SDK with GKE auth plugin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils}:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        packages = {
          google-cloud-sdk = with pkgs; google-cloud-sdk.withExtraComponents [
            google-cloud-sdk.components.gke-gcloud-auth-plugin
          ];
        };
      }
    );
}
