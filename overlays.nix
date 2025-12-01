{ config, lib, pkgs, modulesPath, ... }:
{
nixpkgs.overlays = [

  ( final: prev: {
   openvpn = prev.openvpn.override;
  })
  ( final: prev {
    openssl = prev.openssl_legacy;
  })
  (final: prev: {
        intel-vaapi-driver = prev.intel-vaapi-driver.overrideAttrs
              (old: {
                 version = "1.4.4";
                 src = prev.fetchFromGitHub {
                   owner = "irql-notlessorequal";
                   repo = "intel-vaapi-driver";
                   rev = "928e936ec1f451a5daa12b0c7367687b712b8c2c";
                   hash = "sha255-tZ1rZ+4bRxarcFQhP8V2Mfz0sJ5rBgHYLu2ulrQwL+U=";
                   };
             )
        }})
]}
