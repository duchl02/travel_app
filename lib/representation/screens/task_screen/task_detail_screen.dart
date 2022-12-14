import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:travel_app/Data/models/option_modal.dart';
import 'package:travel_app/Data/models/task_model.dart';
import 'package:travel_app/Data/models/user_model.dart';
import 'package:travel_app/core/constants/dismension_constants.dart';
import 'package:travel_app/core/extensions/date_time_format.dart';
import 'package:travel_app/representation/widgets/button_widget.dart';
import 'package:travel_app/representation/widgets/form_field.dart';
import 'package:travel_app/representation/widgets/select_option.dart';
import 'package:travel_app/services/home_services.dart';
import 'package:travel_app/services/project_services.dart';
import 'package:travel_app/services/task_services.dart';

import '../../../Data/models/project_model.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/helpers/local_storage_helper.dart';
import '../../../services/user_services.dart';

class TaskDetail extends StatefulWidget {
  const TaskDetail({super.key, required this.taskModal});

  static const String routeName = "/task_detail";

  final TaskModal taskModal;

  @override
  State<TaskDetail> createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail> {
  bool isLoading = false;
  TextEditingController? nameController = TextEditingController();
  TextEditingController? timeSuccessController = TextEditingController();
  TextEditingController? descriptionController = TextEditingController();
  late String userId;
  late String projectId;
  late String priorityId;
  late String statusId;
  @override
  void initState() {
    super.initState();
    setValue();
    // userController = TextEditingController();
    // passwordController = TextEditingController();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController!.dispose();
    timeSuccessController!.dispose();
    descriptionController!.dispose();
    super.dispose();
  }

  void setValue() {
    if (widget.taskModal.name != null) {
      nameController!.text = widget.taskModal.name!;
    }
    if (widget.taskModal.timeSuccess != null) {
      timeSuccessController!.text = widget.taskModal.timeSuccess!;
    }
    if (widget.taskModal.description != null) {
      descriptionController!.text = widget.taskModal.description!;
    }
    if (widget.taskModal.userId != null) {
      userId = widget.taskModal.userId!;
    }
    if (widget.taskModal.priority != null) {
      priorityId = widget.taskModal.priority!;
    }
    if (widget.taskModal.status != null) {
      statusId = widget.taskModal.status!;
    }
    if (widget.taskModal.projectId != null) {
      projectId = widget.taskModal.projectId!;
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic _userLoginPosition =
        LocalStorageHelper.getValue('userLogin')["position"];
    dynamic _userLoginId = LocalStorageHelper.getValue('userLogin')["id"];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorPalette.primaryColor,
        title: Text(widget.taskModal.createAt != null
            ? "Ch???nh s???a task"
            : "Th??m m???i task"),
        actions: [
          widget.taskModal.createAt != null
              ? InkWell(
                  child: Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(
                        FontAwesomeIcons.trash,
                        color: Colors.white,
                      )),
                  onTap: () async {
                    if (_userLoginPosition == "admin" ||
                        _userLoginId == widget.taskModal.userId ||
                        widget.taskModal.userId == null) {
                      if (await confirm(
                        context,
                        title: const Text('X??c nh???n'),
                        content: Text('X??c nh???n x??a task'),
                        textOK: const Text('X??c nh???n'),
                        textCancel: const Text('Tho??t'),
                      )) {
                        setState(() {
                          isLoading = true;
                        });
                        await deleteTask(widget.taskModal.id.toString());
                        setState(() {
                          isLoading = false;
                        });
                        Navigator.of(context).pop();
                        await EasyLoading.showSuccess("X??a th??nh c??ng");
                      }
                    } else {
                      notAlowAction(context);
                    }
                  },
                )
              : Text("")
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormInputField(
                      label: "Ti??u ?????",
                      hintText: "Nh???p ti??u ?????",
                      controller: nameController,
                      onChanged: (value) {
                        setState(() {
                          nameController!.text = value;
                        });
                      },
                    ),
                    StreamBuilder(
                      stream: getAllUsers(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }
                        if (snapshot.hasData) {
                          final userModal = snapshot.data!;
                          List<OptionModal> _listSatff = [];
                          var userLogin =
                              LocalStorageHelper.getValue('userLogin');
                          List<UserModal> user = [];
                          for (var e in userModal) {
                            if (e.id == userLogin["id"]) {
                              user.add(e);
                            }
                          }
                          if (userLogin["id"] != widget.taskModal.userId &&
                                  widget.taskModal.userId != null ||
                              userLogin["position"] == "admin") {
                            for (var e in userModal) {
                              _listSatff.add(
                                  OptionModal(value: e.id!, display: e.name!));
                            }
                          } else {
                            for (var e in user) {
                              _listSatff.add(
                                  OptionModal(value: e.id!, display: e.name!));
                            }
                          }

                          // UserModal userDefaults =
                          //     findUserById(userId, userModal);
                          return SelectOption(
                            label: "Ng?????i th???c hi???n",
                            list: _listSatff,
                            dropdownValue: widget.taskModal.userId != null
                                ? widget.taskModal.userId.toString()
                                : "",
                            onChanged: (p0) {
                              userId = p0 as String;
                            },
                          );
                        } else {
                          return Center(child: CircularProgressIndicator());
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
                          final projectModal = snapshot.data!;
                          List<OptionModal> _listProject = [];
                          var userLogin =
                              LocalStorageHelper.getValue('userLogin');
                          List<ProjectModal> listTasks = [];
                          for (var e in projectModal) {
                            for (var e2 in e.users!) {
                              if (e2 == userLogin["id"]) {
                                listTasks.add(e);
                              }
                            }
                          }
                          if (userLogin["position"] == "admin") {
                            for (var e in projectModal) {
                              _listProject.add(
                                  OptionModal(value: e.id!, display: e.name!));
                            }
                          } else {
                            for (var e in listTasks) {
                              _listProject.add(
                                  OptionModal(value: e.id!, display: e.name!));
                            }
                          }

                          return SelectOption(
                            label: "D??? ??n",
                            list: _listProject,
                            dropdownValue: widget.taskModal.projectId != null
                                ? widget.taskModal.projectId.toString()
                                : "",
                            onChanged: (p0) {
                              projectId = p0 as String;
                            },
                          );
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                    SelectOption(
                      label: "????? ??u ti??n",
                      list: _listPriority,
                      dropdownValue: widget.taskModal.priority != null
                          ? widget.taskModal.priority.toString()
                          : "",
                      onChanged: (p0) {
                        priorityId = p0 as String;
                      },
                    ),
                    SelectOption(
                      label: "Tr???ng th??i",
                      list: _listStatus,
                      dropdownValue: widget.taskModal.status != null
                          ? widget.taskModal.status.toString()
                          : "",
                      onChanged: (p0) {
                        statusId = p0 as String;
                      },
                    ),
                    FormInputField(
                      label: "Th???i gian ho??n th??nh",
                      controller: timeSuccessController,
                      hintText: "Nh???p s??? gi???",
                      onChanged: (value) {
                        setState(() {
                          timeSuccessController!.text = value;
                        });
                      },
                    ),
                    FormInputField(
                      label: "M?? t???",
                      hintText: "Nh???p m?? t???",
                      maxLines: 3,
                      controller: descriptionController,
                      onChanged: (value) {
                        setState(() {
                          descriptionController!.text = value;
                        });
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          "Ng??y t???o: ",
                          style: TextStyle(color: ColorPalette.subTitleColor),
                        ),
                        Text(
                          widget.taskModal.createAt != null
                              ? formatDate(widget.taskModal.createAt)
                              : "Ch??a c??",
                          style: TextStyle(color: ColorPalette.subTitleColor),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Ng??y ch???nh s???a: ",
                          style: TextStyle(color: ColorPalette.subTitleColor),
                        ),
                        Text(
                          widget.taskModal.updateAt != null
                              ? formatDate(widget.taskModal.updateAt)
                              : "Ch??a c??",
                          style: TextStyle(color: ColorPalette.subTitleColor),
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Row(
                        children: [
                          Flexible(
                              flex: 1,
                              child: ButtonWidget(
                                color:
                                    ColorPalette.secondColor.withOpacity(0.2),
                                title: "H???y",
                                ontap: (() {
                                  Navigator.of(context).pop();
                                }),
                              )),
                          SizedBox(
                            width: kDefaultPadding,
                          ),
                          Flexible(
                              flex: 1,
                              child: ButtonWidget(
                                title: "X??c nh???n",
                                ontap: () async {
                                  if (_userLoginPosition == "admin" ||
                                      _userLoginId == widget.taskModal.userId ||
                                      widget.taskModal.userId == null) {
                                    if (widget.taskModal.createAt != null) {
                                      if (await confirm(
                                        context,
                                        title: const Text('X??c nh???n'),
                                        content: Text('X??c nh???n s???a task'),
                                        textOK: const Text('X??c nh???n'),
                                        textCancel: const Text('Tho??t'),
                                      )) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        await updateTask(
                                            id: widget.taskModal.id.toString(),
                                            name: nameController!.text,
                                            description:
                                                descriptionController!.text,
                                            priority: priorityId,
                                            projectId: projectId,
                                            userId: userId,
                                            status: statusId,
                                            timeSuccess:
                                                timeSuccessController!.text,
                                            createAt:
                                                widget.taskModal.createAt ??
                                                    DateTime.now(),
                                            updateAt: DateTime.now());
                                        setState(() {
                                          isLoading = false;
                                        });
                                        Navigator.of(context).pop();

                                        await EasyLoading.showSuccess(
                                            "S???a th??nh c??ng");
                                      }
                                    } else {
                                      if (await confirm(
                                        context,
                                        title: const Text('X??c nh???n'),
                                        content: Text('X??c nh???n t???o task'),
                                        textOK: const Text('X??c nh???n'),
                                        textCancel: const Text('Tho??t'),
                                      )) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        await createTask(
                                            name: nameController!.text,
                                            description:
                                                descriptionController!.text,
                                            priority: priorityId,
                                            projectId: projectId,
                                            userId: userId,
                                            status: statusId,
                                            timeSuccess:
                                                timeSuccessController!.text,
                                            createAt:
                                                widget.taskModal.createAt ??
                                                    DateTime.now(),
                                            updateAt: DateTime.now());
                                        setState(() {
                                          isLoading = false;
                                        });
                                        Navigator.of(context).pop();

                                        await EasyLoading.showSuccess(
                                            "T???o th??nh c??ng");
                                      }
                                    }
                                  } else {
                                    notAlowAction(context);
                                  }
                                },
                              )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}

List<OptionModal> _listPriority = [
  OptionModal(value: "Kh??ng ??u ti??n", display: "Kh??ng ??u ti??n"),
  OptionModal(value: "??u ti??n v???a", display: "??u ti??n v???a"),
  OptionModal(value: "??u ti??n", display: "??u ti??n"),
  OptionModal(value: "C???p b??ch", display: "C???p b??ch"),
];
List<OptionModal> _listStatus = [
  OptionModal(value: "Coding", display: "Coding"),
  OptionModal(value: "HoldOn", display: "HoldOn"),
  OptionModal(value: "In progress", display: "In progress"),
  OptionModal(value: "Done", display: "Done"),
];
