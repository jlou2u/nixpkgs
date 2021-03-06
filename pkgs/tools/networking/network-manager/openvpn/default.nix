{ stdenv, fetchurl, substituteAll, openvpn, intltool, libxml2, pkgconfig, file, networkmanager, libsecret
, withGnome ? true, gnome3, kmod }:

let
  pname = "NetworkManager-openvpn";
  version = "1.8.6";
in stdenv.mkDerivation rec {
  name = "${pname}${if withGnome then "-gnome" else ""}-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "1ksij9438f2lrwkg287qjlfaxja6jgmqxqap96585r3nf5zj69ch";
  };

  patches = [
    (substituteAll {
      src = ./fix-paths.patch;
      inherit kmod openvpn;
    })
  ];

  buildInputs = [ openvpn networkmanager ]
    ++ stdenv.lib.optionals withGnome [ gnome3.gtk libsecret gnome3.networkmanagerapplet ];

  nativeBuildInputs = [ intltool pkgconfig file libxml2 ];

  configureFlags = [
    "--without-libnm-glib"
    "--with-gnome=${if withGnome then "yes" else "no"}"
    "--localstatedir=/" # needed for the management socket under /run/NetworkManager
    "--enable-absolute-paths"
  ];

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
      attrPath = "networkmanager-openvpn";
    };
  };

  meta = with stdenv.lib; {
    description = "NetworkManager's OpenVPN plugin";
    inherit (networkmanager.meta) maintainers platforms;
    license = licenses.gpl2Plus;
  };
}
