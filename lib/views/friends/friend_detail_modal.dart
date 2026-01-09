import 'package:flutter/material.dart';
import 'package:age_of_gold_mobile/models/friend.dart';
import 'package:age_of_gold_mobile/utils/auth_store.dart';
import 'package:age_of_gold_mobile/utils/utils.dart';

class FriendDetailModal extends StatefulWidget {
  final Friend friend;
  final Function() onClose;

  const FriendDetailModal({
    super.key,
    required this.friend,
    required this.onClose,
  });

  @override
  State<FriendDetailModal> createState() => _FriendDetailModalState();
}

class _FriendDetailModalState extends State<FriendDetailModal> {
  final AuthStore authStore = AuthStore();

  Future<void> _handleRemoveFriend() async {
    try {
      // TODO: Implement actual remove friend API call
      print('TODO: Implement remove friend for ${widget.friend.friendId}');

      // For now, just close the modal
      widget.onClose();
      showToastMessage('Friend removed (TODO: implement actual API call)');
    } catch (error) {
      showToastMessage('Failed to remove friend: ${error.toString()}');
    }
  }

  Future<void> _handleAcceptFriend() async {
    try {
      // TODO: Implement actual accept friend API call
      print('TODO: Implement accept friend for ${widget.friend.friendId}');

      widget.onClose();
      showToastMessage(
        'Friend request accepted (TODO: implement actual API call)',
      );
    } catch (error) {
      showToastMessage('Failed to accept friend: ${error.toString()}');
    }
  }

  Future<void> _handleRejectFriend() async {
    try {
      // TODO: Implement actual reject friend API call
      print('TODO: Implement reject friend for ${widget.friend.friendId}');

      widget.onClose();
      showToastMessage(
        'Friend request rejected (TODO: implement actual API call)',
      );
    } catch (error) {
      showToastMessage('Failed to reject friend: ${error.toString()}');
    }
  }

  Future<void> _handleCancelFriendRequest() async {
    try {
      // TODO: Implement actual cancel friend request API call
      print(
        'TODO: Implement cancel friend request for ${widget.friend.friendId}',
      );

      widget.onClose();
      showToastMessage(
        'Friend request cancelled (TODO: implement actual API call)',
      );
    } catch (error) {
      showToastMessage('Failed to cancel friend request: ${error.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = widget.friend.user?.username ?? 'Unknown User';
    final initial =
        username.isNotEmpty ? username.substring(0, 1).toUpperCase() : '?';
    final isIncoming = widget.friend.accepted == false;
    final isPending = widget.friend.accepted == null;
    final isAccepted = widget.friend.accepted == true;

    return Stack(
      children: [
        // Semi-transparent overlay
        GestureDetector(
          onTap: widget.onClose,
          child: Container(color: Colors.black.withOpacity(0.5)),
        ),
        // Modal content
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0b9476),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Friend Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: widget.onClose,
                      ),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: _getStatusColor(
                          isIncoming,
                          isPending,
                          isAccepted,
                        ).withOpacity(0.2),
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Username
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Status
                      Text(
                        _getStatusText(isIncoming, isPending, isAccepted),
                        style: TextStyle(
                          fontSize: 16,
                          color: _getStatusColor(
                            isIncoming,
                            isPending,
                            isAccepted,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Actions based on status
                      if (isIncoming) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Accept'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _handleAcceptFriend,
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('Reject'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _handleRejectFriend,
                            ),
                          ],
                        ),
                      ] else if (isPending) ...[
                        ElevatedButton.icon(
                          icon: const Icon(Icons.cancel, size: 18),
                          label: const Text('Cancel Request'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _handleCancelFriendRequest,
                        ),
                      ] else if (isAccepted) ...[
                        ElevatedButton.icon(
                          icon: const Icon(Icons.person_remove, size: 18),
                          label: const Text('Remove Friend'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _handleRemoveFriend,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(bool isIncoming, bool isPending, bool isAccepted) {
    if (isIncoming) return const Color(0xFF27ae60); // Green
    if (isPending) return const Color(0xFFf39c12); // Orange
    return Colors.blue; // Blue for accepted friends
  }

  String _getStatusText(bool isIncoming, bool isPending, bool isAccepted) {
    if (isIncoming) return '⏳ Incoming Request';
    if (isPending) return '⏳ Request Sent';
    return '✓ Friends';
  }
}
