import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sealyshop/pages/chat_screen.dart';
import 'package:sealyshop/services/database.dart';

class AdminChatPage extends StatefulWidget {
  const AdminChatPage({super.key});

  @override
  State<AdminChatPage> createState() => _AdminChatPageState();
}

class _AdminChatPageState extends State<AdminChatPage> with SingleTickerProviderStateMixin {
  Stream<QuerySnapshot>? chatRoomsStream;
  final DatabaseMethod _dbMethod = DatabaseMethod();
  late TabController _tabController;
  final String adminId = ChatScreen.adminId; // ใช้ ID เดียวกับที่กำหนดใน ChatScreen
  final Map<String, String> _customerNameCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeChatStream();
  }

  void _initializeChatStream() {
    chatRoomsStream = _dbMethod.getAllChatRoomsForAdmin(adminId);
  }

  Future<String> _getCustomerName(String userId) async {
    if (_customerNameCache.containsKey(userId)) {
      return _customerNameCache[userId]!;
    }
    
    try {
      DocumentSnapshot userDoc = await _dbMethod.getUserDetails(userId);
      String name = userDoc['Name'] ?? 'Unknown User';
      _customerNameCache[userId] = name;
      return name;
    } catch (e) {
      return 'User ${userId.substring(0, 6)}...';
    }
  }

  Widget _buildChatRoomList(List<DocumentSnapshot> chatRooms, bool showActive) {
    return ListView.builder(
      itemCount: chatRooms.length,
      itemBuilder: (context, index) {
        DocumentSnapshot chatRoom = chatRooms[index];
        List participants = chatRoom['participants'] as List? ?? [];
        String customerId = participants.firstWhere(
          (id) => id != adminId,
          orElse: () => 'Unknown',
        );
        String lastMessage = chatRoom['lastMessage'] ?? 'No messages yet';
        int lastMessageTime = chatRoom['lastMessageTime'] ?? 0;
        DateTime messageDateTime = DateTime.fromMillisecondsSinceEpoch(lastMessageTime);
        bool isToday = messageDateTime.day == DateTime.now().day;
        String timeString = isToday
            ? "${messageDateTime.hour.toString().padLeft(2, '0')}:${messageDateTime.minute.toString().padLeft(2, '0')}"
            : "${messageDateTime.day}/${messageDateTime.month}/${messageDateTime.year}";

        return FutureBuilder<String>(
          future: _getCustomerName(customerId),
          builder: (context, snapshot) {
            String customerName = snapshot.data ?? "Loading...";

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: Color(0xFF9458ED).withOpacity(0.2),
                  child: Text(
                    customerName[0].toUpperCase(),
                    style: TextStyle(
                      color: Color(0xFF9458ED),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      timeString,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatRoomId: chatRoom.id,
                        otherUserName: customerName,
                        otherUserId: customerId,
                      ),
                    ),
                  ).then((_) {
                    // Refresh chat list when returning from chat screen
                    setState(() {});
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          "Customer Support",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF9458ED),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Recent Chats"),
            Tab(text: "All Chats"),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatRoomsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error loading chats"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9458ED)),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No active chats",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Messages from customers will appear here",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          List<DocumentSnapshot> allChats = snapshot.data!.docs;
          List<DocumentSnapshot> recentChats = allChats
              .where((chat) {
                int lastMessageTime = chat['lastMessageTime'] ?? 0;
                Duration difference = DateTime.now().difference(
                  DateTime.fromMillisecondsSinceEpoch(lastMessageTime),
                );
                return difference.inDays <= 7; // แสดงแชทในช่วง 7 วันล่าสุด
              })
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              // Recent Chats Tab
              recentChats.isEmpty
                  ? Center(
                      child: Text(
                        "No recent chats",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : _buildChatRoomList(recentChats, true),

              // All Chats Tab
              _buildChatRoomList(allChats, false),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
