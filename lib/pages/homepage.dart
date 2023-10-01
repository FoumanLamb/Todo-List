import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;

import 'adder.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isloading = true;
  List items = [];

  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo List"),
        elevation: 0,
        backgroundColor: Colors.green,
      ),
      body:Visibility(
        visible: isloading,
        child: Center(child:CircularProgressIndicator(),),
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement:Center(child:Text(
              "Liste vide",
              style: Theme.of(context).textTheme.headlineMedium,
            ),),
            child: ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemCount: items.length,
                itemBuilder: (context,index){
                  final item = items[index];
                  final id = item["id"] as String;
                  //print(id);
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text("${index+1}",style:TextStyle(color:Colors.white),),backgroundColor:Colors.green,),
                      title: Text(item['title']),
                      subtitle: Text(item['description']),
                      trailing: PopupMenuButton(
                        onSelected: (value){
                          if(value == "modifier"){
                            navigateToEditPage(item);
                          }else if(value == 'Supprimer')
                          {
                            deleteById(id);
                          }
                        },
                        itemBuilder: (context){
                          return [
                            PopupMenuItem(
                              child: Text("Modifier"),
                              value: "modifier",
                            ),
                            PopupMenuItem(
                              child: Text("Supprimer"),
                              value: "supprimer",
                            ),
                          ];
                        },
                      ),
                    ),
                  );
                }
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToAddPage,
          backgroundColor: Colors.green,
          label:Icon(Icons.add)),
    );
  }
  Future<void>navigateToAddPage() async{
    final route = MaterialPageRoute(builder: (context)=>AddPage());
    await Navigator.push(context, route);
    setState(() {
      isloading = true;
    });
    fetchTodo();
  }

  Future<void> navigateToEditPage(Map item) async{
    final route = MaterialPageRoute(builder: (context) => AddPage(todo:item));
    await Navigator.push(context, route);
    setState(() {
      isloading = true;
    });
    fetchTodo();
  }

  Future <void> deleteById(String id) async{
    final url = "http://localhost:3000/todo-list/$id";
    final uri = Uri.parse(url);
    final res = await http.delete(uri);
    if(res.statusCode == 200)
    {
      final filtered = items.where((element) => element["id"] != id).toList();
      setState(() {
        items = filtered;
      });
    }else{

      showErrorMessage("Echec de Suppression");
    }

  }


  void showErrorMessage(String message){
    final snackBar = SnackBar(
      content: Text(message,style: TextStyle(color: Colors.white),),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> fetchTodo() async{
    setState(() {
      isloading = false;
    });
    final url ="http://localhost:3000/todo-list";
    final uri = Uri.parse(url);
    final res = await http.get(uri);
    if(res.statusCode == 200){
      final json = jsonDecode(res.body) ;//as List;
      //final result = json["items"] as List;
      setState(() {
        items = json;
      });
    }
    setState(() {
      isloading = false;
    });

  }


}


