{ lib
, stdenv
, stdenvNoCC
, fetchurl
, makeWrapper
, jre_headless
, gnugrep
, coreutils
, autoPatchelfHook
, zlib
, nixosTests
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "opensearch";
  version = "2.9.0";

  src = fetchurl {
    url = "https://artifacts.opensearch.org/releases/bundle/opensearch/${finalAttrs.version}/opensearch-${finalAttrs.version}-linux-x64.tar.gz";
    hash = "sha256-A9YjwtmacQDC8PrdyP/ai6J+roqmP/bz99rSM3votow=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ jre_headless ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -R bin config lib modules plugins $out

    substituteInPlace $out/bin/opensearch \
      --replace 'bin/opensearch-keystore' "$out/bin/opensearch-keystore"

    wrapProgram $out/bin/opensearch \
      --prefix PATH : "${lib.makeBinPath [ gnugrep coreutils ]}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ stdenv.cc.cc.lib ]}:$out/plugins/opensearch-knn/lib/" \
      --set JAVA_HOME "${jre_headless}"

    wrapProgram $out/bin/opensearch-plugin --set JAVA_HOME "${jre_headless}"
    wrapProgram $out/bin/opensearch-cli --set JAVA_HOME "${jre_headless}"

    runHook postInstall
  '';

  passthru.tests = nixosTests.opensearch;

  meta = {
    description = "Open Source, Distributed, RESTful Search Engine";
    homepage = "https://github.com/opensearch-project/OpenSearch";
    sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
      binaryNativeCode
    ];
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ shyim ];
  };
})
