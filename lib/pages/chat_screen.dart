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
    // ดึง Stream ข้อความจาก Firestore โดยตรง
    chatMessagesStream = FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(widget.chatRoomId)
        .collection("Messages")
        .orderBy("time", descending: true)
        .snapshots();
    
    // Mark messages as read when opening chat
    _markAsRead();
    setState(() {});
  }

  void _markAsRead() async {
    try {
      await DatabaseMethod().updateLastRead(widget.chatRoomId, myUid!);
    } catch (e) {
      print("Error marking messages as read: $e");
    }
  }

  // แสดงสถานะการพิมพ์
  void _showTypingIndicator(bool isTyping) async {
    if (myUid == null) return;
    
    try {
      await FirebaseFirestore.instance
          .collection("ChatRooms")
          .doc(widget.chatRoomId)
          .set({
        "isTyping_${myUid}": isTyping,
        "lastTypingTime": DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error updating typing status: $e");
    }
  }
  
  // เพิ่มฟังก์ชันสำหรับการตรวจสอบสถานะ error
  void _handleError(dynamic error) {
    print("Error in chat: $error");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${error.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> sendMessage() async {
    if (messageController.text.isEmpty || myUid == null) {
      return;
    }

    String messageText = messageController.text;
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    
    Map<String, dynamic> messageMap = {
      "message": messageText,
      "senderId": myUid,
      "time": timestamp,
      "senderName": widget.otherUserName, // เพิ่มชื่อผู้ส่ง
      "isAdmin": myUid == ChatScreen.adminId, // flag สำหรับข้อความของแอดมิน
    };

    try {
        // 1. เพิ่มข้อความในคอลเล็กชัน Messages
        await FirebaseFirestore.instance
            .collection("ChatRooms")
            .doc(widget.chatRoomId)
            .collection("Messages")
            .add(messageMap);
        
        // 2. อัปเดตข้อมูลห้องแชท
        await FirebaseFirestore.instance
            .collection("ChatRooms")
            .doc(widget.chatRoomId)
            .set({
              "lastMessage": messageText,
              "lastMessageTime": timestamp,
              "participants": [myUid, widget.otherUserId],
              "lastSenderId": myUid,
              "unreadCount": FieldValue.increment(1),
            }, 
            SetOptions(merge: true));

        // 3. เคลียร์ข้อความและสถานะการพิมพ์
        messageController.clear();
        _showTypingIndicator(false);
        
    } catch (e) {
        print("CHAT WRITE FAILED: $e");
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Failed to send message: ${e.toString()}"),
                backgroundColor: Colors.red,
              ),
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
    bool isAdmin = myUid == ChatScreen.adminId;
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              widget.otherUserName, 
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18
              )
            ),
            if (!isAdmin) Text(
              "Admin Support",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              // Show chat info or user details
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Chat Information"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("User: ${widget.otherUserName}"),
                      SizedBox(height: 8),
                      Text(isAdmin ? "Role: Admin" : "Role: Customer"),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Close"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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
                    onChanged: (text) {
                      _showTypingIndicator(text.isNotEmpty);
                    },
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