{ lib
, async-timeout
, btsocket
, buildPythonPackage
, fetchFromGitHub
, poetry-core
, pyric
, pytestCheckHook
, pythonOlder
, usb-devices
}:

buildPythonPackage rec {
  pname = "bluetooth-auto-recovery";
  version = "1.0.0";
  format = "pyproject";

  disabled = pythonOlder "3.9";

  src = fetchFromGitHub {
    owner = "Bluetooth-Devices";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-TkTWF8Ljt2cLIuz2FnktrZFAlpvTVkFh6evE8TSzJhk=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    async-timeout
    btsocket
    pyric
    usb-devices
  ];

  checkInputs = [
    pytestCheckHook
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace " --cov=bluetooth_auto_recovery --cov-report=term-missing:skip-covered" ""
  '';

  pythonImportsCheck = [
    "bluetooth_auto_recovery"
  ];

  meta = with lib; {
    description = "Library for recovering Bluetooth adapters";
    homepage = "https://github.com/Bluetooth-Devices/bluetooth-auto-recovery";
    changelog = "https://github.com/Bluetooth-Devices/bluetooth-auto-recovery/blob/v${version}/CHANGELOG.md";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ fab ];
  };
}
