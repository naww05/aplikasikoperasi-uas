import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:project_uas/model/list_users_model.dart';
import 'package:project_uas/pages/home/mobileView.dart';
import 'package:project_uas/pages/home/tabletView.dart';
import 'package:project_uas/pages/login/login.dart';
import 'package:project_uas/service/service_app.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../model/userpreference.dart';
import '../scanner.dart';

// import 'package:shared_preferences/shared_preferences.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  UserReferences userReferences = UserReferences();
  Service userServices = Service();

  String? user_id;

  List<ListUsersModel?> _mod = [null];

  void awaiting() async {
    await userReferences.getUserId().then((value) {
      setState(() {
        user_id = value;
      });
    });
  }

  void datas(user_id) async {
    if (_mod[0] == null) {
      _mod = await userServices.getUser(user_id: user_id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // cek jika terdapat data login
    userReferences.getUserId().then((value) {
      setState(() {
        user_id = value;
      });
    });

    if (user_id != null && user_id != '') {
      return FutureBuilder(
        builder: ((context, snapshot) {
          datas(user_id);

          if (_mod[0] != null) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: const Text('Koperasi Undiksha'),
                centerTitle: true,
                backgroundColor: const Color.fromARGB(255, 10, 7, 139),
                actions: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        user_id = null;
                        _mod = [null];
                        userReferences.setNullAllData();
                      });
                    },
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
              body: LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth > 480) {
                  return const TabletView();
                } else {
                  return MobileView(myUser: _mod[0]);
                }
              }),
              floatingActionButton: FloatingActionButton(
                backgroundColor: Color(0XFF0020f6),
                child: Icon(Icons.qr_code_scanner_sharp),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QrScanner(),
                    ),
                  );
                },
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: BottomAppBar(
                color: Color(0XFF0020f6),
                shape: CircularNotchedRectangle(),
                notchMargin: 10,
                child: Container(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MaterialButton(
                        padding: EdgeInsets.only(left: 100),
                        minWidth: 40,
                        onPressed: () {},
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.settings, color: Colors.white),
                            Text(
                              'Settings',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                      ),
                      MaterialButton(
                        padding: EdgeInsets.only(right: 100),
                        minWidth: 40,
                        onPressed: () {},
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.account_circle_rounded,
                                color: Colors.white),
                            Text(
                              'Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }),
      );
    } else {
      return const Login();
    }
  }
}
