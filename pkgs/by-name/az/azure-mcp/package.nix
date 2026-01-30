{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  azure-cli,
  makeWrapper,
}:

let
  version = "2.0.0-beta.14";
  srcs = {
    x86_64-linux = {
      url = "https://github.com/microsoft/mcp/releases/download/Azure.Mcp.Server-${version}/Azure.Mcp.Server-linux-x64-native.zip";
      hash = "sha256-sJPLk14fwZqUxvIKhHFQnBJB1KDCLXI+kXrYXdBLXGI=";
    };
    aarch64-linux = {
      url = "https://github.com/microsoft/mcp/releases/download/Azure.Mcp.Server-${version}/Azure.Mcp.Server-linux-arm64.zip";
      hash = "sha256-1RI0eyNI1UK8JZS562DUXQY0R8BsYlz/zyUP4TRG/KQ=";
    };
    x86_64-darwin = {
      url = "https://github.com/microsoft/mcp/releases/download/Azure.Mcp.Server-${version}/Azure.Mcp.Server-osx-x64.zip";
      hash = "sha256-jadoNqlQdNqkwnGP0HafrxP5G64cleWyM4ZM3QsLJA8=";
    };
    aarch64-darwin = {
      url = "https://github.com/microsoft/mcp/releases/download/Azure.Mcp.Server-${version}/Azure.Mcp.Server-osx-arm64.zip";
      hash = "sha256-h3f5iWrqOkc4VmxqFycVZsVV7bwkduWZYkLmacB3w+s=";
    };
  };
  src = fetchzip {
    inherit (srcs.${stdenv.hostPlatform.system}) url hash;
    stripRoot = false;
  };
in
stdenv.mkDerivation {
  pname = "azure-mcp";
  inherit version src;

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir --parents $out/bin $out/share/azure-mcp

    # Install the binary
    cp --recursive * $out/share/azure-mcp/

    # Create wrapper that adds azure-cli to PATH
    makeWrapper $out/share/azure-mcp/Azure.Mcp $out/bin/azure-mcp \
      --prefix PATH : ${lib.makeBinPath [ azure-cli ]}

    runHook postInstall
  '';

  meta = {
    description = "Model Context Protocol server for Azure services";
    longDescription = ''
      The Azure MCP Server implements the Model Context Protocol (MCP)
      specification to create a seamless connection between AI agents and
      Azure services. It provides 221+ tools for interacting with Azure
      resources including storage, compute, databases, and more.
    '';
    homepage = "https://github.com/microsoft/mcp";
    changelog = "https://github.com/microsoft/mcp/blob/main/servers/Azure.Mcp.Server/CHANGELOG.md";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "azure-mcp";
    maintainers = with lib.maintainers; [ sheeeng ];
  };
}
