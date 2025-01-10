{
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/release-24.11";
		flake-utils.url = "github:numtide/flake-utils";
	};

	outputs = { self, nixpkgs, flake-utils }:
		flake-utils.lib.eachDefaultSystem (system:
			let pkgs = import nixpkgs {
				inherit system;
			};
			i3lock-fancy-acceptably-fast = pkgs.rustPlatform.buildRustPackage {
				pname = "i3lock-fancy-acceptably-fast";
				version = "0.1.0";

				buildInputs = with pkgs; [
					xorg.libxcb
					ocl-icd
				];

				propagatedBuildInputs = [ pkgs.i3lock ];

				src = ./.;
				cargoLock.lockFile = ./Cargo.lock;
			}; in {
				devShell = pkgs.mkShell {
					buildInputs = with pkgs; [
						cargo
						clippy
						xorg.libxcb
						ocl-icd
					];
				};

				packages.default = i3lock-fancy-acceptably-fast;
		});
}
