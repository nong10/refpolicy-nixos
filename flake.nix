{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs, ... }@inputs: 
  let 
    pkgs = import nixpkgs { 
      overlays = [ 
        (final: prev: {
          libsemanage = prev.libsemanage.overrideAttrs {
            prePatch = ''
              pwd
              ls
            ''; 
            patchPhase = ''
              patch -p1 "${./conf-parse.y.patch}"
            '';
          };
        })
      ];
    }; 
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

      fixupPhase = ''
        cd $out/refpolicy/src/policy
        make conf
      '';




      nativeBuildInputs = [
        tree
        getopt
        git
        gawk	      # awk
        gnugrep	    # grep
        coreutils	  # GNU coreutils: install sort
        gnused	    # sed
        gnumake	    # make
        gnum4	      # m4
        (pkgs.applyPatches {
          src = pkgs.policycoreutils;
          patches = [
            (pkgs.writeText "" ''
--- a/src/conf-parse.y      2024-08-27 15:48:20.094331321 +0000
+++ b/src/conf-parse.y      2024-08-27 16:06:57.514785742 +0000
@@ -353,7 +353,7 @@
        conf->store_path = strdup(basename(selinux_policy_root()));
        conf->ignoredirs = NULL;
        conf->store_root_path = strdup("/var/lib/selinux");
-       conf->compiler_directory_path = strdup("/usr/libexec/selinux/hll");
+       conf->compiler_directory_path = strdup("${pkgs.policycoreutils}/libexec/selinux/hll");
        conf->policyvers = sepol_policy_kern_vers_max();
        conf->target_platform = SEPOL_TARGET_SELINUX;
        conf->expand_check = 1;
@@ -377,7 +377,7 @@
        if (access("/sbin/load_policy", X_OK) == 0) {
                conf->load_policy->path = strdup("/sbin/load_policy");
        } else {
-               conf->load_policy->path = strdup("/usr/sbin/load_policy");
+               conf->load_policy->path = strdup("${pkgs.policycoreutils}/bin/load_policy");
        }
        if (conf->load_policy->path == NULL) {
                return -1;
@@ -391,7 +391,7 @@
        if (access("/sbin/setfiles", X_OK) == 0) {
                conf->setfiles->path = strdup("/sbin/setfiles");
        } else {
-               conf->setfiles->path = strdup("/usr/sbin/setfiles");
+               conf->setfiles->path = strdup("${pkgs.policycoreutils}bin/setfiles");
        }
        if ((conf->setfiles->path == NULL) ||
            (conf->setfiles->args = strdup("-q -c $@ $<")) == NULL) {
@@ -405,7 +405,7 @@
        if (access("/sbin/sefcontext_compile", X_OK) == 0) {
                conf->sefcontext_compile->path = strdup("/sbin/sefcontext_compile");
        } else {
-               conf->sefcontext_compile->path = strdup("/usr/sbin/sefcontext_compile");
+               conf->sefcontext_compile->path = strdup("${pkgs.libselinux}/bin/sefcontext_compile");
        }
        if ((conf->sefcontext_compile->path == NULL) ||
            (conf->sefcontext_compile->args = strdup("$@")) == NULL) {
            '')
          ];
        })
        #policycoreutils # semodule
        checkpolicy     # checkpolicy checkmodule
        semodule-utils  # semodule_link semodule_unpackage semodule_expand semodule_package
        setools         # sechecker
        (libselinux.override { enablePython = true; } )      # sefcontext_compile
        libxml2         # xmllint
      ];
    };
  };

}
