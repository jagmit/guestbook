import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guestbook/entities/guestbook.dart';
import 'package:guestbook/services/firebase_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gästebuch',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
        snackBarTheme: Theme.of(context)
            .snackBarTheme
            .copyWith(behavior: SnackBarBehavior.floating),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _textEditingController = TextEditingController();

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Jagmit's Gästebuch"),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height:40),
            FutureBuilder(
              future: FirebaseService.fetchAllEntries(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  if (snapshot.hasError) {
                    return Text("Fehler");
                  } else {
                    List<GuestbookEntry> entries = snapshot.data;
                    return Column(
                      children: [
                        if (entries?.isEmpty ?? true) Text("Keine Einträge"),
                        for (GuestbookEntry entry in entries ?? [])
                          Text(
                            entry.message + " - " + entry.timestamp.toString(),
                          ),
                      ],
                    );
                  }
                }
              },
            ),
            SizedBox(height:40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _textEditingController,
                onSubmitted: (_) => _onSubmit(),
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _onSubmit,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print(await Firestore.instance
              .collection('guestbook')
              .document("w60sXYmQDSszQWIBIDvJ")
              .get()
              .then((doc) => doc.data));
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _onSubmit() async {
    return FirebaseService.createEntry(
      GuestbookEntry(message: _textEditingController.text),
    ).then((documentId) {
      _textEditingController.clear();
      return documentId;
    }).then(
      (documentId) {
        print(documentId);
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text("Eintrag erfolgeich erstellt!"),
          ),
        );
        setState(() {});
      },
    );
  }
}
