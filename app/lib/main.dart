import 'package:app/liquid.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _darkTheme = true;

  void _brightnessCallback() {
    setState(() {
      _darkTheme = !_darkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
          brightness: _darkTheme ? Brightness.dark : Brightness.light,
        ),
        home: Home(_brightnessCallback));
  }
}

class Home extends StatelessWidget {
  final VoidCallback callback;
  const Home(this.callback, {Key? key}) : super(key: key);

  Future<void> _showDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Look, a dialog!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text(
                    'Some text here. Don\'t mind the progress indicator.'),
                Container(
                  height: 32,
                ),
                const Center(
                  child: CircularProgressIndicator(),
                ),
                Container(
                  height: 32,
                ),
                Center(
                    child: ElevatedButton(
                        onPressed: callback,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Toggle theme'),
                        ))),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter demo'),
      ),
      body: const Liquid(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(context),
        child: const Icon(Icons.aspect_ratio),
      ),
    );
  }
}
