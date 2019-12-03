import 'package:flutter/material.dart';
import 'package:nutes/ui/shared/styles.dart';

import 'avatar_image.dart';

///Base row widget for showing avatar + username
///
///Can be customized to include subtitle or a trailing widget
class AvatarListItem extends StatelessWidget {
  final AvatarImage avatar;
  final String title;
  final TextSpan richTitle;
  final TextStyle style;
  final String subtitle;
  final Widget trailingWidget;
  final Function onTrailingWidgetPressed;
  final Function onAvatarTapped;
  final Function onBodyTapped;
  final int trailingFlexFactor;
  final Color color;

  const AvatarListItem({
    Key key,
    @required this.avatar,
    this.title,
    this.subtitle,
    this.trailingWidget,
    this.onTrailingWidgetPressed,
    this.onAvatarTapped,
    this.onBodyTapped,
    this.style,
    this.trailingFlexFactor = 3,
    this.richTitle,
    this.color,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Colors.white,
      height: 64,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            flex: 5,
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: onAvatarTapped,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 0, horizontal: 4.0),
                    child: avatar,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: onBodyTapped,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        (richTitle != null)
                            ? RichText(text: richTitle)
                            : Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: style ?? TextStyles.w600Text,
                                textAlign: TextAlign.left,
                              ),
                        if (subtitle != null && subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.defaultText
                                .copyWith(color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (trailingWidget != null)
            Flexible(
              flex: trailingFlexFactor,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: GestureDetector(
                    onTap: onTrailingWidgetPressed, child: trailingWidget),
              ),
            ),
        ],
      ),
    );
  }
}
