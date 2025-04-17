import 'package:flutter/material.dart';

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String text;
  final DateTime timestamp;
  final List<String> images;
  int likes;
  bool isLiked;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.text,
    required this.timestamp,
    this.images = const [],
    this.likes = 0,
    this.isLiked = false,
  });
}

// Dữ liệu giả lập bình luận
Map<String, List<Comment>> dummyComments = {
  'p1': [
    Comment(
      id: 'c1',
      userId: 'user1',
      userName: 'Sarah Johnson',
      userAvatar: 'https://placehold.co/50x50/png',
      text: 'I love this serum! My skin feels so hydrated after using it for just one week.',
      timestamp: DateTime.now().subtract(Duration(days: 2)),
      likes: 12,
    ),
    Comment(
      id: 'c2',
      userId: 'user2',
      userName: 'Michael Chen',
      userAvatar: 'https://placehold.co/50x50/png',
      text: 'Works great for my dry skin, especially during winter. Highly recommend!',
      timestamp: DateTime.now().subtract(Duration(hours: 5)),
      likes: 4,
    ),
  ],
  'p2': [
    Comment(
      id: 'c3',
      userId: 'user3',
      userName: 'Emma Wilson',
      userAvatar: 'https://placehold.co/50x50/png',
      text: 'Started seeing results after 2 weeks of consistent use. Fine lines around my eyes are less noticeable.',
      timestamp: DateTime.now().subtract(Duration(days: 7)),
      likes: 18,
      images: ['https://placehold.co/200x100/png'],
    ),
    Comment(
      id: 'c4',
      userId: 'user4',
      userName: 'David Kim',
      userAvatar: 'https://placehold.co/50x50/png',
      text: 'A bit pricey but worth every penny. My skin feels firmer and looks brighter.',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      likes: 7,
    ),
  ],
  'p3': [
    Comment(
      id: 'c5',
      userId: 'user5',
      userName: 'Jessica Miller',
      userAvatar: 'https://placehold.co/50x50/png',
      text: 'This serum is amazing! My skin feels so much brighter and smoother after just a week. Will definitely repurchase.',
      timestamp: DateTime.now().subtract(Duration(days: 2)),
      likes: 9,
    ),
  ],
}; 