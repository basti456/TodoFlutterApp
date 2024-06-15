import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void _showSignOutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Do you really want to sign out?'),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () {
              // Dismiss the dialog when "No" is pressed
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () async {
              // Perform sign-out action and navigate to the auth screen
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context)
                  .pushReplacementNamed('/auth'); // Navigate to the auth screen
            },
          ),
        ],
      );
    },
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String uid = '';

  @override
  void initState() {
    super.initState();
    getUid();
  }

  getUid() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    setState(() {
      uid = user!.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(child: Container()),
            const Text("Todo"),
            const Text(
              "List",
              style: TextStyle(
                color: Colors.greenAccent,
              ),
            ),
            Expanded(child: Container()),
            GestureDetector(
              onTap: () {
                _showSignOutDialog(context);
              },
              child: Container(
                child: const Icon(Icons.exit_to_app),
              ),
            )
          ],
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('tasks')
              .doc(uid)
              .collection('userTasks')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(snapshot.data!.docs[index]['title']),
                      subtitle: Text(snapshot.data!.docs[index]['description']),
                      trailing: IconButton(
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('tasks')
                              .doc(uid)
                              .collection('userTasks')
                              .doc(snapshot.data!.docs[index].id)
                              .delete();
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addTodo');
        },
        backgroundColor: Colors.greenAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
