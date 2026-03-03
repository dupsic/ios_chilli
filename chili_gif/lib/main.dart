import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());



class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    final TextEditingController searchController = TextEditingController();
    List<String> gifUrls = [];
    

    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.blueGrey),
      home: Scaffold(
        appBar: AppBar(
          title: Text("SuperChili App"),
          centerTitle: true,
          ),
        body: StatefulBuilder(
          builder: (BuildContext context, StateSetter setInternalState) {
            
            
            Future<void> searchGifs(String query) async {
              final String apiKey = 'odgNV68FOM3rCSdrkL80RAqYVTexRdkp';
              final url = Uri.parse(
                  'https://api.giphy.com/v1/gifs/search?api_key=$apiKey&q=$query&limit=20');
              final response = await http.get(url);

              if (response.statusCode == 200) {
                final data = jsonDecode(response.body);
                // updates UI
                // print(data);
                
                setInternalState(() {

                  String gifTitle = (data['data']['title']);
                  String gifUsername = (data['data']['username']);
                  print(gifUsername);
                  print(gifTitle);
                  gifUrls = (data['data'] as List)
                  
                      .map((gif) => gif['images']['fixed_height']['url'].toString())
                      .toList();
                });
              }
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search gif...",
                      suffixIcon: IconButton(
                        onPressed: () => searchGifs(searchController.text),
                        icon: const Icon(Icons.search),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => searchGifs(value),
                  ),
                ),
                // grid
                if (gifUrls.isEmpty)
                  const Center(child: Text("Search for some GIFs!"))
                else
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: gifUrls.length,
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (
                                context) => FullScreenGif(url: gifUrls[index]),));
                        },
                        child: Image.network(
                        gifUrls[index],
                        fit: BoxFit.cover,
                        )
                      ),
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

class FullScreenGif extends StatelessWidget {
  final String url;

  const FullScreenGif({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SuperChili App"),
        centerTitle: true,),
      // backgroundColor: Colors.black,
      body: Center(
        child: Image.network(
          url,
          fit: BoxFit.contain,
        ),
      ),
      Text()
    );
  }
}