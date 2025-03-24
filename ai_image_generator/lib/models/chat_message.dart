enum MessageType { user, system }

class ChatMessage {
  final MessageType type;
  final String content;
  final String? imageUrl;
  final String? imageId;
  final bool isLoading;

  ChatMessage({
    required this.type,
    required this.content,
    this.imageUrl,
    this.imageId,
    this.isLoading = false,
  });

  factory ChatMessage.user({
    required String content,
    String? imageUrl,
    String? imageId,
  }) {
    return ChatMessage(
      type: MessageType.user,
      content: content,
      imageUrl: imageUrl,
      imageId: imageId,
    );
  }

  factory ChatMessage.system({
    required String content,
    String? imageUrl,
    String? imageId,
    bool isLoading = false,
  }) {
    return ChatMessage(
      type: MessageType.system,
      content: content,
      imageUrl: imageUrl,
      imageId: imageId,
      isLoading: isLoading,
    );
  }
}
