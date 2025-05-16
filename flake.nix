{
  description = "ruby stuff";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixpkgs,
    utils,
  }:
    utils.lib.eachDefaultSystem (system: let
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
          solargraph
          ruby_3_2
          typst
          bundix
        ];
      };

      defaultPackage = pkgs.buildRubyGem {
        src = ./.;
        inherit ruby;
        version = "0.1.0";

        gemName = "5echar";
        pname = "5echar";

        buildInputs = [gems];
        
        nativeBuildInputs = [ pkgs.makeWrapper ];

        # <https://github.com/NixOS/nixpkgs/blob/5c0c4807e49b1f5a2d2f125aaad6b3ddffa6a097/pkgs/by-name/va/vagrant/package.nix>
        preFixup = ''
          wrapProgram $out/bin/5echar \
              --prefix GEM_HOME : "${gems}/lib/ruby/gems/${ruby.version.libDir}" \
              --prefix GEM_PATH : "${gems}/lib/ruby/gems/${ruby.version.libDir}"
          '';

        meta = with pkgs.lib; {
          description = "5echar";
          license = licenses.mit;
          maintainers = [ "0xmycf" ];
          platforms = utils.lib.defaultSystems;
        };

      };
    });
}
