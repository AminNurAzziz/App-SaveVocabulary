import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocabulary App',
      theme: ThemeData(
        primarySwatch: MaterialColor(
          0xFF3BD8F7, // Use the RGB values as a hex value
          <int, Color>{
            50: Color(0xFFE0F8FE), // You can customize shades as needed
            100: Color(0xFFB3E9FD),
            200: Color(0xFF85DAFC),
            300: Color(0xFF57CAF9),
            400: Color(0xFF3BD8F7), // This is your custom color
            500: Color(0xFF00A5D8),
            600: Color(0xFF0097C4),
            700: Color(0xFF0082A9),
            800: Color(0xFF006E8F),
            900: Color(0xFF005C7A),
          },
        ),
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController vocabController = TextEditingController();
  TextEditingController meaningController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  List<VocabularyEntry> vocabularyList = [];
  List<VocabularyEntry> filteredVocabularyList = [];

  @override
  void initState() {
    super.initState();
    _loadVocabularyList();
  }

  void _loadVocabularyList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStrings = prefs.getStringList('vocabularyList') ?? [];
    setState(() {
      vocabularyList = jsonStrings
          .map((e) => VocabularyEntry.fromJson(json.decode(e)))
          .toList(); // Decode JSON strings
      filteredVocabularyList = List.from(vocabularyList);
    });
  }

  void _saveVocabularyList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = vocabularyList.map((e) => e.toJson()).toList();
    final jsonStrings =
        jsonData.map((e) => json.encode(e)).toList(); // Encode as JSON strings
    await prefs.setStringList('vocabularyList', jsonStrings);
  }

  void _addVocabularyEntry() {
    final vocab = vocabController.text;
    final meaning = meaningController.text;
    if (vocab.isNotEmpty && meaning.isNotEmpty) {
      setState(() {
        vocabularyList.insert(
            0,
            VocabularyEntry(
                vocab, meaning)); // menambah entri baru di awal list
        filteredVocabularyList.insert(
            0,
            VocabularyEntry(
                vocab, meaning)); // menambah entri baru di awal list
      });
      _saveVocabularyList();
      vocabController.clear();
      meaningController.clear();
    }
  }

  void _removeVocabularyEntry(int index) {
    setState(() {
      vocabularyList.removeAt(index);
      filteredVocabularyList.removeAt(index);
    });
    _saveVocabularyList();
  }

  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        // Jika query kosong, tampilkan semua vocabulary
        filteredVocabularyList = List.from(vocabularyList);
      } else {
        // Jika ada query, filter daftar vocabulary berdasarkan query
        filteredVocabularyList = vocabularyList.where((entry) {
          return entry.vocab.toLowerCase().contains(query.toLowerCase()) ||
              entry.meaning.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin?'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog konfirmasi
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.grey, // Atur warna latar belakang menjadi merah
              ),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                _removeVocabularyEntry(index); // Hapus entri jika dikonfirmasi
                Navigator.of(context).pop(); // Tutup dialog konfirmasi
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  AlertDialog _buildAddVocabularyDialog() {
    return AlertDialog(
      title: Text('Add Vocabulary'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: vocabController,
            decoration: InputDecoration(
              labelText: 'Vocabulary',
            ),
          ),
          SizedBox(height: 10.0), // Tambahkan jarak antara field (8 piksel
          TextField(
            controller: meaningController,
            decoration: InputDecoration(
              labelText: 'Meaning',
            ),
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Tutup dialog
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            _addVocabularyEntry(); // Tambahkan vocabulary
            Navigator.of(context).pop(); // Tutup dialog
          },
          child: Text('Add'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Vocabulary App (Azziz ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0, // Adjust the font size as needed
                  fontWeight: FontWeight.bold,
                ),
              ),
              WidgetSpan(
                child: Icon(
                  Icons.favorite,
                  color: Colors.white, // Change the color to white
                ),
              ),
              TextSpan(
                text: ' Fillah )',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0, // Adjust the font size as needed
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(top: 4, bottom: 50.0, left: 16.0, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search Vocabulary',
              ),
              onChanged: (query) {
                _performSearch(query);
              },
            ),
            const SizedBox(height: 8), // Tambahkan jarak sebelum tabel
// Replace the part of your code that renders the DataTable with this:
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('No.')), // Kolom untuk nomor
                    DataColumn(label: Text('Vocab')),
                    DataColumn(label: Text('Arti')),
                    DataColumn(label: Text('Action')),
                  ],
                  columnSpacing: 16.0, // Spasi antara kolom
                  headingRowColor: MaterialStateColor.resolveWith((states) =>
                      Color.fromARGB(
                          255, 59, 216, 247)), // Set header row color to grey
                  rows: filteredVocabularyList.asMap().entries.map((entry) {
                    final vocabEntry = entry.value;
                    final index = entry.key;
                    final color = index.isOdd ? Colors.white : Colors.grey[200];
                    return DataRow(
                      color: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                          return color;
                        },
                      ),
                      cells: [
                        DataCell(
                            Text((index + 1).toString())), // Menampilkan nomor
                        DataCell(Text(vocabEntry.vocab)),
                        DataCell(Text(vocabEntry.meaning)),
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _confirmDelete(
                                  index); // Memunculkan dialog konfirmasi sebelum menghapus
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return _buildAddVocabularyDialog();
            },
          );
        },
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // align the children to the center
          children: [
            Text(
              '${filteredVocabularyList.length}', // display the count
              style: TextStyle(fontSize: 17.5), // increase the font size to 18
            ),
          ],
        ),
      ),
    );
  }
}

class VocabularyEntry {
  final String vocab;
  final String meaning;

  VocabularyEntry(this.vocab, this.meaning);

  VocabularyEntry.fromJson(Map<String, dynamic> json)
      : vocab = json['vocab'],
        meaning = json['meaning'];

  Map<String, dynamic> toJson() => {
        'vocab': vocab,
        'meaning': meaning,
      };
}
