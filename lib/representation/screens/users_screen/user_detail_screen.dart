import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_app/Data/models/option_modal.dart';
import 'package:travel_app/Data/models/user_model.dart';
import 'package:travel_app/core/constants/dismension_constants.dart';
import 'package:travel_app/core/extensions/date_time_format.dart';
import 'package:travel_app/representation/screens/priview_image_screen.dart';
import 'package:travel_app/representation/widgets/button_widget.dart';
import 'package:travel_app/representation/widgets/form_field.dart';
import 'package:travel_app/services/user_services.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/helpers/asset_helper.dart';
import '../../../core/helpers/local_storage_helper.dart';
import '../../../services/home_services.dart';
import '../../widgets/select_option.dart';

class UserDetail extends StatefulWidget {
  const UserDetail({super.key, required this.userModal});

  static const String routeName = "/user_detail";

  final UserModal userModal;

  @override
  State<UserDetail> createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetail> {
  bool isLoading = false;
  TextEditingController? nameController = TextEditingController();
  TextEditingController? userNameController = TextEditingController();
  TextEditingController? passwordController = TextEditingController();
  TextEditingController? birthdayController = TextEditingController();
  TextEditingController? addressController = TextEditingController();
  TextEditingController? idNumberController = TextEditingController();
  TextEditingController? emailController = TextEditingController();
  TextEditingController? phoneNumberController = TextEditingController();

  List listProject = [];
  List listProjectsId = [];
  String positionId = "";

  @override
  void initState() {
    super.initState();
    // listUsersId = widget.userModal.users ?? [];
    setValue();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController!.dispose();
    userNameController!.dispose();
    passwordController!.dispose();
    birthdayController!.dispose();
    addressController!.dispose();
    idNumberController!.dispose();
    emailController!.dispose();
    super.dispose();
  }

  void setValue() {
    if (widget.userModal.name != null) {
      nameController!.text = widget.userModal.name!;
    }
    if (widget.userModal.password != null) {
      passwordController!.text = widget.userModal.password!;
    }
    if (widget.userModal.birthday != null) {
      birthdayController!.text = formatDate(widget.userModal.birthday);
    }
    if (widget.userModal.userName != null) {
      userNameController!.text = widget.userModal.userName!;
    }
    if (widget.userModal.idNumber != null) {
      idNumberController!.text = widget.userModal.idNumber!;
    }
    if (widget.userModal.email != null) {
      emailController!.text = widget.userModal.email!;
    }
    if (widget.userModal.phoneNumber != null) {
      phoneNumberController!.text = widget.userModal.phoneNumber!;
    }
    if (widget.userModal.address != null) {
      addressController!.text = widget.userModal.address!;
    }
    if (widget.userModal.position != null) {
      positionId = widget.userModal.position!;
    }
    if (widget.userModal.birthday != null) {
      dateTime = widget.userModal.birthday!;
    }
    if (widget.userModal.projects != null) {
      listProjectsId = widget.userModal.projects!;
    }
    if (widget.userModal.imageUser != null) {
      imagePath = widget.userModal.imageUser!;
    }
  }

  List listProjectsDefault = [];

  late DateTime dateTime = DateTime.now();
  File? file;
  String? imagePath;

  @override
  Widget build(BuildContext context) {
    dynamic _userLoginPosition =
        LocalStorageHelper.getValue('userLogin')["position"];
    dynamic _userLoginId = LocalStorageHelper.getValue('userLogin')["id"];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorPalette.primaryColor,
        title: Text(widget.userModal.createAt != null
            ? "Ch???nh s???a nh??n vi??n"
            : "Th??m m???i nh??n vi??n"),
        actions: [
          widget.userModal.createAt != null
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
                        content: Text('X??c nh???n x??a nh??n vi??n'),
                        textOK: const Text('X??c nh???n'),
                        textCancel: const Text('Tho??t'),
                      )) {
                        setState(() {
                          isLoading = true;
                        });
                        await deleteUser(widget.userModal.id.toString());
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
                    Center(
                      child: InkWell(
                        onTap: () async {
                          if (await confirm(
                            context,
                            title: const Text('X??c nh???n'),
                            content: Text('X??c nh???n h??nh ?????ng'),
                            textCancel: const Text('Xem ???nh'),
                            textOK: const Text('T???i ???nh l??n'),
                          )) {
                            chooseImage();
                          } else {
                            Navigator.of(context).pushNamed(
                                PreviewImageScreen.routeName,
                                arguments: imagePath ??
                                    "https://t4.ftcdn.net/jpg/02/29/75/83/360_F_229758328_7x8jwCwjtBMmC6rgFzLFhZoEpLobB6L8.jpg");
                          }
                          ;
                        },
                        child: Hero(
                          tag: imagePath ??
                              "https://t4.ftcdn.net/jpg/02/29/75/83/360_F_229758328_7x8jwCwjtBMmC6rgFzLFhZoEpLobB6L8.jpg",
                          child: Container(
                            height: 160,
                            width: 160,
                            decoration: BoxDecoration(
                              border: Border.all(width: 3, color: Colors.black),
                              shape: BoxShape.circle,
                              image: file == null
                                  ? imagePath == null
                                      ? DecorationImage(
                                          image: AssetImage(AssetHelper.user),
                                          fit: BoxFit.cover)
                                      : DecorationImage(
                                          image: NetworkImage(imagePath!),
                                          fit: BoxFit.cover)
                                  : DecorationImage(
                                      image: FileImage(file!),
                                      fit: BoxFit.cover),
                            ),
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                    ),

                    FormInputField(
                      label: "H??? v?? t??n",
                      hintText: "Nh???p h??? v?? t??n",
                      controller: nameController,
                      onChanged: (value) {
                        setState(() {
                          nameController!.text = value;
                        });
                      },
                    ),

                    FormInputField(
                      label: "User name",
                      controller: userNameController,
                      hintText: "Nh???p user name",
                      onChanged: (value) {
                        setState(() {
                          userNameController!.text = value;
                        });
                      },
                    ),
                    FormInputField(
                      label: "M???t kh???u",
                      controller: passwordController,
                      hintText: "Nh???p m???t kh???u",
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          passwordController!.text = value;
                        });
                      },
                    ),
                    FormInputField(
                      label: "Ng??y sinh",
                      controller: birthdayController,
                      hintText: "Ch???n ng??y sinh",
                      onTap: () async {
                        final dateData = await pickDate();
                        if (dateData == null) {
                          return;
                        }
                        setState(() {
                          dateTime = dateData;
                          birthdayController!.text =
                              "${dateTime.day} - ${dateTime.month} - ${dateTime.year}";
                        });
                      },
                    ),
                    FormInputField(
                      label: "?????a ch???",
                      controller: addressController,
                      hintText: "Nh???p ?????a ch???",
                      onChanged: (value) {
                        setState(() {
                          addressController!.text = value;
                        });
                      },
                    ),
                    FormInputField(
                      label: "S??? ??i???n tho???i",
                      controller: phoneNumberController,
                      hintText: "Nh???p s??? ??i???n tho???i",
                      onChanged: (value) {
                        setState(() {
                          phoneNumberController!.text = value;
                        });
                      },
                    ),
                    FormInputField(
                      label: "CMND",
                      controller: idNumberController,
                      hintText: "Nh???p CMND",
                      onChanged: (value) {
                        setState(() {
                          idNumberController!.text = value;
                        });
                      },
                    ),

                    SelectOption(
                      label: 'V??? tr??',
                      list: _listPositions,
                      dropdownValue: widget.userModal.position != null
                          ? widget.userModal.position.toString()
                          : _listPositions[0].value,
                      onChanged: (p0) {
                        positionId = p0 as String;
                      },
                    ),
                    FormInputField(
                      label: "Email",
                      controller: emailController,
                      hintText: "Nh???p email",
                      onChanged: (value) {
                        setState(() {
                          emailController!.text = value;
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
                          widget.userModal.createAt != null
                              ? formatDate(widget.userModal.createAt)
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
                          widget.userModal.updateAt != null
                              ? formatDate(widget.userModal.updateAt)
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
                                      _userLoginId == widget.userModal.id ||
                                      widget.userModal.id == null) {
                                    if (listProject != [] &&
                                        listProject.length != 0) {
                                      listProjectsId = [];
                                      for (var e in listProject) {
                                        listProjectsId.add(e.id);
                                      }
                                    }
                                    if (widget.userModal.createAt != null) {
                                      if (await confirm(
                                        context,
                                        title: const Text('X??c nh???n'),
                                        content: Text('X??c nh???n s???a nh??n vi??n'),
                                        textOK: const Text('X??c nh???n'),
                                        textCancel: const Text('Tho??t'),
                                      )) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        String? url;
                                        if (file != null) {
                                          url = await uploadImage();
                                        } else {
                                          url = widget.userModal.imageUser;
                                        }

                                        await updateUser(
                                            imageUser: url,
                                            id: widget.userModal.id.toString(),
                                            name: nameController!.text,
                                            userName: userNameController!.text,
                                            password: passwordController!.text,
                                            birthday: dateTime,
                                            idNumber: idNumberController!.text,
                                            position: positionId,
                                            // projects: listProjectsId,
                                            checkIn:
                                                widget.userModal.checkIn ?? [],
                                            phoneNumber:
                                                phoneNumberController!.text,
                                            email: emailController!.text,
                                            address: addressController!.text,
                                            createAt:
                                                widget.userModal.createAt ??
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
                                            Text('X??c nh???n t???o m???i nh??n vi??n'),
                                        textOK: const Text('X??c nh???n'),
                                        textCancel: const Text('Tho??t'),
                                      )) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        String? url;

                                        if (file != null) {
                                          url = await uploadImage();
                                        } else {
                                          url = widget.userModal.imageUser;
                                        }

                                        await createUser(
                                            imageUser: url,
                                            name: nameController!.text,
                                            userName: userNameController!.text,
                                            password: passwordController!.text,
                                            birthday: dateTime,
                                            idNumber: idNumberController!.text,
                                            address: addressController!.text,
                                            phoneNumber:
                                                phoneNumberController!.text,
                                            position: positionId,
                                            email: emailController!.text,
                                            createAt:
                                                widget.userModal.createAt ??
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

  void chooseImage() async {
    XFile? xfile = await ImagePicker().pickImage(source: ImageSource.gallery);

    print('xFile + ${xfile?.path}');

    file = File(xfile!.path);
    setState(() {});
  }

  Future<String> uploadImage() async {
    TaskSnapshot taskSnapshot = await FirebaseStorage.instance
        .ref()
        .child('profile')
        .child(
            '${FirebaseFirestore.instance.collection("users").id}_${widget.userModal.id}')
        .putFile(file!);
    print(' 11 ${taskSnapshot.ref.getDownloadURL()}');
    return taskSnapshot.ref.getDownloadURL();
  }

  Future<DateTime?> pickDate() => showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100));
}

List<OptionModal> _listPositions = [
  OptionModal(value: "user", display: "Nh??n vi??n"),
  OptionModal(value: "manager", display: "Qu???n l??"),
  OptionModal(value: "admin", display: "Admin"),
];
