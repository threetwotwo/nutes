import 'package:flutter/material.dart';

class ColorAvatars extends StatelessWidget {
  final Function(Color) onColor;

  const ColorAvatars({Key key, this.onColor}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ColorAvatar(
            color: Colors.white,
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.black,
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.grey[800],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.grey[700],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.grey[600],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.grey[300],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.grey[100],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.blue[900],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.blueAccent[700],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.blueAccent[400],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.blueAccent,
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.green[900],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.green[800],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.green[700],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.green[500],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.deepOrangeAccent[700],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.orange[900],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.orangeAccent[700],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.orangeAccent[400],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.amber,
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.amber[200],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.pink[900],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.red[900],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.pinkAccent[700],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.redAccent[700],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.redAccent[400],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.pink[400],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.pink[300],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.purple[900],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.deepPurple[700],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.deepPurple,
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.deepPurpleAccent[700],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.deepPurpleAccent[400],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.purpleAccent[700],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.purpleAccent[400],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.purpleAccent[100],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.purple[300],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.brown[900],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.brown[700],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.brown[500],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.brown[400],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.brown[200],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.blueGrey[800],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.blueGrey[500],
            onColor: (val) => onColor(val),
          ),
          ColorAvatar(
            color: Colors.blueGrey[100],
            onColor: (val) => onColor(val),
          ),
        ],
      ),
    );
  }
}

class ColorAvatar extends StatelessWidget {
  final Color color;
  final Function(Color) onColor;

  const ColorAvatar({Key key, this.color, this.onColor}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onColor(color),
      child: Container(
        height: 25,
        width: 25,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.grey, width: 0.5),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.grey, width: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
