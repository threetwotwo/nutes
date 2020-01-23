import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nutes/ui/shared/styles.dart';

class SettingsButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Function onPressed;
  const SettingsButton({
    Key key,
    this.icon = Icons.settings,
    this.size = 30,
    this.color = Colors.white,
    this.onPressed,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: size,
      color: color,
    );
  }
}

class AddButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Function onPressed;
  const AddButton({
    Key key,
    this.icon = Icons.add,
    this.size = 30,
    this.color = Colors.white,
    this.onPressed,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: size,
      color: color,
    );
  }
}

class DeleteButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Function onPressed;
  const DeleteButton({
    Key key,
    this.icon = Icons.delete,
    this.size = 30,
    this.color = Colors.white,
    this.onPressed,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: size,
      color: color,
    );
  }
}

class CancelButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Function onPressed;
  const CancelButton({
    Key key,
    this.icon = Icons.close,
    this.size = 30,
    this.color = Colors.white,
    this.onPressed,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: size,
      color: color,
    );
  }
}

class RightBackButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Function onPressed;
  const RightBackButton({
    Key key,
    this.icon = Icons.arrow_forward,
    this.size = 30,
    this.color = Colors.white,
    this.onPressed,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: size,
      color: color,
    );
  }
}

///For use in editor screen
class SendToButton extends StatelessWidget {
  final Function onPressed;
  final bool isVisible;
  final bool isLoading;

  const SendToButton({
    Key key,
    @required this.onPressed,
    this.isVisible,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: FlatButton(
        padding: EdgeInsets.all(0),
        color: Colors.white.withOpacity(0.95),
        shape: StadiumBorder(side: BorderSide(color: Colors.black12)),
        onPressed: onPressed,
        child: isLoading
            ? SpinKitThreeBounce(
                color: Colors.grey[600],
                size: 24.0,
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    ' Send ',
                    style: TextStyles.defaultText,
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                  )
                ],
              ),
      ),
    );
  }
}

class FollowButtonExtended extends StatelessWidget {
  final bool isRequested;
  final bool isFollowing;

  final VoidCallback onFollow;
  final VoidCallback onRequest;

  const FollowButtonExtended(
      {Key key,
      this.isRequested,
      this.isFollowing,
      this.onFollow,
      this.onRequest})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return isRequested
        ? RequestedFollowButton(
            onPressed: onRequest,
          )
        : FollowButton(
            onFollowPressed: onFollow,
            isFollowing: isFollowing,
          );
  }
}

class RequestedFollowButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RequestedFollowButton({Key key, this.onPressed}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SoftBorderedButton(
      backgroundColor: Colors.white,
      borderColor: Colors.grey,
      onPressed: onPressed,
      child: Text(
        'Requested',
        style: TextStyles.defaultDisplay
            .copyWith(color: Colors.black, fontSize: 15),
      ),
    );
  }
}

class FollowButton extends StatelessWidget {
  final Function onFollowPressed;
  final bool isFollowing;

  const FollowButton({Key key, this.onFollowPressed, this.isFollowing = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SoftBorderedButton(
      backgroundColor: isFollowing ? Colors.white : Colors.blueAccent[400],
      borderColor: isFollowing ? Colors.grey : Colors.transparent,
      onPressed: onFollowPressed,
      child: Text(
        isFollowing ? 'Following' : 'Follow',
        style: TextStyles.defaultDisplay.copyWith(
            color: isFollowing ? Colors.black : Colors.white, fontSize: 15),
      ),
    );
  }
}

class SoftBorderedButton extends StatelessWidget {
  final Function onPressed;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final Widget child;
  final Color backgroundColor;
  const SoftBorderedButton({
    Key key,
    this.onPressed,
    this.borderColor = Colors.grey,
    this.borderWidth = 1.0,
    this.child,
    this.borderRadius = 8.0,
    this.backgroundColor = Colors.white,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 40,
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Center(child: child),
      ),
    );
  }
}
