{
  description = "ruby stuff";

  inputs.nixpkgs.url =  "github:nixos/nixpkgs/nixos-unstable";
  inputs.utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixpkgs,
    utils,
  }: utils.lib.eachDefaultSystem (system: 
    let
    pkgs = nixpkgs.legacyPackages.${system};
    ruby = pkgs.ruby_3_2;
    gems = pkgs.bundlerEnv {
      name = "5echar";
      inherit ruby;
      gemdir = ./.;
    };
    in {
    devShell = pkgs.mkShellNoCC {
        packages = with pkgs; [
          gems
          solargraph
          ruby_3_2
        ];
      };

      # This doesnt work so dont try to use it
      defaultPackage = pkgs.stdenv.mkDerivation {
        name = "5echar";
        src = ./.;
        buildInputs = [ gems gems.wrappedRuby ];
        installPhase = ''
          mkdir -p $out
          cp -r $src $out
          mkdir $out/bin
        '';
      };

    });
}
