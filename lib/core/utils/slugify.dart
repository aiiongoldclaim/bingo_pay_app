String slugify(String input) {
  final lowercased = input.toLowerCase().trim();
  final hyphenated = lowercased.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  final collapsed = hyphenated.replaceAll(RegExp(r'-+'), '-');
  return collapsed.replaceAll(RegExp(r'^-|-$'), '');
}
