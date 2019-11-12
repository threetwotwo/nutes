enum PostType { text, shout }

class PostHelper {
  static PostType postType(String val) {
    val = 'PostType.$val';
    return PostType.values
        .firstWhere((b) => b.toString() == val, orElse: () => null);
  }

  static String stringValue(PostType type) {
    return type.toString().split('.')[1];
  }
}
