import 'package:askaide/repo/model/misc.dart';

const groupMessageStatusWaiting = 0;
const groupMessageStatusSuccess = 1;
const groupMessageStatusFailed = 2;

class ChatGroup {
  final RoomInServer group;
  final List<GroupMember> members;

  ChatGroup({
    required this.group,
    required this.members,
  });

  factory ChatGroup.fromJson(Map<String, dynamic> json) {
    return ChatGroup(
      group: RoomInServer.fromJson(json['group']),
      members: (json['members'] as List)
          .map((member) => GroupMember.fromJson(member))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group': group.toJson(),
      'members': members.map((member) => member.toJson()).toList(),
    };
  }
}

class GroupMember {
  final int? id;
  final String modelId;
  final String modelName;
  final String? avatarUrl;

  GroupMember({
    this.id,
    required this.modelId,
    required this.modelName,
    this.avatarUrl,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'],
      modelId: json['model_id'],
      modelName: json['model_name'],
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'model_id': modelId,
      'model_name': modelName,
      'avatar_url': avatarUrl,
    };
  }
}

class GroupMessage {
  final int id;
  final String message;
  final String role;
  final int? tokenConsumed;
  final int? quotaConsumed;
  final int? pid;
  final int? memberId;
  final int? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  GroupMessage({
    required this.id,
    required this.message,
    required this.role,
    this.tokenConsumed,
    this.quotaConsumed,
    this.pid,
    this.memberId,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory GroupMessage.fromJson(Map<String, dynamic> json) {
    return GroupMessage(
      id: json['id'],
      message: json['message'] ?? '',
      role: json['role'] == 1 ? 'user' : 'assistant',
      tokenConsumed: json['token_consumed'],
      quotaConsumed: json['quota_consumed'],
      pid: json['pid'],
      memberId: json['member_id'],
      status: json['status'],
      createdAt: DateTime.tryParse(json['CreatedAt']),
      updatedAt: DateTime.tryParse(json['UpdatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'role': role,
      'token_consumed': tokenConsumed,
      'quota_consumed': quotaConsumed,
      'pid': pid,
      'member_id': memberId,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class GroupChatSendRequestMessage {
  final String role;
  final String content;
  final int? memberId;

  GroupChatSendRequestMessage({
    required this.role,
    required this.content,
    this.memberId,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      'member_id': memberId,
    };
  }

  factory GroupChatSendRequestMessage.fromJson(Map<String, dynamic> json) {
    return GroupChatSendRequestMessage(
      role: json['role'],
      content: json['content'],
      memberId: json['member_id'],
    );
  }
}

class GroupChatSendRequest {
  final List<GroupChatSendRequestMessage> messages;
  final List<int> memberIds;

  GroupChatSendRequest({
    required this.messages,
    required this.memberIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'messages': messages.map((message) => message.toJson()).toList(),
      'member_ids': memberIds,
    };
  }

  factory GroupChatSendRequest.fromJson(Map<String, dynamic> json) {
    return GroupChatSendRequest(
      messages: ((json['messages'] ?? []) as List)
          .map((message) => GroupChatSendRequestMessage.fromJson(message))
          .toList(),
      memberIds: (json['member_ids'] as List).map((e) => e as int).toList(),
    );
  }
}

class GroupChatSendResponseTask {
  final int memberId;
  final String taskId;
  final int answerId;

  GroupChatSendResponseTask({
    required this.memberId,
    required this.taskId,
    required this.answerId,
  });

  factory GroupChatSendResponseTask.fromJson(Map<String, dynamic> json) {
    return GroupChatSendResponseTask(
      memberId: json['member_id'],
      taskId: json['task_id'],
      answerId: json['answer_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'task_id': taskId,
      'answer_id': answerId,
    };
  }
}

class GroupChatSendResponse {
  final int questionId;
  final List<GroupChatSendResponseTask> tasks;

  GroupChatSendResponse({
    required this.questionId,
    required this.tasks,
  });

  factory GroupChatSendResponse.fromJson(Map<String, dynamic> json) {
    return GroupChatSendResponse(
      questionId: json['question_id'],
      tasks: (json['tasks'] as List)
          .map((task) => GroupChatSendResponseTask.fromJson(task))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }
}
