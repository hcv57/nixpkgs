# We don't have a wrapper which can supply obs-studio plugins so you have to
# somewhat manually install this:

# nix-env -f . -iA obs-linuxbrowser
# mkdir -p ~/.config/obs-studio/plugins
# ln -s ~/.nix-profile/share/obs/obs-plugins/obs-linuxbrowser ~/.config/obs-studio/plugins/

{ stdenv, fetchFromGitHub, obs-studio, cmake, libcef
}:

stdenv.mkDerivation rec {
  name = "obs-linuxbrowser-${version}";
  version = "0.5.2";
  src = fetchFromGitHub {
    owner = "bazukas";
    repo = "obs-linuxbrowser";
    rev = version;
    sha256 = "1vwgdgcmab5442wh2rjww6lzij9g2c5ccnv79rs7vx3rdl8wqg4f";
  };
  nativeBuildInputs = [ cmake ];
  buildInputs = [ obs-studio ];
  postUnpack = ''
    mkdir -p cef/Release cef/Resources cef/libcef_dll_wrapper/
    for i in ${libcef}/share/cef/*; do
      ln -s $i cef/Release/
      ln -s $i cef/Resources/
    done
    ln -s ${libcef}/lib/libcef.so cef/Release/
    ln -s ${libcef}/lib/libcef_dll_wrapper.a cef/libcef_dll_wrapper/
    ln -s ${libcef}/include cef/
  '';
  cmakeFlags = [
    "-DCEF_ROOT_DIR=../../cef"
    "-DOBS_INCLUDE_SEARCH_DIR=${obs-studio}/include/obs"
  ];
  installPhase = ''
    mkdir -p $out/share/obs/obs-plugins
    cp -r build/obs-linuxbrowser $out/share/obs/obs-plugins/
  '';

  meta = with stdenv.lib; {
    description = "Browser source plugin for obs-studio based on Chromium Embedded Framework";
    homepage = https://github.com/bazukas/obs-linuxbrowser;
    maintainers = with maintainers; [ puffnfresh ];
    license = licenses.gpl2;
    platforms = with platforms; linux;
  };
}
