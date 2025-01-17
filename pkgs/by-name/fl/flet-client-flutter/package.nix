{ lib
, fetchFromGitHub
, pkg-config
, flutter324
, gst_all_1
, libunwind
, makeWrapper
, mimalloc
, orc
, yq
, runCommand
, gitUpdater
, mpv-unwrapped
, libplacebo
, _experimental-update-script-combinators
, flet-client-flutter
, fletTarget ? "linux"
}:

flutter324.buildFlutterApplication rec {
  pname = "flet-client-flutter";
  version = "0.25.2";

  src = fetchFromGitHub {
    owner = "flet-dev";
    repo = "flet";
    tag = "v${version}";
    hash = "sha256-bD44MCRZPXB/xuw2vBCzNbRNSVgdc4GyyWg3F2adxKk=";
  };

  sourceRoot = "${src.name}/client";

  cmakeFlags = [
    "-DMIMALLOC_LIB=${mimalloc}/lib/mimalloc.o"
  ];

  targetFlutterPlatform = fletTarget;

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  nativeBuildInputs = [
    makeWrapper
    mimalloc
    pkg-config
  ];

  buildInputs = [
    mpv-unwrapped
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-base
    gst_all_1.gst-vaapi
    gst_all_1.gstreamer
    libunwind
    orc
    mimalloc
  ]
    ++ mpv-unwrapped.buildInputs
    ++ libplacebo.buildInputs
  ;

  passthru = {
    pubspecSource = runCommand "pubspec.lock.json" {
        buildInputs = [ yq ];
        inherit (flet-client-flutter) src;
      } ''
      cat $src/client/pubspec.lock | yq > $out
    '';

    updateScript = _experimental-update-script-combinators.sequence [
      (gitUpdater { rev-prefix = "v"; })
      (_experimental-update-script-combinators.copyAttrOutputToFile "flet-client-flutter.pubspecSource" ./pubspec.lock.json)
    ];
  };

  meta = {
    description = "Framework that enables you to easily build realtime web, mobile, and desktop apps in Python. The frontend part";
    homepage = "https://flet.dev/";
    changelog = "https://github.com/flet-dev/flet/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ heyimnova lucasew ];
    mainProgram = "flet";
  };
}
