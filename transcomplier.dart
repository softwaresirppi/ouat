import 'dart:convert';
import 'dart:io';

// TODO
// Friendly operator aliases
//   turns into, as long as,
//   Tenses: [Will be] for is
// turns into =
// not versions of operators

// OOP
// Object property

// Better errors

// Functions
// IO operators
// Verb karma computation

// DONE
//  + with - without += is with -= is without < worse than > better than = is == same as && and || or ! not ; .
// Value resolver
//   Numbers: big bad brother
//   Bool good, bad
//   Strings: "wtf"
//   null; nothing

// Comment resolver

// Pronoun resolver
// it him herherself himself itself

// Structure resolver
// unless resolver
// when resolver
// while resolver

// keyword exceptions which are like values in talelang
List<String> keywords = [
  'true',
  'false',
  'null',
  'if',
  'while',
];

class Resolver {
  late String Function(String) resolve;
  Resolver(this.resolve);
  Resolver.replace(String from, String to, {bool isCaseSensitive = false}) {
    resolve = (String source) {
      return source.replaceAll(
          RegExp(from, caseSensitive: isCaseSensitive), to);
    };
  }
  Resolver.handle(String pattern, String Function(Match) handler,
      {bool isCaseSensitive = false}) {
    resolve = (String source) {
      return source.replaceAllMapped(
          RegExp(pattern, caseSensitive: isCaseSensitive), handler);
    };
  }
}

int stringCount = 0;
String? prevCharacter;
List<Resolver> resolvers = [
  Resolver.replace(r'\([^()]*\)', ''),
  Resolver.handle(r'"[\w\s]+"', (Match match) {
    String stringName = "__String${stringCount}";
    stringCount++;
    print("$stringName = ${match.group(0)};");
    return stringName;
  }),
  Resolver.handle(r'when\s*([^,]+),(.+)\.', (match) {
    return ('if(' + match.group(1)! + ') { ' + match.group(2)! + ' }');
  }),
  Resolver.handle(r'unless\s*([^,]+),(.+)\.', (match) {
    return ('if(!(' + match.group(1)! + ')) { ' + match.group(2)! + ' }');
  }),
  Resolver.handle(r'while\s*([^,]+),(.+)\.', (match) {
    return ('while(' + match.group(1)! + ') { ' + match.group(2)! + ' }');
  }),
  Resolver.handle(r'until\s*([^,]+),(.+)\.', (match) {
    return ('while(!(' + match.group(1)! + ')) { ' + match.group(2)! + ' }');
  }),
  Resolver.replace(r'(was|were|am|are)', 'is'),
  Resolver.replace(r'(\s+is)?\s+same\s+as\s+', ' == '),
  Resolver.replace(r'\s+is\s+with\s*out\s+', ' -= '),
  Resolver.replace(r'\s+with\s*out\s+', ' - '),
  Resolver.replace(r'\s+is\s+with\s+', ' += '),
  Resolver.replace(r'\s+with\s+', ' + '),
  Resolver.replace(r'(\s+is)?\s+worse\s+than\s+', ' < '),
  Resolver.replace(r'(\s+is)?\s+better\s+than\s+', ' > '),
  Resolver.handle(
      r'(also|but|however|because|since|so|therefore|hence|yet|after|as|before|ever\s+since|once|whenever|as\s+soon\s+as|although|though|whereas|always|then|\.|,)',
      (Match match) => ';'),
  Resolver.replace(r'\s+is\s+', ' = '),
  Resolver.replace(r'\s+good', 'true'),
  Resolver.replace(r'\s+bad', 'false'),
  Resolver.replace(r'\s+nothing', '0'),
  Resolver.replace(r'\s+blank', 'null'),
  Resolver.replace(r'\s+and\s+', ' && '),
  Resolver.replace(r'\s+or\s+', ' || '),
  Resolver.replace(r'\s+not\s+', ' ! '),
  Resolver.handle(r'\s+([a-z][\w-]*)', (Match match) {
    if (keywords.contains(match.group(1)))
      return match.group(0)!;
    else
      return match.group(1)!.length.toString();
  }, isCaseSensitive: true),
  Resolver.handle(r'\s+(itself)|(himself)|(herself)|(it)|(him)|(her)', (match) {
    return match.input.substring(0, match.start).split(' ').lastWhere((word) =>
        word.isNotEmpty &&
        word.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
        word.codeUnitAt(0) <= 'Z'.codeUnitAt(0));
  }),
];
void main(List<String> args) async {
  File sourceFile = File(args[0]);
  var lines =
      sourceFile.openRead().transform(utf8.decoder).transform(LineSplitter());
  await for (String line in lines) {
    for (Resolver resolver in resolvers) line = resolver.resolve(line);
    print(line);
  }
}
