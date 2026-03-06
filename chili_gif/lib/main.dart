import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

Future<List<Map<String, dynamic>>> searchGifs(String query) async {
  const String apiKey = 'odgNV68FOM3rCSdrkL80RAqYVTexRdkp';
  try {
    final url = Uri.parse('https://api.giphy.com/v1/gifs/search?api_key=$apiKey&q=$query&limit=21');
    
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    }
    return [];
  }
  catch (e) {
    print("Connection error: $e");
    return [];
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> gifData = [];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("SuperChili App"),
          centerTitle: true,
        ),
        body: StatefulBuilder(
          builder: (BuildContext context, StateSetter setInternalState) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search gif...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        onPressed: () => searchController.clear(),
                        icon: const Icon(Icons.clear),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    
                onChanged: (value) async {
                      gifData = await searchGifs(value);
                      setInternalState(() {});
                    },
                  ),
                ),
                if (gifData.isEmpty)
                  const Expanded(child: Center(child: Text("Search for some GIFs!")))
                else
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(4),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: gifData.length,
                      itemBuilder: (context, index) {
                        final gif = gifData[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenGif(
                                  fullData: gif,
                                  query: searchController.text,
                                ),
                              ),
                            );
                          },
                          child: Image.network(
                            gif['images']['fixed_height']['url'],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  )
              ],
            );
          },
        ),
      ),
    );
  }
}

class FullScreenGif extends StatefulWidget {
  final Map<String, dynamic> fullData;
  final String query;

  const FullScreenGif({
    super.key,
    required this.fullData,
    required this.query,
  });

  @override
  State<FullScreenGif> createState() => _FullScreenGifState();
}

class _FullScreenGifState extends State<FullScreenGif> {
  List<Map<String, dynamic>> relatedGifs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRelatedGifs();
  }

  Future<void> loadRelatedGifs() async {
    relatedGifs = await searchGifs(widget.query);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.fullData['title'] ?? 'No Title';
    final String originalUrl = widget.fullData['images']['original']['url'];
    final String username = widget.fullData['username'] ?? 'Unknown User';
    final String date = widget.fullData['import_datetime'] ?? 'Unknown Date';

    return Scaffold(
      appBar: AppBar(title: const Text("GIF Details")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(10),
              children: [
                Text(title, 
                    textAlign: TextAlign.center, 
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text("By: @$username", textAlign: TextAlign.center),
                Text("Published: $date", textAlign: TextAlign.center),
                const Divider(),
                
                Center(
                  child: Image.network(
                    originalUrl,
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("More like this:", 
                      textAlign: TextAlign.center, 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: relatedGifs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemBuilder: (context, index) {
                    return Image.network(
                      relatedGifs[index]['images']['fixed_height']['url'],
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ],
            ),
    );
  }
}