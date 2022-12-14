import 'dart:math';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:travel_app/Data/models/user_model.dart';
import 'package:travel_app/core/constants/dismension_constants.dart';
import 'package:travel_app/core/constants/text_style.dart';
import 'package:travel_app/core/helpers/asset_helper.dart';
import 'package:flutter_svg/svg.dart';
import 'package:travel_app/core/helpers/image_helper.dart';
import 'package:travel_app/representation/screens/main_app.dart';
import 'package:travel_app/representation/widgets/button_widget.dart';
import 'package:travel_app/representation/widgets/form_field.dart';

import '../../../Data/models/user_login_modal.dart';
import '../../../core/helpers/local_storage_helper.dart';
import '../../../services/user_services.dart';

class FormLoginScreen extends StatefulWidget {
  const FormLoginScreen({super.key});

  static const routeName = "/login";

  @override
  State<FormLoginScreen> createState() => _FormLoginScreenState();
}

class _FormLoginScreenState extends State<FormLoginScreen> {
  late TextEditingController userController, passwordController;
  List<UserModal>? listUser;

  @override
  void initState() {
    super.initState();
    userController = TextEditingController();
    passwordController = TextEditingController();
  }

  // final List<UserLoginModal> listUsers = [
  //   UserLoginModal(user: "admin", password: "admin"),
  //   UserLoginModal(user: "user", password: "user"),
  // ];

  // void saveUserPassword(userInput, passwordInput) async {
  //   final user = LocalStorageHelper.setValue('user', userInput);
  //   final pasword = LocalStorageHelper.setValue('password', passwordInput);
  // }

  void checkLogin(userInput, passwordInput) async {
    bool checkLogin = false;
    listUser?.forEach((element) async {
      if (element.userName == userInput && element.password == passwordInput) {
        checkLogin = true;
        UserLoginModal userLoginModal = UserLoginModal(
            password: element.password!,
            user: element.userName!,
            id: element.id!,
            position: element.position!);
        LocalStorageHelper.setValue('checkLogin', true);
        LocalStorageHelper.setValue('userLogin', userLoginModal.toJson());
        Navigator.pushReplacementNamed(context, MainApp.routeName);
        await EasyLoading.showSuccess("????ng nh???p th??nh c??ng");
        return;
      }
    });
    print(LocalStorageHelper.getValue('userLogin'));
    if (checkLogin == false) {
      await confirm(
        context,
        title: const Text('L???i ????ng nh???p'),
        content: Text('M???t kh???u ho???c t??n ????ng nh???p kh??ng ????ng'),
        textOK: const Text('X??c nh???n'),
        textCancel: const Text('Tho??t'),
      );
    }

    // UserLoginModal userLogin =
    //     UserLoginModal(password: passwordInput, user: userInput);
    // for (int i = 0; i < listUsers.length; i++) {
    //   if (listUsers[i].user == userInput &&
    //       listUsers[i].password == passwordInput) {
    //     LocalStorageHelper.setValue('checkLogin', true);
    //     // Navigator.pushNamed(context, MainApp.routeName);
    //     Navigator.pushReplacementNamed(context, MainApp.routeName);
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(kDefaultPadding),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              StreamBuilder(
                stream: getAllUsers(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  if (snapshot.hasData) {
                    final userModal = snapshot.data!;
                    listUser = userModal;
                    return Text('');
                  } else {
                    return Text('');
                  }
                },
              ),
              Container(
                margin: EdgeInsets.only(bottom: 40, top: 80),
                child: Column(children: [
                  ImageHelper.loadFromAsset(AssetHelper.flutterLogo,
                      width: MediaQuery.of(context).size.width * 0.5),
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    child: Text(
                      "Ch??o m???ng quay tr??? l???i!",
                      style: TextStyleCustom.h1Text,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Text(
                      "????ng nh???p ????? b???t ?????u",
                      style: TextStyleCustom.h2Text,
                    ),
                  )
                ]),
              ),
              FormInputField(
                label: "T??n User",
                hintText: "Nh???p t??n user",
                controller: userController,
              ),
              FormInputField(
                obscureText: true,
                label: "M???t kh???u",
                hintText: "Nh???p m???t kh???u",
                controller: passwordController,
              ),
              Padding(
                padding: EdgeInsets.only(top: kDefaultPadding),
                child: ButtonWidget(
                  title: "????ng nh???p",
                  ontap: () async {
                    checkLogin(userController.text, passwordController.text);
                  },
                ),
              ),
              // Padding(
              //   padding: EdgeInsets.all(kDefaultPadding),
              //   child: Text("T??i kho???n admin: admin/admin"),
              // ),
              // Padding(
              //   padding: EdgeInsets.all(kDefaultPadding),
              //   child: Text("T??i kho???n user: user/user"),
              // ),

              // Positioned.fill(
              //   child: ImageHelper.loadFromAsset(AssetHelper.computerGuy,
              //       fit: BoxFit.fitWidth , width: double.infinity , height: 280),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
