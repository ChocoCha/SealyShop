import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sealyshop/services/database.dart';
// import 'package:sealyshop/widget/support_widget.dart'; // สำหรับ AppWidget style

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String otherUserName;
  final String otherUserId;

  // 💡 FIX: ใช้ Admin ID ที่ถูกต้องและไม่มีช่องว่าง (จาก Firebase Auth UID)
  static const String adminId = "4gfJcstTIQlHRzewP0qp"; 
  
  const ChatScreen({
    super.key,
    required this.chatRoomId,
    required this.otherUserName,
    required this.otherUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController(); 
  Stream<QuerySnapshot>? chatMessagesStream; 
  String? myUid;

  @override
  void initState() {
    super.initState();
    myUid = FirebaseAuth.instance.currentUser?.uid;
    // 💡 FIX: เริ่มดึง Stream ข้อความ และ mark as read
    _initializeChat();
  }

  void _initializeChat() {
    chatMessagesStream = DatabaseMethod().getChatMessages(widget.chatRoomId);
    // Mark messages as read when opening chat
    _markAsRead();
    setState(() {});
  }

  void _markAsRead() async {
    try {
      await FirebaseFirestore.instance
          .collection("ChatRooms")
          .doc(widget.chatRoomId)
          .set({
        "unreadCount": 0,
        "lastRead": DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error marking messages as read: $e");
    }
  }

  Future<void> sendMessage() async {
    if (messageController.text.isEmpty || myUid == null) {
      // ไม่ต้องทำอะไรถ้าข้อความว่างเปล่าหรือผู้ใช้ไม่อยู่ในระบบ
      return; 
    }

    String messageText = messageController.text;
    
    Map<String, dynamic> messageMap = {
      "message": messageText,
      "senderId": myUid,
      "time": DateTime.now().millisecondsSinceEpoch,
    };

    try {
        // 1. บันทึกข้อความ (DatabaseMethod().addMessage ไม่มีการ return)
        await DatabaseMethod().addMessage(widget.chatRoomId, messageMap);
        
        // 2. อัปเดต ChatRooms Document เพื่อให้ Admin List เห็นข้อความล่าสุด
        await FirebaseFirestore.instance.collection("ChatRooms").doc(widget.chatRoomId).set({
          "lastMessage": messageText,
          "lastMessageTime": DateTime.now().millisecondsSinceEpoch,
          "participants": [myUid, widget.otherUserId],
        }, SetOptions(merge: true));

        messageController.clear();
    } catch (e) {
        print("CHAT WRITE FAILED: $e");
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to send message. Check Firebase Rules.")),
            );
        }
    }
  }

  Widget chatMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: chatMessagesStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6F35A5)),
                ),
                SizedBox(height: 16),
                Text(
                  "Loading messages...",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }
        
        if (snapshot.data!.docs.isEmpty) {
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
                  "No messages yet",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Start the conversation!",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          reverse: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data!.docs[index];
            bool isMe = ds['senderId'] == myUid;
            DateTime messageTime = DateTime.fromMillisecondsSinceEpoch(ds['time'] ?? 0);
            String timeString = "${messageTime.hour.toString().padLeft(2, '0')}:${messageTime.minute.toString().padLeft(2, '0')}";

            return Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 4,
                    bottom: 2,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF6F35A5) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomLeft: isMe ? Radius.circular(15) : Radius.circular(0),
                      bottomRight: isMe ? Radius.circular(0) : Radius.circular(15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    ds["message"],
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 15.0,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: isMe ? 0 : 24,
                    right: isMe ? 24 : 0,
                    bottom: 8,
                  ),
                  child: Text(
                    timeString,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Stack(
        children: [
          // 💡 ส่วนแสดงข้อความ
          chatMessageList(),

          // 💡 ส่วน Text Input ด้านล่าง
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: sendMessage,
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6F35A5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}