import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:todo_app/screens/loading.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  var logger = Logger();

  addTaskToDatabase() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final FirebaseAuth auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      final uid = user!.uid;
      var time = DateTime.now();
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(uid)
          .collection('userTasks')
          .doc(time.toString())
          .set({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'time': time.toString()
      }).then((_) {
        Fluttertoast.showToast(msg: "Task Added Sucessfully");
        Navigator.pushReplacementNamed(context, '/home');
      }).catchError((error) {
        logger.e("Failed to add task to Firestore: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add task: $error")),
        );
      });
      ;
    } catch (e) {
      logger.d("Exception - $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Todo",
          style: TextStyle(color: Colors.white70),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 45.0,
                ),
                const Text(
                  "Add the task you want to do",
                  style: TextStyle(fontSize: 22.0),
                ),
                const SizedBox(
                  height: 50.0,
                ),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(color: Colors.grey.shade700),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.grey.shade700),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 35.0,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50.0,
                  child: ElevatedButton(
                    onPressed: () {
                      addTaskToDatabase();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        // Rounded corners
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text(
                      "Add Todo",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Positioned.fill(
              child: LoadingOverlay(),
            )
        ],
      ),
    );
  }
}
