let
	tarball = "https://github.com/NixOS/nixpkgs/archive/f0869b1a2c0b150aac26e10bb5c2364ffb2e804f.tar.gz";
	
	x86pkgs = import (fetchTarball tarball) {
    localSystem = { system = "x86_64-linux"; };
  };

	pkgs = import (fetchTarball tarball) {};

	pypkgs = [ pkgs.python3Packages.pandas
				 	   pkgs.python3Packages.tqdm
						 pkgs.python3Packages.matplotlib ];

	deps = p: [
							p.zlib
							p.curl
			 	 			p.getopt
							p.flex
							p.binutils
							p.bison
							p.bc
							p.pkg-config
							p.m4
							p.which
							p.cmake
							p.gettext
							p.autoconf
							p.sqlite
							p.openssl
							p.yasm
							p.glib
							p.libxml2
							p.ninja
						];

in

with import (fetchTarball tarball) {};

gcc10Stdenv.mkDerivation {
  X86-DEPS = buildEnv {
	  name = "risotto-x86";
		paths = deps x86pkgs;
		pathsToLink = [ "/include" "/lib" "/lib64" "/bin" "/usr" "/usr/lib" ];
    extraOutputsToInstall = [ "out" "bin" "dev" ];
	};

  RISOTTO_ROOT = builtins.getEnv "RISOTTO_ROOT";
	
	name = "risotto-native";
	nativeBuildInputs = [
	 	bashInteractive
	];
	buildInputs = pypkgs ++ deps pkgs;
}