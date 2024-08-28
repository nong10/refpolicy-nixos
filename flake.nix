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


      preInstall = ''
        pwd
        cd refpolicy
        pwd
        export AWK="${pkgs.gawk}/bin/awk" 
        export GREP="${pkgs.gnugrep}/bin/grep -E" 
        export INSTALL="${pkgs.coreutils}/bin/install" 
        export M4="${pkgs.gnum4}/bin/m4 -E -E" 
        export PYTHON="${pkgs.python311}/bin/python3 -bb -t -t -E -W error"
        export SORT="LC_ALL=C ${pkgs.coreutils}/bin/sort"
        export SED="${pkgs.gnused}/bin/sed" 
        export CHECKPOLICY="${pkgs.checkpolicy}/bin/checkpolicy" 
        export CHECKMODULE="${pkgs.checkpolicy}/bin/checkmodule"
        export SEMODULE="${pkgs.policycoreutils}/bin/semodule"
        export SEMOD_PKG="${pkgs.semodule-utils}/bin/semodule_package"
        export SEMOD_LNK="${pkgs.semodule-utils}/bin/semodule_link"
        export SEMOD_EXP="${pkgs.semodule-utils}/bin/semodule_expand"
        export LOADPOLICY="${pkgs.policycoreutils}/bin/load_policy"
        export SEPOLGEN_IFGEN="${pkgs.selinux-python}/bin/sepolgen-ifgen"
        export SETFILES="${pkgs.policycoreutils}/bin/setfiles"
        export SEFCONTEXT_COMPILE="${pkgs.libselinux}/bin/sefcontext_compile"
        export SECHECK="${pkgs.setools}/bin/sechecker"
        export XMLLINT="${pkgs.libxml2}/bin/xmllint"
        #echo "${out}"
        #ls ${out}
        #make install-src topdir=${out}
        #cd ${out} 
        #make conf
      '';

#      installFlags = [ "topdir=$(out)" ];
#      installTargets = [ "install-src" ];

      installPhase = ''
        pwd
        echo $out
        cd refpolicy
        pwd
        make install-src topdir=$out
      '';

      postInstall = ''
        pwd
        echo $out
        cd $out
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
