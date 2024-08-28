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

      src = fetchzip {
        url = "https://github.com/SELinuxProject/refpolicy/releases/download/RELEASE_2_20240226/refpolicy-2.20240226.tar.bz2";
        hash = "sha256-C0aBjjO7YBi5atl/mmBP1l3fLhtsG/xwFXUMlz20smM=";
        stripRoot = false;
        nativeBuildInputs = [ bzip2 gnutar ];
      };



      buildPhase = ''
        pwd
        cd refpolicy
        pwd
        export (
          topdir = ${out}
          AWK="${pkgs.gawk}/bin/awk" 
          GREP="${pkgs.gnugrep}/bin/grep -E" 
          INSTALL="${pkgs.coreutils}/bin/install" 
          M4="${pkgs.gnum4}/bin/m4 -E -E" 
          PYTHON="${pkgs.python311}/bin/python3 -bb -t -t -E -W error"
          SORT="LC_ALL=C ${pkgs.coreutils}/bin/sort"
          SED="${pkgs.gnused}/bin/sed" 
          CHECKPOLICY="${pkgs.checkpolicy}/bin/checkpolicy" 
          CHECKMODULE="${pkgs.checkpolicy}/bin/checkmodule"
          SEMODULE="${pkgs.policycoreutils}/bin/semodule"
          SEMOD_PKG="${pkgs.semodule-utils}/bin/semodule_package"
          SEMOD_LNK="${pkgs.semodule-utils}/bin/semodule_link"
          SEMOD_EXP="${pkgs.semodule-utils}/bin/semodule_expand"
          LOADPOLICY="${pkgs.policycoreutils}/bin/load_policy"
          SEPOLGEN_IFGEN="${pkgs.selinux-python}/bin/sepolgen-ifgen"
          SETFILES="${pkgs.policycoreutils}/bin/setfiles"
          SEFCONTEXT_COMPILE="${pkgs.libselinux}/bin/sefcontext_compile"
          SECHECK="${pkgs.setools}/bin/sechecker"
          XMLLINT="${pkgs.libxml2}/bin/xmllint"
        )
        make install-src
        cd ${out} 
        make conf
      '';



      nativeBuildInputs = [
        tree

        git
        gawk	      # awk
        gnugrep	    # grep
        coreutils	  # GNU coreutils: install sort
        gnused	    # sed
        gnumake	    # make
        gnum4	      # m4
        policycoreutils # semodule
        checkpolicy     # checkpolicy checkmodule
        semodule-utils  # semodule_link semodule_unpackage semodule_expand semodule_package
        setools         # sechecker
        (libselinux.override { enablePython = true; } )      # sefcontext_compile
        libxml2         # xmllint
      ];
    };
  };

}
