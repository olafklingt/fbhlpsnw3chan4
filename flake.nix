{
  description = "fbhlpsnw3chan4";

  inputs = {
    nixpkgs.url = "github:olafklingt/nixpkgs/faust";
  };

  outputs = { self, nixpkgs }:
    let
      # Systems supported
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
#        "aarch64-linux" # 64-bit ARM Linux
#        "x86_64-darwin" # 64-bit Intel macOS
#        "aarch64-darwin" # 64-bit ARM macOS
      ];

      # Helper to provide system-specific attributes
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      packages = forAllSystems ({ pkgs }: {
        default = pkgs.stdenv.mkDerivation {
            name = "fbhlpsnw3chan4";
            src = self;
            buildInputs = with pkgs; [faust faust2supercollider ];
            buildPhase = "faust2supercollider -sn fbhlpsnw3chan4.dsp ";
            installPhase = ''
              mkdir -p $out/lib
              cp fbhlpsnw3chan4.so $out/lib/
            '';
          };
      });
    };
}
