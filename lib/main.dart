import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guestbook/entities/guestbook.dart';
import 'package:guestbook/services/firebase_service.dart';
import 'package:intl/intl.dart';

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
        brightness: Brightness.light,
        textTheme: GoogleFonts.comicNeueTextTheme(),
        snackBarTheme: Theme.of(context)
            .snackBarTheme
            .copyWith(behavior: SnackBarBehavior.floating),
      ),
      home: GuestbookPage(),
    );
  }
}

class GuestbookPage extends StatefulWidget {
  GuestbookPage({Key key}) : super(key: key);

  @override
  _GuestbookPageState createState() => _GuestbookPageState();
}

class _GuestbookPageState extends State<GuestbookPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isMobile(context) => MediaQuery.of(context).size.width <= 576;

  Stream<List<GuestbookEntry>> _stream;

  @override
  void initState() {
    _stream = FirebaseService.listenToEntries();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFf7b2b7),
      body: SizedBox.expand(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            BackgroundPattern(),
            FractionallySizedBox(
              widthFactor: (_isMobile(context)) ? 0.8 : 0.6,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xff9aeaed),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.6),
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 40),
                      StreamBuilder(
                        stream: _stream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else {
                            if (snapshot.hasError) {
                              return Text("Fehler");
                            } else {
                              List<GuestbookEntry> entries = snapshot.data;
                              return Column(
                                children: [
                                  if (entries?.isEmpty ?? true)
                                    Text("Keine Einträge"),
                                  for (GuestbookEntry entry in entries ?? [])
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      child: GuestbookEntryItem(entry: entry),
                                    )
                                ],
                              );
                            }
                          }
                        },
                      ),
                      SizedBox(height: 40),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: EntryForm()),
                      SizedBox(height: 40),
                    ],
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
}

class EntryForm extends StatefulWidget {
  @override
  _EntryFormState createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  TextEditingController _textEditingController = TextEditingController();

  Future<void> _onSubmit() async {
    return FirebaseService.createEntry(
      GuestbookEntry(name: "Jagmit", message: _textEditingController.text),
    ).then((documentId) {
      _textEditingController.clear();
      return documentId;
    }).then(
      (documentId) {
        print(documentId);
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("Eintrag erfolgeich erstellt!"),
          ),
        );
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textEditingController,
      onSubmitted: (_) => _onSubmit(),
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: Icon(Icons.send),
          onPressed: _onSubmit,
        ),
      ),
    );
  }
}

class GuestbookEntryItem extends StatelessWidget {
  final GuestbookEntry entry;

  const GuestbookEntryItem({Key key, @required this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Transform.translate(
            offset: Offset(5, 5),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFFb8b3e9),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Colors.black.withOpacity(0.6),
              style: BorderStyle.solid,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${entry.name} schrieb:",
                    style: Theme.of(context).textTheme.overline,
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(entry.timestamp),
                    style: Theme.of(context).textTheme.overline,
                  )
                ],
              ),
              SizedBox(height: 10),
              Text("„${entry.message}“"),
              SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}

class BackgroundPattern extends StatefulWidget {
  const BackgroundPattern({
    Key key,
  }) : super(key: key);

  @override
  _BackgroundPatternState createState() => _BackgroundPatternState();
}

class _BackgroundPatternState extends State<BackgroundPattern> {
  final CustomPainter painter = BackgroundPainter();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: painter,
        ),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    int stepSize = 20;
    double boxSize = 4.0;
    int horizontalCount = size.width ~/ stepSize;
    int horizontalRemainder = (size.width % stepSize).floor();
    int verticalCount = size.height ~/ stepSize;
    int verticalRemainder = (size.height % stepSize).floor();

    int pointerX = horizontalRemainder ~/ 2;
    int pointerY = verticalRemainder ~/ 2;

    for (int i = 0; i < horizontalCount + 1; i++) {
      for (int j = 0; j < verticalCount + 1; j++) {
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset((pointerX + i * stepSize).toDouble(),
                  (pointerY + j * stepSize).toDouble()),
              width: boxSize,
              height: boxSize),
          Paint()
            ..color = Color.lerp(Color(0xFF333399), Color(0xFFff00CC),
                ((i / horizontalCount) + (j / verticalCount)) / 2),
        );
      }
    }
    print("painted background");
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
