import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class MyImage extends Image {
  MyImage({required super.image});
  @override
  State<MyImage> createState() => _NewState();
}

class MyDropdown extends StatefulWidget {
  const MyDropdown({super.key});

  @override
  State<MyDropdown> createState() => _DropdownButtonExampleState();
}

class _DropdownButtonExampleState extends State<MyDropdown> {
  String dropdownValue = "RAW";

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      elevation: 16,
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
          _NewState.mode = value!;
        });
      },
      items: <DropdownMenuItem<String>>[
        DropdownMenuItem<String>(value: "RAW", child: Text("Raw image")),
        DropdownMenuItem<String>(value: "DLNK", child: Text("Plain text with link")),
        DropdownMenuItem<String>(value: "JSONPL", child: Text("JSON entry (plain k-v pairs)")),
        DropdownMenuItem<String>(value: "JSONPF", child: Text("JSON entry (array, path first)")),
        DropdownMenuItem<String>(value: "JSONPA", child: Text("JSON entry (array, path after)"))
      ],
    );
  }
}

class _NewState extends State<MyImage> {
  String lastLink = "";
  String apiLink = "https://cataas.com/cat";
  Image lastimg = Image.asset("assets/images/cheshir.png");
  static String mode = "RAW";
  String jsonPath = "";
  Random rnd = Random();
  TextEditingController editor = TextEditingController();
  TextEditingController editor2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
        textDirection: TextDirection.ltr,
        children: <Widget>[
          lastimg,
          Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(
                  width: 100.0,
                  height: 50.0,
                  child: ElevatedButton(
                    onPressed: _loadImage,
                    child: Text("Next"),
                  ),
                ),
                SizedBox(
                  width: 100.0,
                  height: 50.0,
                  child: ElevatedButton(
                    onPressed: _saveImage,
                    child: Text("Save"),
                  ),
                )
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text("Generated link"),
                TextFormField(controller: editor),
                Text("API link"),
                TextFormField(initialValue: apiLink, onFieldSubmitted: (String val)=>{apiLink = val}),
                MyDropdown(),
                Text("JSON path separated by semicolons"),
                TextFormField(controller: editor2, onFieldSubmitted: (String val)=>{jsonPath = val})
              ]
            ),
          )
        ]
    );
  }

  void _loadImage() async {
    print(mode);
    switch (mode) {
      case "RAW":
        lastLink = apiLink;
        break;
      case "DLNK":
        lastLink = (await http.get(Uri.parse(apiLink))).body;
        break;
      case "JSONPL":
      case "JSONPA":
      case "JSONPF":
        try {
          var json = jsonDecode((await http.get(Uri.parse(apiLink))).body);
          if (mode == "JSONPA") {
            json = json[rnd.nextInt(json.length)];
          }
          for (var x in jsonPath.split(";")) {
            if (json is String) {
              lastLink = json.toString();
              break;
            } else if (json is List && mode == "JSONPF") {
              lastLink = json[rnd.nextInt(json.length)];
              break;
            }
            json = json[x];
          }
        } catch (e) {

        }

    }
    setState((){
      print(lastLink);
      lastimg = Image.network(lastLink);
      print(lastimg.height);
      print(lastimg.width);
      // lastLink = "https://www.video2edit.com/assets/favicon/favicon-196x196.png";
      editor.text = lastLink;
    });
  }
  void _saveImage() async {
    if (await Permission.storage.request().isGranted) {
      // var f = File("/storage/emulated/0/Download/image.png", );
      var bytes = (await http.get(Uri.parse(lastLink))).bodyBytes;
      final params = SaveFileDialogParams(data: bytes, fileName: "untitled.png");
      final p = await FlutterFileDialog.saveFile(params: params);
    }
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    var myWid = MyImage(image:AssetImage("assets/images/cheshir.png"));
    var app = MaterialApp(home: Scaffold(
        appBar: AppBar(title: Text("Trapp")),
        body: SingleChildScrollView(
    child:
    Container(
            padding: EdgeInsets.all(20),
            child: myWid
        )
    )));
    return app;
  }
}

void main() {
  runApp(App());
}