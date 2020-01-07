import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutes/core/models/chat_message.dart';
import 'package:nutes/core/models/user.dart';
import 'package:nutes/core/services/auth.dart';
import 'package:nutes/core/services/repository.dart';
import 'package:nutes/ui/screens/profile_screen.dart';
import 'package:nutes/ui/screens/shout_screen.dart';
import 'package:nutes/ui/shared/app_bars.dart';
import 'package:nutes/ui/shared/avatar_image.dart';
import 'package:nutes/ui/shared/avatar_list_item.dart';
import 'package:nutes/ui/shared/loading_indicator.dart';
import 'package:nutes/ui/widgets/chat_bubble.dart';
import 'package:nutes/ui/widgets/chat_screen_input.dart';
import 'package:nutes/ui/widgets/shout_text_field.dart';

class ChatScreen extends StatefulWidget {
  final User peer;
  final Timestamp lastSeenTimestamp;
  final Timestamp lastSeenTimestampPeer;
  final String peerId;

  const ChatScreen(
      {Key key,
      this.peer,
      this.lastSeenTimestamp,
      this.lastSeenTimestampPeer,
      this.peerId})
      : super(key: key);

  static Route route(User peer) => MaterialPageRoute(
      builder: (_) => ChatScreen(
            peer: peer,
          ));
  static Route FCMroute(String peerId) => MaterialPageRoute(
      builder: (_) => ChatScreen(
            peerId: peerId,
          ));

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final auth = Repo.auth;

  String uid = Auth.instance.profile.uid;

  User peer;

  String chatId;

  List<ChatItem> messages = [];

  final TextEditingController textController = TextEditingController();
  final TextEditingController shoutController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  Stream<QuerySnapshot> _messagesStream;
  Stream<QuerySnapshot> _isTypingStream;

  bool selfIsTyping = false;

  bool peerIsTyping = false;

  bool initialMessagedFinishedLoading = false;

  bool loadMoreIndicatorIsVisibible = false;

  bool peerHasSeenMyLastMessage = false;

  double bottomPadding = 64.0;

  ///For pagination
  Timestamp endAt;
  Timestamp startAt;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    print('dispose chat screen');
    Repo.isTyping(chatId, uid, false);
    super.dispose();
  }

  @override
  void initState() {
    final peerId = widget.peer.uid;

    chatId =
        (uid.hashCode <= peerId.hashCode) ? '$uid-$peerId' : '$peerId-$uid';

    getInitialMessages();

    initStream();

    listenToTypingEvent();

    _scrollController.addListener(_scrollListener);

    super.initState();
  }

  _loadMoreMessages() async {
    if (loadMoreIndicatorIsVisibible || endAt == null) return;

    final newMessages =
        await Repo.getMessages(chatId: chatId, endAt: endAt, startAt: startAt);

    if (newMessages.isEmpty) {
      print('no more earlier messages');
      _removeMessageOfType(Bubbles.loadMore);

      setState(() {
        loadMoreIndicatorIsVisibible = false;
      });
      return;
    }
    startAt = newMessages.last.timestamp;

    _removeMessageOfType(Bubbles.loadMore);

    setState(() {
      messages.addAll(newMessages);
      loadMoreIndicatorIsVisibible = false;
    });
  }

  _removeMessageOfType(Bubbles type, {String id}) {
    final message = id == null
        ? messages.firstWhere((m) => (m.type == type), orElse: () => null)
        : messages.firstWhere((m) => (m.id == id && m.type == type),
            orElse: () => null);

    if (message != null) {
      setState(() {
        messages.remove(message);
      });
    }
  }

  initStream() {
    _messagesStream = Repo.messagesStream(chatId);

    _messagesStream.listen((data) {
      ///only insert if initial messages have finished loading

      data.documentChanges.forEach((c) {
        if (initialMessagedFinishedLoading) {
          final message = ChatItem.fromDoc(c.document);

          setState(() {
            messages.insert(0, message);
          });

          _removeMessageOfType(Bubbles.text_temp, id: message.id);

          if (message.type == Bubbles.shout_complete)
            _removeMessageOfType(Bubbles.shout_challenge, id: message.id);

          if (mounted)
            _scrollController.animateTo(0,
                duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
        }
      });
    });

    _isTypingStream = Repo.isTypingStream(chatId);

    _isTypingStream.listen((data) {
      if (!mounted) return;

      final uids = data.documents.map((doc) => doc.documentID).toList();
      print(uids);

      if (uids.contains(widget.peer.uid)) {
        ///Ensure that only one typing indicator is visible

        if (!peerIsTyping) {
          peerIsTyping = true;
          setState(() {
            messages.insert(
              0,
              ChatItem(
                type: Bubbles.isTyping,
              ),
            );
          });
        }
      } else {
        print('should remove peer is typing');
        peerIsTyping = false;
        _removeMessageOfType(Bubbles.isTyping);
      }
    });
  }

  void _scrollListener() {
    final maxExtent = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
//    print('max extent: $maxExtent, offset: $offset');

    if (offset < 64) {
      setState(() {
        bottomPadding = 64.0 - offset;
      });
    }

    if (offset > maxExtent + 40) {
      if (!loadMoreIndicatorIsVisibible) {
        _loadMoreMessages();
        setState(() {
          loadMoreIndicatorIsVisibible = true;
          messages.add(ChatItem(
            type: Bubbles.loadMore,
          ));
        });
      }
    }

//    if (offset > 64) {
//      setState(() {
//        bottomPadding = 4.0;
//      });
//    }

    if (offset > 300) {
      FocusScope.of(context).requestFocus(new FocusNode());
    }
  }

  ///Listen to whether or not peer is typing
  listenToTypingEvent() {
    textController.addListener(() {
      if (textController.text.isNotEmpty) {
        if (!selfIsTyping) {
          print('is typing');
          Repo.isTyping(chatId, uid, true);
        }
        selfIsTyping = true;
      } else {
        selfIsTyping = false;
        print('not typing!');
        Repo.isTyping(chatId, uid, false);
      }
    });
  }

  Future getInitialMessages() async {
    final end = await Repo.chatEndAtForUser(widget.peer.uid);
    final initialMessages =
        await Repo.getInitialMessages(chatId: chatId, endAt: end);

    endAt = end;
    if (initialMessages.isNotEmpty) {
      startAt = initialMessages.last.timestamp;
    }

    setState(() {
      messages.addAll(initialMessages);
      initialMessagedFinishedLoading = true;
    });

    final myLastMessage = initialMessages
        .firstWhere((msg) => msg.senderId == auth.uid, orElse: () => null);
    final lastMessagePeer = initialMessages.firstWhere(
        (msg) => msg.senderId == widget.peer.uid,
        orElse: () => null);

    setState(() {
      peerHasSeenMyLastMessage =
          (widget.lastSeenTimestampPeer == null || myLastMessage == null)
              ? false
              : widget.lastSeenTimestampPeer.millisecondsSinceEpoch >=
                  myLastMessage.timestamp.millisecondsSinceEpoch;
    });

    if (lastMessagePeer != null)
      Repo.updateLastSeenPeerMessage(lastMessagePeer);

    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: BaseAppBar(
        onLeadingPressed: () => Navigator.pop(context),
        title: AvatarListItem(
          onAvatarTapped: () =>
              Navigator.push(context, ProfileScreen.route(widget.peer.uid)),
          onBodyTapped: () =>
              Navigator.push(context, ProfileScreen.route(widget.peer.uid)),
          avatar: AvatarImage(
            spacing: 2,
            url: widget.peer.urls.small,
          ),
          titleStyle: kPeerTextStyle,
          title: widget.peer.username,
//          subtitle: 'Following',
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Stack(
            children: <Widget>[
              Container(
                child: Center(
                  child: !initialMessagedFinishedLoading
                      ? LoadingIndicator()
                      : Padding(
                          padding: EdgeInsets.only(
                            left: 8.0,
                            right: 8.0,
                            top: 0.0,
                            bottom: bottomPadding,
                          ),
                          child: ListView.builder(
                            physics: AlwaysScrollableScrollPhysics(),
                            reverse: true,
                            controller: _scrollController,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];

                              final isPeer = message.senderId != auth.uid;

                              ///Remember: list view is reversed
                              final isLast = index < 1;
                              final lastMessageIsMine = isLast && !isPeer;

                              final nextBubbleIsMine = (!isLast &&
                                  messages[index - 1].senderId == auth.uid);

                              final showPeerAvatar = (isLast &&
                                      message.senderId == widget.peer.uid) ||
                                  nextBubbleIsMine;

                              ///Show message date if previous message is
                              ///sent more than an hour ago
                              final isFirst = index == messages.length - 1;
                              final currentMessage = messages[index];
                              final previousMessage =
                                  isFirst ? null : messages[index + 1];

                              bool showDate;

                              if (previousMessage == null) {
                                showDate = true;
                              } else if (currentMessage.timestamp == null ||
                                  previousMessage.timestamp == null) {
                                showDate = true;
                              } else {
                                showDate = previousMessage.timestamp.seconds <
                                    currentMessage.timestamp.seconds - 3600;
                              }

                              switch (message.type) {
                                case Bubbles.text:
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      ChatTextBubble(
                                        isPeer: isPeer,
                                        message: message,
                                        isLast: showPeerAvatar,
                                        peer: widget.peer,
                                        showDate: showDate,
                                      ),
                                      if (lastMessageIsMine &&
                                          peerHasSeenMyLastMessage)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Text(
                                            'Seen',
                                            style: kLabelTextStyle,
                                          ),
                                        ),
                                    ],
                                  );
                                case Bubbles.photo:
                                  return SizedBox();
                                case Bubbles.shout_challenge:
                                  return ChatShoutBubble(
                                    isPeer: isPeer,
                                    message: message,
                                    peer: isPeer ? widget.peer : auth.user,
                                    onTapped: isPeer
                                        ? () => Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ShoutScreen(
                                                      chatId: chatId,
                                                      messageId: message.id,
                                                      content: message.content,
                                                      peer: widget.peer,
                                                    )))
                                        : () {},
                                    isLast: showPeerAvatar,
                                  );
                                case Bubbles.shout_complete:
                                  return ChatShoutResponseBubble(
                                    isPeer: isPeer,
                                    response: message,
                                    message: message.metadata['responding_to'],
                                    peer: widget.peer,
                                    isLast: showPeerAvatar,
                                    onTapped: () {
                                      print('tapped shout response');
                                    },
                                  );

                                case Bubbles.post:
                                  return ChatPostBubble(
                                    isPeer: isPeer,
                                    isLast: isLast,
                                    peer: widget.peer,
                                    message: message,
//                                      showDate: showDate,
                                  );
                                case Bubbles.text_temp:
                                  return ChatPlaceholderBubble(message);
                                case Bubbles.photo_temp:
                                  return SizedBox();
                                case Bubbles.shout_challenge_temp:
                                  return SizedBox();
                                case Bubbles.shout_complete_temp:
                                  return SizedBox();
                                case Bubbles.isTyping:
                                  return TypingIndicator(
                                    user: widget.peer,
                                  );
                                case Bubbles.loadMore:
                                  return LoadingIndicator();

                                default:
                                  return SizedBox();
                              }
                            },
                          ),
                        ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ChatTextField(
                  controller: textController,
                  onImagePressed: () {},
                  onSendPressed: onSendPressed,
                  focusNode: focusNode,
                  showModalBottomSheet: () => _showBottomModalSheet(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  onSendPressed() {
    final text = textController.text.trim();

    if (text.isEmpty) return;

    final ref = Repo.createMessageRef(chatId);

    final placeholder = ChatItem(
        type: Bubbles.text_temp,
        id: ref.documentID,
        senderId: auth.uid,
        content: text,
        timestamp: Timestamp.now());

    print('new id: ${placeholder.id}');

    Repo.uploadMessage(
      ref: ref,
      type: Bubbles.text,
      content: text,
      peer: widget.peer,
    );

    setState(() {
      messages.insert(0, placeholder);
      peerHasSeenMyLastMessage = false;
    });

    _scrollController.animateTo(0,
        duration: Duration(milliseconds: 300), curve: Curves.easeInOut);

    textController.clear();
  }

  _showBottomModalSheet(BuildContext context) {
    return showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ShoutTextField(
                  onSendPressed: (val) {
                    if (shoutController.text.isEmpty) {
                      print('shout is empty');
                      return;
                    }

                    final text = shoutController.text;

                    final messageRef = Repo.createMessageRef(chatId);

                    ///upload a shout challenge
                    Repo.uploadMessage(
                      ref: messageRef,
                      type: Bubbles.shout_challenge,
                      content: text,
                      peer: widget.peer,
                    );

                    shoutController.clear();

                    Navigator.pop(context);
                  },
                  controller: shoutController,
                )),
          );
        });
  }
}
