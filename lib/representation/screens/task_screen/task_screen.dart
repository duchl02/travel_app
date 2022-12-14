import 'dart:core';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:travel_app/Data/models/project_model.dart';
import 'package:travel_app/Data/models/user_model.dart';
import 'package:travel_app/core/constants/color_constants.dart';
import 'package:travel_app/representation/screens/task_screen/task_detail_screen.dart';
import 'package:travel_app/representation/widgets/list_task.dart';
import 'package:travel_app/representation/widgets/search_input.dart';
import 'package:travel_app/representation/widgets/select_option.dart';
import 'package:travel_app/services/project_services.dart';
import 'package:travel_app/services/user_services.dart';

import '../../../Data/models/option_modal.dart';
import '../../../Data/models/task_model.dart';
import '../../../core/helpers/local_storage_helper.dart';
import '../../../services/task_services.dart';

class TaskScreen extends StatefulWidget {
  TaskScreen({
    super.key,
    this.checkIsUser = false,
  });

  var checkIsUser;

  static const routeName = '/task_screen';

  @override
  State<TaskScreen> createState() => _TaskScreenState();
  // final TaskModal taskModal;
}

class _TaskScreenState extends State<TaskScreen> {
  // String dropdownValue = list.first

  @override
  void initState() {
    super.initState();
    category = _list[0].value;
  }

  @override
  void dispose() {
    super.dispose();
  }

  final TaskModal taskModalEmty = TaskModal();
  List<TaskModal> list = [];
  List<UserModal> _listUser = [];
  List<ProjectModal> _listProject = [];

  bool isSearch = false;
  late String category;
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var userLoginId = LocalStorageHelper.getValue('userLogin')["id"];
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
          stream: getAllTasks(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            if (snapshot.hasData) {
              final taskModal = snapshot.data!;
              taskModal.map(
                (e) {},
              );
              return Text(
                "Task (${taskModal.length})",
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
        backgroundColor: ColorPalette.primaryColor,
        actions: [
          InkWell(
            child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(
                  FontAwesomeIcons.plus,
                )),
            onTap: () {
              Navigator.of(context)
                  .pushNamed(TaskDetail.routeName, arguments: taskModalEmty);
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 10, left: 10, right: 10),
        child: Column(children: [
          SearchInput(
            controller: textEditingController,
            onChanged: (value) {
              setState(() {
                textEditingController.text = value;
              });
            },
          ),
          SelectOption(
            list: _list,
            searchOption: 0,
            dropdownValue: category,
            onChanged: ((p0) {
              setState(() {
                category = p0.toString();
              });
            }),
          ),
          SizedBox(
            height: 10,
          ),
          StreamBuilder(
            stream: getAllUsers(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              if (snapshot.hasData) {
                _listUser = snapshot.data!;

                return SizedBox();
              } else {
                return SizedBox();
              }
            },
          ),
          StreamBuilder(
            stream: getAllProjects(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              if (snapshot.hasData) {
                _listProject = snapshot.data!;

                return SizedBox();
              } else {
                return SizedBox();
              }
            },
          ),
          Expanded(
              child: StreamBuilder(
            stream: getAllTasks(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              if (snapshot.hasData) {
                final taskModal = snapshot.data!;
                taskModal.sort((a, b) {
                  var adate = a.createAt;
                  var bdate = b.createAt;
                  return -adate!.compareTo(bdate!);
                });

                if (widget.checkIsUser) {
                  currentTaskData = taskModal.reversed
                      .where((element) => element.userId == userLoginId)
                      .toList();
                } else {
                  currentTaskData = searchTask(textEditingController.text,
                      category, taskModal, _listUser, _listProject);
                }
                currentTaskData.sort((a, b) {
                  var adate = a.createAt;
                  var bdate = b.createAt;
                  return -adate!.compareTo(bdate!);
                });

                return ListView(
                  children: currentTaskData
                      .map(((e) => ListTask(
                            taskModal: e,
                          )))
                      .toList(),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ))
        ]),
      ),
    );
  }
}

List<OptionModal> _list = [
  OptionModal(value: "name", display: "T??n task"),
  OptionModal(value: "userName", display: "T??n nh??n vi??n"),
  OptionModal(value: "project", display: "D??? ??n"),
  OptionModal(value: "status", display: "Tr???ng th??i"),
];
