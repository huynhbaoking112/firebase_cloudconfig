import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //firestore
  final FirestoreService firestoreService = FirestoreService();


  //text controller
  final TextEditingController textController = TextEditingController();

  void openNoteBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(

        //Text user input
        content: TextField(
          controller: textController,
        ),
        actions: [
          // button to save
          ElevatedButton(onPressed: ()  {
            print("king huynhf");
            //add a new note
            if(docID != null){
                 firestoreService.updateNote(docID,textController.text );
            }else{
               firestoreService.addNote(textController.text);
            }

            //clear text controller
            textController.clear();

            //close the box
            Navigator.pop(context);
          }, child: Text('Add'))
          ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {

          //if we have data, get all the docs
          if(snapshot.hasData){
            List notesList = snapshot.data!.docs;
            print(notesList);
            //display as a list
            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
              //get each individual doc
              DocumentSnapshot document = notesList[index];

              String docID = document.id;


              //get note from each doc
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              String note = data['note'];

              //display as a list tile  
                return ListTile(
                  title: Text(note) ,
                  leading: IconButton(onPressed: (){
                      firestoreService.deleteNote(docID);
                  },
                  icon: Icon(Icons.delete),
                  ),
                  trailing: IconButton(onPressed: (){
                      openNoteBox(docID: docID);
                  },
                  icon: Icon(Icons.settings),
                  ),
                );
            },);
          }else{
            return Text("Notes...");
          }

        },
      ),
    );
  }
}
