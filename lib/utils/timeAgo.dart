class TimeAgo {
  static String formatShort(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365)
      return "${(diff.inDays / 365).floor()}${(diff.inDays / 365).floor() == 1 ? "y" : "y"}";
//    if (diff.inDays > 30)
//      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "m" : "m"}";
    if (diff.inDays > 7)
      return "${(diff.inDays / 7).floor()}${(diff.inDays / 7).floor() == 1 ? "w" : "w"}";
    if (diff.inDays > 0) return "${diff.inDays}${diff.inDays == 1 ? "d" : "d"}";
    if (diff.inHours > 0)
      return "${diff.inHours}${diff.inHours == 1 ? "h" : "h"}";
    if (diff.inMinutes > 0)
      return "${diff.inMinutes}${diff.inMinutes == 1 ? "m" : "m"}";
    return "just now";
  }

  static String formatLong(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365)
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
    if (diff.inDays > 30)
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
    if (diff.inDays > 7)
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
    if (diff.inDays > 0)
      return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
    if (diff.inHours > 0)
      return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
    if (diff.inMinutes > 0)
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
    return "just now";
  }
}

//String timeAgo(DateTime d) {
//  Duration diff = DateTime.now().difference(d);
//  if (diff.inDays > 365)
//    return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
//  if (diff.inDays > 30)
//    return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
//  if (diff.inDays > 7)
//    return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
//  if (diff.inDays > 0)
//    return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
//  if (diff.inHours > 0)
//    return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
//  if (diff.inMinutes > 0)
//    return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
//  return "just now";
//}
