{ supportedSystems ? ["x86_64-linux"]
, supportedCompilers ? [ "ghc802" "ghc821" "ghc841" ] 
}:

with (import <nixpkgs/pkgs/top-level/release-lib.nix> { inherit supportedSystems; });

let
  pkgs = import <nixpkgs> {};

  configurations = 
    pkgs.lib.listToAttrs (
      pkgs.lib.concatMap (compiler: 
        pkgs.lib.concatMap (system: 
          [{name = "haskell.packages." + compiler + ".vfr-waypoints." + system ; value = {inherit compiler system;};}]
        ) supportedSystems
      ) supportedCompilers
    );

  jobs =
      pkgs.lib.mapAttrs (name: configuration: 
          let
            compiler = configuration.compiler; 
            system = configuration.system; 
            nixpkgs = { pkgs = pkgsFor system; };
            vfr-waypoints = import ../default.nix { inherit nixpkgs compiler; };
          in
            vfr-waypoints
      ) configurations;
in
  jobs
