class HtmlUtils {
  static String stripHtml(String? html) {
    if (html == null || html.isEmpty) return "";

    // Remove HTML tags
    String result = html.replaceAll(RegExp(r'<[^>]*>'), '');

    // Replace common HTML entities
    final Map<String, String> entities = {
      '&nbsp;': ' ',
      '&amp;': '&',
      '&quot;': '"',
      '&#39;': "'",
      '&lt;': '<',
      '&gt;': '>',
      '&ndash;': '-',
      '&mdash;': '—',
    };

    entities.forEach((entity, replacement) {
      result = result.replaceAll(entity, replacement);
    });

    // Handle occurrences without semicolon or case variations if any
    result = result.replaceAll(RegExp(r'&nbsp;?', caseSensitive: false), ' ');

    return result.trim();
  }
}
