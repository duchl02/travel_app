import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:travel_app/Data/models/project_model.dart';
import 'package:travel_app/Data/models/user_model.dart';
import 'package:travel_app/core/constants/dismension_constants.dart';
import 'package:travel_app/core/extensions/date_time_format.dart';
import 'package:travel_app/representation/widgets/button_widget.dart';
import 'package:travel_app/representation/widgets/form_field.dart';
import 'package:travel_app/representation/widgets/select_multi_custom.dart';
import 'package:travel_app/representation/widgets/select_option.dart';
import 'package:travel_app/services/project_services.dart';
import 'package:travel_app/services/task_services.dart';
import 'package:travel_app/services/user_services.dart';

import '../../../core/constants/color_constants.dart';
import '../../../core/helpers/local_storage_helper.dart';
import '../../../services/home_services.dart';

class ProjectDetail extends StatefulWidget {
  const ProjectDetail({super.key, required this.projectModal});

  static const String routeName = "/project_detail";

  final ProjectModal projectModal;

  @override
  State<ProjectDetail> createState() => _ProjectDetailState();
}

class _ProjectDetailState extends State<ProjectDetail> {
  bool isLoading = false;
  TextEditingController? nameController = TextEditingController();
  TextEditingController? shortNameController = TextEditingController();
  TextEditingController? descriptionController = TextEditingController();

  List listUsers = [];
  List listUsersId = [];

  @override
  void initState() {
    super.initState();
    listUsersId = widget.projectModal.users ?? [];
    setValue();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController!.dispose();
    shortNameController!.dispose();
    descriptionController!.dispose();
    super.dispose();
  }

  void setValue() {
    if (widget.projectModal.name != null) {
      nameController!.text = widget.projectModal.name!;
    }
    if (widget.projectModal.shortName != null) {
      shortNameController!.text = widget.projectModal.shortName!;
    }
    if (widget.projectModal.description != null) {
      descriptionController!.text = widget.projectModal.description!;
    }
    listUsers = listUsersDefault;
  }

  List<UserModal> listUsersDefault = [];

  @override
  Widget build(BuildContext context) {
    dynamic _userLoginPosition =
        LocalStorageHelper.getValue('userLogin')["position"];
    dynamic _userLoginId = LocalStorageHelper.getValue('userLogin')["id"];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorPalette.primaryColor,
        title: Text(widget.projectModal.createAt != null
            ? "Ch???nh s???a d??? ??n"
            : "Th??m m???i d??? ??n"),
        actions: [
          widget.projectModal.createAt != null
              ? InkWell(
                  child: Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(
                        FontAwesomeIcons.trash,
                        color: Colors.white,
                      )),
                  onTap: () async {
                    if (_userLoginPosition == "admin") {
                      if (await confirm(
                        context,
                        title: const Text('X??c nh???n'),
                        content: Text('X??c nh???n x??a d??? ??n'),
                        textOK: const Text('X??c nh???n'),
                        textCancel: const Text('Tho??t'),
                      )) {
                        setState(() {
                          isLoading = true;
                        });
                        await deleteProject(widget.projectModal.id.toString());
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
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   
                    FormInputField(
                      label: "T??n d??? ??n",
                      hintText: "Nh???p t??n d??? ??n",
                      controller: nameController,
                      onChanged: (value) {
                        setState(() {
                          nameController!.text = value;
                        });
                      },
                    ),

                    FormInputField(
                      label: "T??n ng???n g???n",
                      controller: shortNameController,
                      hintText: "Nh???p t??n",
                      onChanged: (value) {
                        setState(() {
                          shortNameController!.text = value;
                        });
                      },
                    ),
                    // FormInputField(label: "Ng?????i th???c hi???n", hintText: "Nh???p ti??u ?????"),

                    StreamBuilder(
                      stream: getAllUsers(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }
                        if (snapshot.hasData) {
                          final projectModal = snapshot.data!;
                          // listUsersDefault = projectModal;
                          listUsersDefault = [];
                          for (var e in projectModal) {
                            for (var e2 in listUsersId) {
                              if (e.id == e2) {
                                listUsersDefault.add(e);
                              }
                            }
                          }
                          return SelectMultiCustom(
                            title: "Nh??n vi??n",
                            listValues: projectModal,
                            defaultListValues: listUsersDefault,
                            onTap: (value) {
                              // print("---------------------------------------");

                              // print(listUsers);
                              listUsers = value;
                            },
                          );
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
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
                    SizedBox(height: 6,),
                     Row(
                      children: [
                        Text("Ng??y t???o: ",
                          style: TextStyle(color: ColorPalette.subTitleColor),),
                        Text(widget.projectModal.createAt != null
                            ? formatDate(widget.projectModal.createAt)
                            : "Ch??a c??",
                          style: TextStyle(color: ColorPalette.subTitleColor),)
                      ],
                    ),
                    Row(
                      children: [
                        Text("Ng??y ch???nh s???a: ",
                          style: TextStyle(color: ColorPalette.subTitleColor),),
                        Text(widget.projectModal.updateAt != null
                            ? formatDate(widget.projectModal.updateAt)
                            : "Ch??a c??",
                          style: TextStyle(color: ColorPalette.subTitleColor),)
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Row(
                        children: [
                          Flexible(
                              flex: 1,
                              child: ButtonWidget(
                                color: ColorPalette.secondColor.withOpacity(0.2),
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
                                  if (_userLoginPosition == "admin") {
                                    if (listUsers != []) {
                                      listUsersId = [];
                                      for (var e in listUsers) {
                                        listUsersId.add(e.id);
                                      }
                                    }

                                    if (widget.projectModal.createAt != null) {
                                      if (await confirm(
                                        context,
                                        title: const Text('X??c nh???n'),
                                        content: Text('X??c nh???n s???a d??? ??n'),
                                        textOK: const Text('X??c nh???n'),
                                        textCancel: const Text('Tho??t'),
                                      )) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        await updateProject(
                                            id: widget.projectModal.id
                                                .toString(),
                                            name: nameController!.text,
                                            description:
                                                descriptionController!.text,
                                            users: listUsersId,
                                            shortName:
                                                shortNameController!.text,
                                            createAt:
                                                widget.projectModal.createAt ??
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
                                        content:
                                            Text('X??c nh???n th??m m???i d??? ??n'),
                                        textOK: const Text('X??c nh???n'),
                                        textCancel: const Text('Tho??t'),
                                      )) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        await createProject(
                                            name: nameController!.text,
                                            description:
                                                descriptionController!.text,
                                            users: listUsersId,
                                            shortName:
                                                shortNameController!.text,
                                            createAt:
                                                widget.projectModal.createAt ??
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
