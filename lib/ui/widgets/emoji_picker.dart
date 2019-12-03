import 'package:flutter/material.dart';

const emojis = [
  '❤',
  '😂',
  '😍',
  '👌',
  '👍',
  '🔥',
  '🙏',
  '🙌',
  '👏',
  '💪',
  '😢',
  '🙄',
  '😎',
  '😮',
  '😅',
  '👀',
];

class EmojiPicker extends StatelessWidget {
  final Function(String) onEmoji;

  const EmojiPicker({Key key, this.onEmoji}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[100]))),
      height: 50,
      alignment: Alignment.center,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: emojis.length,
          itemBuilder: (context, index) => Material(
                color: Colors.white,
                child: InkWell(
                  onTap: () => onEmoji(emojis[index]),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      emojis[index],
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              )),
    );
  }
}
