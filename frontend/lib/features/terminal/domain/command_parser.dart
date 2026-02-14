/// Result of parsing a raw input string.
class ParsedCommand {
  const ParsedCommand({
    required this.name,
    this.subcommand,
    this.positionalArgs = const [],
    this.flags = const {},
  });

  /// Primary command (e.g. `auth`, `find`, `help`).
  final String name;

  /// Optional subcommand (e.g. `login` in `auth login`).
  final String? subcommand;

  /// Positional arguments (e.g. `@username`).
  final List<String> positionalArgs;

  /// Named flags: `--key=value` or `--flag` (value = "true").
  final Map<String, String> flags;

  @override
  String toString() =>
      'ParsedCommand(name=$name, sub=$subcommand, args=$positionalArgs, flags=$flags)';
}

/// Tokenizes a raw terminal input string into a [ParsedCommand].
///
/// Examples:
///   `auth login --github`       → name=auth, sub=login, flags={github: true}
///   `find --near --tech=python` → name=find, flags={near: true, tech: python}
///   `collab request @bob --project=foo` → name=collab, sub=request, args=[@bob], flags={project: foo}
///   `whoami`                    → name=whoami
///   `clear`                     → name=clear
ParsedCommand parseCommand(String raw) {
  final input = raw.trim();
  if (input.isEmpty) {
    return const ParsedCommand(name: '');
  }

  final tokens = input.split(RegExp(r'\s+'));

  final name = tokens.first.toLowerCase();
  String? subcommand;
  final positionalArgs = <String>[];
  final flags = <String, String>{};

  var foundSubcommand = false;

  for (var i = 1; i < tokens.length; i++) {
    final token = tokens[i];

    if (token.startsWith('--')) {
      // Flag: --key=value or --flag
      final cleaned = token.substring(2);
      if (cleaned.contains('=')) {
        final parts = cleaned.split('=');
        flags[parts[0]] = parts.sublist(1).join('=');
      } else {
        flags[cleaned] = 'true';
      }
    } else if (!foundSubcommand && !token.startsWith('@') && !token.startsWith('-')) {
      // First non-flag token after the command name is the subcommand.
      subcommand = token.toLowerCase();
      foundSubcommand = true;
    } else {
      positionalArgs.add(token);
    }
  }

  return ParsedCommand(
    name: name,
    subcommand: subcommand,
    positionalArgs: positionalArgs,
    flags: flags,
  );
}
