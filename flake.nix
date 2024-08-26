{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs, ... }@inputs: 
  let 
    pkgs = import nixpkgs {}; 
    system = "x86_64-linux";
  in
  with pkgs; with stdenv;	
  {
    packages.${system}.default = mkDerivation {
      name = "refpolicy";
      src = fetchFromGitHub {
        owner = "SELinuxProject";
        repo = "refpolicy";
        rev = "RELEASE_2_20240226";	  # a tag
        hash = "7ed41f4f45189b9ee9706da8ac357eccc103651b56daabaddb54c436e8117cf9";
      };
    };
  };

}
