import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

abstract class SmartTextElement {}

/// Represents an element containing a link
class LinkElement extends SmartTextElement {
  final String url;

  LinkElement(this.url);

  @override
  String toString() {
    return "LinkElement: $url";
  }
}

/// Represents an element containing a hastag
class HashTagElement extends SmartTextElement {
  final String tag;

  HashTagElement(this.tag);

  @override
  String toString() {
    return "HashTagElement: $tag";
  }
}

/// Represents an element containing a mention
class MentionElement extends SmartTextElement {
  final String mention;

  MentionElement(this.mention);

  @override
  String toString() {
    return "MentionElement: $mention";
  }
}

/// Represents an element containing text
class TextElement extends SmartTextElement {
  final String text;

  TextElement(this.text);

  @override
  String toString() {
    return "TextElement: $text";
  }
}

class LeadingElement extends SmartTextElement {
  final String text;

  LeadingElement(this.text);

  @override
  String toString() {
    return "TextElement: $text";
  }
}

final _linkRegex = RegExp(
    r"(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)",
    caseSensitive: false);
final _tagRegex = RegExp(r"\B#\w*[a-zA-Z]+\w*", caseSensitive: false);
final _mentionRegex = RegExp(r"\B@\w*[a-zA-Z._0-9]+\w*", caseSensitive: false);

/// Turns [text] into a list of [SmartTextElement]
List<SmartTextElement> _smartify(String text, {TextSpan leading}) {
  final sentences = text.split('\n');
  List<SmartTextElement> span = [];
  sentences.forEach((sentence) {
    final words = sentence.split(' ');
    words.forEach((word) {
      if (_linkRegex.hasMatch(word)) {
        span.add(LinkElement(word));
      } else if (_tagRegex.hasMatch(word)) {
        span.add(HashTagElement(word));
      } else if (_mentionRegex.hasMatch(word)) {
        span.add(MentionElement(word));
      } else {
        span.add(TextElement(word));
      }
      span.add(TextElement(' '));
    });
    if (words.isNotEmpty) {
      span.removeLast();
    }
    span.add(TextElement('\n'));
  });
  if (sentences.isNotEmpty) {
    span.removeLast();
  }
  if (leading != null) span.insert(0, LeadingElement(leading.text + ' '));
  return span;
}

/// Callback with URL to open
typedef StringCallback(String url);

/// Turns URLs into links
class CommentText extends StatelessWidget {
  /// Text to be linkified
  final String text;

  /// Style for non-link text
  final TextStyle style;

  /// Style of link text
  final TextStyle linkStyle;

  /// Style of HashTag text
  final TextStyle tagStyle;

  /// Callback for tapping a link
  final StringCallback onOpen;

  /// Callback for tapping a link
  final StringCallback onTagClick;

  final TextSpan leading;

  final String uid;

  final Function(String) onMention;

  const CommentText({
    Key key,
    this.text,
    this.style,
    this.linkStyle,
    this.tagStyle,
    this.onOpen,
    this.onTagClick,
    this.leading,
    this.onMention,
    @required this.uid,
  }) : super(key: key);

  /// Raw TextSpan builder for more control on the RichText
  TextSpan _buildTextSpan(
      {String text,
      TextStyle style,
      TextStyle linkStyle,
      TextStyle tagStyle,
      StringCallback onOpen,
      StringCallback onTagClick}) {
    void _onOpen(String url) {
      if (onOpen != null) {
        onOpen(url);
      }
    }

//    void _onMentionClick(String mention) {
//      if (onMention != null) {
//        onMention(mention);
//      }
//    }

    void _onTagClick(String url) {
      if (onTagClick != null) {
        onTagClick(url);
      }
    }

    final elements = _smartify(text, leading: leading);

    return TextSpan(
        children: elements.map<TextSpan>((element) {
      if (element is TextElement) {
        return TextSpan(
          text: element.text,
          style: style,
        );
      } else if (element is LinkElement) {
        return LinkTextSpan(
          text: element.url,
          style: linkStyle,
          onPressed: () => _onOpen(element.url),
        );
      } else if (element is LeadingElement) {
        return LinkTextSpan(
          text: element.text,
          style: style.copyWith(fontWeight: FontWeight.w600),
          onPressed: () => _onOpen(uid),
        );
      } else if (element is MentionElement) {
        return LinkTextSpan(
          text: element.mention,
          style: tagStyle,
          onPressed: () {
            print('mention click');
            return onMention(element.mention.substring(1));
          },
        );
      } else if (element is HashTagElement) {
        return LinkTextSpan(
          text: element.tag,
          style: tagStyle,
          onPressed: () => _onTagClick(element.tag),
        );
      }
    }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      softWrap: true,
      text: _buildTextSpan(
        text: text,
        style: Theme.of(context).textTheme.body1.merge(style),
        linkStyle: Theme.of(context)
            .textTheme
            .body1
            .merge(style)
            .copyWith(
              color: Colors.blue[800],
              decoration: TextDecoration.underline,
            )
            .merge(linkStyle),
        tagStyle: Theme.of(context)
            .textTheme
            .body1
            .merge(style)
            .copyWith(
              color: Colors.blue[900],
            )
            .merge(linkStyle),
        onOpen: onOpen,
        onTagClick: onTagClick,
      ),
    );
  }
}

class LinkTextSpan extends TextSpan {
  LinkTextSpan({TextStyle style, VoidCallback onPressed, String text})
      : super(
          style: style,
          text: text,
          recognizer: new TapGestureRecognizer()..onTap = onPressed,
        );
}
