import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/item.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Todo App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.black12,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = <item>[];

  HomePage() {
    // Adicionar valores iniciais à lista de items
    // items.add(item(title: "Item 1", done: true));
    // items.add(item(title: "Item 2", done: false));
    // items.add(item(title: "Item 3", done: true));
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var textEdt = TextEditingController();

  void add() {
    if (textEdt.text.isEmpty) return;
    setState(() {
      widget.items.add(item(title: textEdt.text, done: false));
      textEdt.text = "";
    });

    save();
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');
    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<item> result = decoded.map((e) => item.fromJson(e)).toList();

      setState(() {
        widget.items = result;
      });
    }
  }

  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  _HomePageState() {
    load();
  }
  void remove(index) {
    setState(() {
      widget.items.removeAt(index);
    });

    save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: textEdt,
          keyboardType: TextInputType.text,
          style: TextStyle(color: Colors.cyan, fontSize: 25),
          decoration: InputDecoration(
              labelText: "Teste", labelStyle: TextStyle(color: Colors.white)),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext ctxt, int index) {
          final title = widget.items[index].title ??
              ''; // Verificação de nulo e valor padrão vazio
          bool done = widget.items[index].done ??
              false; // Verificação de nulo e valor padrão false

          return Dismissible(
            key: Key(title),
            background: Container(
              color: Colors.red.withOpacity(0.2),
            ),
            onDismissed: (direction) {
              remove(index);
            },
            child: CheckboxListTile(
              title: Text(title),
              value: done,
              onChanged: (value) {
                setState(() {
                  print(value.toString() + " " + title + " " + done.toString());
                  if (value != null) {
                    widget.items[index].done = value;
                    save();
                  }
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          add();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}
