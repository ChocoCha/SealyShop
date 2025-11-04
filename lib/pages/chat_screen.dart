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
    // 💡 FIX: เริ่มดึง Stream ข้อความ
    chatMessagesStream = DatabaseMethod().getChatMessages(widget.chatRoomId);
    setState(() {});
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
        
        if (!snapshot.hasData) { // 💡 FIX: ใช้ !hasData เพื่อรวม Loading และ Empty State
          return const Center(child: CircularProgressIndicator());
        }
        
        // 💡 FIX: ใช้ snapshot.data!.docs.isEmpty เพื่อตรวจสอบว่ามีข้อความหรือไม่
        if (snapshot.data!.docs.isEmpty) {
             return const Center(child: Text("Start the conversation..."));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          reverse: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data!.docs[index];
            bool isMe = ds['senderId'] == myUid; 

            return Container(
              padding: const EdgeInsets.only(
                left: 20, 
                right: 20, 
                top: 8, 
                bottom: 8
              ),
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFF6F35A5) : Colors.grey.shade300,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(15),
                    topRight: const Radius.circular(15),
                    bottomLeft: isMe ? const Radius.circular(15) : const Radius.circular(0),
                    bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(15),
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Text(
                  ds["message"],
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 15.0,
                  ),
                ),
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