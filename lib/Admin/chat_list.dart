// ใน Admin/chat_list.dart 

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sealyshop/services/database.dart';
import 'package:sealyshop/pages/chat_screen.dart'; 

class AdminChatList extends StatefulWidget {
  const AdminChatList({super.key});

  @override
  State<AdminChatList> createState() => _AdminChatListState();
}

class _AdminChatListState extends State<AdminChatList> {
  Stream<QuerySnapshot>? chatRoomsStream;
  String? adminId;
  // 💡 NEW: Cache ชื่อลูกค้าเพื่อไม่ให้ต้องดึงซ้ำๆ
  final Map<String, String> _customerNameCache = {}; 
  final DatabaseMethod _dbMethod = DatabaseMethod();

  @override
  void initState() {
    super.initState();
    adminId = FirebaseAuth.instance.currentUser?.uid;
    if (adminId != null) {
      // 💡 ดึงเฉพาะห้องแชทที่ Admin เป็นผู้เข้าร่วม
      chatRoomsStream = _dbMethod.getAllChatRoomsForAdmin(adminId!);
      setState(() {});
    }
  }
  
  // 💡 ฟังก์ชันสำหรับดึงชื่อลูกค้าจาก UID (ใช้ FutureBuilder)
  Future<String> _getCustomerName(String userId) async {
    if (_customerNameCache.containsKey(userId)) {
      return _customerNameCache[userId]!;
    }
    
    try {
      DocumentSnapshot userDoc = await _dbMethod.getUserDetails(userId);
      String name = userDoc['Name'] ?? 'Unknown User';
      _customerNameCache[userId] = name; // Cache ผลลัพธ์
      return name;
    } catch (e) {
      return 'User ID: ${userId.substring(0, 8)}...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Chats"),
        backgroundColor: const Color(0xFF5B0F8A),
        foregroundColor: Colors.white,
      ),
      body: adminId == null 
          ? const Center(child: Text("Admin not logged in."))
          : StreamBuilder<QuerySnapshot>(
              stream: chatRoomsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No active chat rooms."));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot chatRoomDoc = snapshot.data!.docs[index];
                    String chatRoomId = chatRoomDoc.id;
                    
                    // 💡 ดึง ID ของลูกค้า (หา ID ที่ไม่ใช่ Admin)
                    List participants = chatRoomDoc['participants'] as List? ?? [];
                    String customerId = participants.firstWhere((id) => id != adminId, orElse: () => 'Unknown');
                    String lastMessage = chatRoomDoc['lastMessage'] ?? 'Start conversation';

                    return FutureBuilder<String>( // ⭐️ FutureBuilder เพื่อดึงชื่อลูกค้า
                      future: _getCustomerName(customerId),
                      builder: (context, nameSnapshot) {
                        String customerName = nameSnapshot.data ?? "Loading...";

                        return ListTile(
                          leading: const Icon(Icons.person_outline, color: Color(0xFF9458ED)),
                          title: Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // ➡️ เปิดหน้า Chat
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  chatRoomId: chatRoomId,
                                  otherUserName: customerName,
                                  otherUserId: customerId,
                                ),
                              ),
                            );
                          },
                        );
                      }
                    );
                  },
                );
              },
            ),
    );
  }
}