import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;

class AddPage extends StatefulWidget {
  final Map? todo;
  const AddPage({Key? key,this.todo}) : super(key: key);
  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TextEditingController titleController =  TextEditingController();
  TextEditingController descriptionController =  TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if(todo != null){
      isEdit = true;
      final title = todo["title"];
      final description = todo["description"];
      titleController.text = title;
      descriptionController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: isEdit? Text("Modifier"):Text("Ajouter"),
        elevation: 0,
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: EdgeInsets.all(20.0),
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: 'Titre',
            ),
          ),
          SizedBox(height: 20.0,),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              hintText: 'Description',
            ),
            minLines: 5,
            maxLines: 8,
          ),
          SizedBox(height: 20.0,),
          ElevatedButton(
            onPressed:isEdit?updateData:submitData,
            style:ElevatedButton.styleFrom(
              backgroundColor: Colors.green
            ),
            child:Padding(
                padding: EdgeInsets.all(18.0),
                child:isEdit?Text("Modifier"):Text("Envoyer")),
          )
        ],
      ),
    );
  }

  Future <void> updateData() async {
    final todo = widget.todo;
    if(todo == null)
    {
      //print('Impossible de modifier une liste vide');
      return;
    }
    final id = todo["id"];
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title":title,
      "description":description,
    };

    final url = "http://localhost:3000/todo-list/$id";
    final uri = Uri.parse(url);
    final res = await http.put(
        uri,
        body:jsonEncode(body),
        headers: {
          "Content-Type":"application/json"
        }
    );

    if(res.statusCode == 200)
    {
      titleController.text = "";
      descriptionController.text = "";
      showSuccessMessage("Modifié avec Succès !!");
    }else
    {
      showErrorMessage("Echec de la modification !!");
    }
  }

  Future <void> submitData() async {
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title":title,
      "description":description,
      "is_completed":false
    };

    final url = "http://localhost:3000/todo-list";
    final uri = Uri.parse(url);
    final res = await http.post(
        uri,
        body:jsonEncode(body),
        headers: {
          "Content-Type":"application/json"
        }
    );

    if(res.statusCode == 201)
    {
      titleController.text = "";
      descriptionController.text = "";
      showSuccessMessage("Ajouté avec Succès !!");
    }else
    {
      showErrorMessage("Echec");
    }
  }

  void showSuccessMessage(String message){
    final snackBar = SnackBar(
        content: Text(message,style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message){
    final snackBar = SnackBar(
      content: Text(message,style: TextStyle(color: Colors.white),),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


}
