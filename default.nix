{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation {
  name = "fbhlpsnw3chan4";
  src = ./.;
  buildInputs = with pkgs; [ faust2sc faust ];
  buildPhase = ''
    	      faust2sc --supernova -n0 fbhlpsnw3chan4.dsp 
    	    '';
  installPhase = ''
    mkdir $out
    cp *.so $out
  '';
}
