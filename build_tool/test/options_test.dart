import 'package:build_tool/src/builder.dart';
import 'package:build_tool/src/options.dart';
import 'package:hex/hex.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('parseCargoBuildOptions', () {
    final yaml = """
toolchain: nightly
extra_flags:
  - -Z
  # Comment here
  - build-std=panic_abort,std
""";
    final node = loadYamlNode(yaml);
    final options = CargoBuildOptions.parse(node);
    expect(options.toolchain, Toolchain.nightly);
    expect(options.flags, ['-Z', 'build-std=panic_abort,std']);
  });

  test('parsePrecompiledBinaries', () {
    final yaml = """
url_prefix: https://url-prefix
public_key: a4c3433798eb2c36edf2b94dbb4dd899d57496ca373a8982d8a792410b7f6445
""";
    final precompiledBinaries = PrecompiledBinaries.parse(loadYamlNode(yaml));
    final key = HEX.decode(
        'a4c3433798eb2c36edf2b94dbb4dd899d57496ca373a8982d8a792410b7f6445');
    expect(precompiledBinaries.uriPrefix, 'https://url-prefix');
    expect(precompiledBinaries.publicKey.bytes, key);
  });

  test('parseLocalPrecompiledBinaries', () {
    final yaml = """
path: /path/to/dir
""";
    final localPrecompiledBinaries =
        LocalPrecompiledBinaries.parse(loadYamlNode(yaml));
    expect(localPrecompiledBinaries.path, '/path/to/dir');
  });

  test('parseCargokitOptions', () {
    const yaml = '''
cargo:
  # For smalles binaries rebuilt the standard library with panic=abort
  debug:
    toolchain: nightly
    extra_flags:
      - -Z
      # Comment here
      - build-std=panic_abort,std
  release:
    toolchain: beta

precompiled_binaries:
  url_prefix: https://url-prefix
  public_key: a4c3433798eb2c36edf2b94dbb4dd899d57496ca373a8982d8a792410b7f6445

local_precompiled_binaries:
  path: /path/to/dir
''';
    final options = CargokitCrateOptions.parse(loadYamlNode(yaml));
    expect(options.precompiledBinaries?.uriPrefix, 'https://url-prefix');
    final key = HEX.decode(
        'a4c3433798eb2c36edf2b94dbb4dd899d57496ca373a8982d8a792410b7f6445');
    expect(options.precompiledBinaries?.publicKey.bytes, key);
    expect(options.localPrecompiledBinaries?.path, '/path/to/dir');

    final debugOptions = options.cargo[BuildConfiguration.debug]!;
    expect(debugOptions.toolchain, Toolchain.nightly);
    expect(debugOptions.flags, ['-Z', 'build-std=panic_abort,std']);

    final releaseOptions = options.cargo[BuildConfiguration.release]!;
    expect(releaseOptions.toolchain, Toolchain.beta);
    expect(releaseOptions.flags, []);
  });

  test('parseCargokitUserOptions', () {
    const yaml = '''
use_precompiled_binaries: false
use_local_precompiled_binaries: true
verbose_logging: true
''';
    final options = CargokitUserOptions.parse(loadYamlNode(yaml));
    expect(options.usePrecompiledBinaries, false);
    expect(options.useLocalPrecompiledBinaries, true);
    expect(options.verboseLogging, true);
  });
}
