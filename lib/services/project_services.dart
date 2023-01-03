import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:travel_app/Data/models/project_model.dart';
import 'package:travel_app/Data/models/project_model.dart';
import 'package:travel_app/services/task_services.dart';

import '../representation/screens/users_screen/users_screen.dart';

Stream<List<ProjectModal>> getAllProjects() {
  var data = FirebaseFirestore.instance.collection("projects").snapshots().map(
      (snapshots) => snapshots.docs
          .map((doc) => ProjectModal.fromJson(doc.data()))
          .toList());
  return data;
}

// CollectionReference _collectionRef =
//     FirebaseFirestore.instance.collection("projects");
// List getdtaa() {
//   StreamBuilder(
//     stream: getAllTasks(),
//     builder: (context, snapshot) {
//       if (snapshot.hasError) {
//         return Text("${snapshot.error}");
//       }
//       if (snapshot.hasData) {
//         final taskModal = snapshot.data!;
//         currentTaskData = taskModal;
//         print("object--------------------------------");
//         return taskModal ;
//       } else {
//         return Center(child: CircularProgressIndicator());
//       }
//     },
//   );
// }

List<Object?> projectData = [];
List<ProjectModal> currentProjectData = [];

// Future<List<Object?>> getAllDataProject(
// ) async {
//   QuerySnapshot querySnapshot = await _collectionRef.get();
//   projectData = querySnapshot.docs.map((doc) => doc.data()).toList();
//   print(projectData);
//   currentProjectData = projectData.toList();
//   return projectData;
//   // print(data.toString());
// }
List<ProjectModal> searchProject(name, category, list) {
  print(name);
  print(category);
  List<ProjectModal> data = list;
  List<ProjectModal> listSearch = [];
  data.forEach((element) {
    if (category == "Tên" && element.name.toString().contains(name)) {
      listSearch.add(element);
    }
    if ('Tên nhân viên' == category &&
        element.users.toString().contains(name)) {
      listSearch.add(element);
    }
    if ("Tên task" == category && element.tasks.toString().contains(name)) {
      listSearch.add(element);
    }
    if ("Tên ngắn" == category && element.shortName.toString().contains(name)) {
      listSearch.add(element);
    }
  });
  return listSearch;
}

Future createProject(
    {name, description, shortName, users, tasks, createAt, updateAt}) async {
  final docProject = FirebaseFirestore.instance.collection("projects").doc();

  final projectModal = ProjectModal(
      id: docProject.id,
      name: name,
      description: description,
      shortName: shortName,
      users: users,
      tasks: tasks,
      createAt: createAt ?? DateTime.now(),
      updateAt: updateAt ?? DateTime.now());

  final json = projectModal.toJson();

  await docProject.set(json);
}

Future updateProject(
    {id,
    name,
    description,
    shortName,
    users,
    tasks,
    createAt,
    updateAt}) async {
  final docProject = FirebaseFirestore.instance.collection("projects").doc(id);

  final projectModal = ProjectModal(
      id: id,
      name: name,
      description: description,
      shortName: shortName,
      users: users,
      tasks: tasks,
      createAt: createAt ?? DateTime.now(),
      updateAt: updateAt ?? DateTime.now());

  final json = projectModal.toJson();

  await docProject.update(json);
}

Future deleteProject(id) async {
  print(id);
  final docProject = FirebaseFirestore.instance.collection("projects").doc(id);
  await docProject.delete();
}