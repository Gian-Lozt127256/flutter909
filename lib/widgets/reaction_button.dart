import 'package:flutter/material.dart';

class ReactionButton extends StatefulWidget {
  final IconData icon;
  final String reactionType;
  final VoidCallback onPressed;
  final bool isReacted;

  const ReactionButton({
    super.key,
    required this.icon,
    required this.reactionType,
    required this.onPressed,
    this.isReacted = false,
  });

  @override
  _ReactionButtonState createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<ReactionButton> {
  bool isReacted = false;

  @override
  void initState() {
    super.initState();
    isReacted = widget.isReacted;
  }

  void toggleReaction() {
    setState(() {
      isReacted = !isReacted;
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        widget.icon,
        color: isReacted ? Colors.blue : Colors.grey,
      ),
      onPressed: toggleReaction,
      tooltip: widget.reactionType,
    );
  }
}
