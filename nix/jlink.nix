# SEGGER J-Link, pinned and with a working download.
#
# J-Link is unfree, so the NixOS cache never has it: every machine downloads
# the tarball from SEGGER through a licence-accept POST. Two problems with
# taking it from the system nixpkgs:
#
#   1. Every nixpkgs update that bumps J-Link means a fresh download and a new
#      "segger-jlink-qt4-<version>" entry in permittedInsecurePackages.
#      Fix: build it from its own nixpkgs input (nixpkgs-jlink in flake.nix),
#      pinned to one revision. To upgrade J-Link, change that revision.
#
#   2. nixpkgs' fetchurl always passes --continue-at to curl, and curl >= 8.23
#      refuses that together with --data ("HTTP upload cannot be resumed"),
#      see https://github.com/NixOS/nixpkgs/issues/580434.
#      Fix: fetch with plain curl. Same file name and hash, so the result is
#      the same store path nixpkgs would have produced. Drop the override once
#      that issue is fixed in the pinned revision.
{ inputs, pkgs, lib, ... }:

let
  jlinkPkgs = import inputs.nixpkgs-jlink {
    inherit (pkgs.stdenv.hostPlatform) system;
    config = {
      allowUnfree = true;
      segger-jlink.acceptLicense = true;
      # The bundled Qt4 is flagged insecure; accept it for whatever version
      # the pinned revision ships, so this never needs a version bump.
      allowInsecurePredicate = pkg: lib.hasPrefix "segger-jlink-qt4" (lib.getName pkg);
    };
  };

  fetchWithLicensePost = { url, hash, ... }: jlinkPkgs.stdenvNoCC.mkDerivation {
    name = baseNameOf url;
    nativeBuildInputs = [ jlinkPkgs.curl ];
    SSL_CERT_FILE = "${jlinkPkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    impureEnvVars = lib.fetchers.proxyImpureEnvVars;
    outputHash = hash;
    outputHashMode = "flat";
    buildCommand = ''
      curl --fail --location --retry 3 \
        --data accept_license_agreement=accepted \
        --output "$out" "${url}"
    '';
  };
in
{
  nixpkgs.overlays = [
    (final: prev: {
      segger-jlink = jlinkPkgs.segger-jlink.override { fetchurl = fetchWithLicensePost; };
    })
  ];
}
