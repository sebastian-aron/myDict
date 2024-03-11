import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(DictionaryApp());
}

class DictionaryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dictionary App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.search,
                  size: 37,
                  color: Color.fromARGB(255, 221, 175, 77)), // Add an icon
              SizedBox(width: 10), // Add some space
              Text(
                'MyDict!',
                style: TextStyle(
                  color: Color.fromARGB(255, 221, 175, 77),
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        body: DictionaryHomePage(),
      ),
    );
  }
}

class DictionaryHomePage extends StatefulWidget {
  @override
  _DictionaryHomePageState createState() => _DictionaryHomePageState();
}

class _DictionaryHomePageState extends State<DictionaryHomePage> {
  String _currentWord = '';
  String _definition = '';
  TextEditingController _controller = TextEditingController();

  Future<void> _searchWord(String word) async {
    final response = await http.get(
        Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        final String mainWord = data[0]['word'];
        final String phonetics =
            data[0]['phonetics'][0]['text'] ?? 'No phonetics available';
        final meanings = data[0]['meanings'];
        if (meanings.isNotEmpty) {
          final definitions = meanings[0]['definitions'];
          if (definitions.isNotEmpty) {
            final definition = definitions[0]['definition'];
            setState(() {
              _definition =
                  '$mainWord [$phonetics]:\n\n DEFINITION: \n $definition';
            });
            return;
          }
        }
      }
    } else {
      setState(() {
        _definition = 'Definition not found.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search a word'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Search',
                  labelStyle:
                      TextStyle(color: Color.fromARGB(255, 221, 175, 77)),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => _currentWord = value,
                style: TextStyle(
                    color: Colors.black), // Change text color to black
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _searchWord(_currentWord);
              },
              child: Text('Find Dict!!'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Color.fromARGB(255, 221, 175, 77), // background color
                foregroundColor: Colors.white, // text color
                padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: RichText(
                    textAlign: TextAlign.justify, // Align text to the right
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 18.0),
                      children: <TextSpan>[
                        TextSpan(
                          text: _currentWord,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                30.0, // Set bigger font size for the main word
                          ),
                        ),
                        TextSpan(
                          text: '\n\n$_definition',
                          style: TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
