import 'dart:math';

import 'package:flutter/material.dart';
import 'package:project_uas/service/service_app.dart';
import 'package:push_notification/push_notification.dart';

import '../../model/list_users_model.dart';
import '../../model/userpreference.dart';

import '../home/wrapper.dart';

class Penarikan extends StatefulWidget {
  const Penarikan({Key? key, user}) : super(key: key);

  @override
  State<Penarikan> createState() => _PenarikanState();
}

class _PenarikanState extends State<Penarikan> {
  UserReferences pref = UserReferences();

  Service userServices = Service();

  List<ListUsersModel?> user = [];

  String? userId;

  ListUsersModel? myUser;

  late Notificator notification;

  String notificationKey = 'key';
  String _bodyText = 'notification test';

  TextEditingController jumlah_tarikan = TextEditingController();

  void getUser() async {
    userId = await pref.getUserId();
    user = await userServices.getUser(user_id: userId!);
    setState(() {
      myUser = user[0];
    });
  }

  void tarikSaldo(nominal) async {
    userId = await pref.getUserId();
    await userServices
        .tarikan(nominal: nominal, user_id: userId!)
        .then((value) {
      // snackbar

      notification.show(
        Random().nextInt(100),
        'Transaksi Berhasil',
        'Penarikan sebesar $nominal berhasil',
        imageUrl: 'https://www.lumico.io/wp-019/09/flutter.jpg',
        data: {notificationKey: '[notification data]'},
        notificationSpecifics: NotificationSpecifics(
          AndroidNotificationSpecifics(
            autoCancelable: true,
          ),
        ),
      );
    }).onError((error, stackTrace) {
      // snackbar
    });

    user = await userServices.getUser(user_id: userId!);
    setState(() {
      myUser = user[0];
    });
  }

  @override
  void initState() {
    getUser();
    super.initState();
    notification = Notificator(
      onPermissionDecline: () {
        // ignore: avoid_print
        print('permission decline');
      },
      onNotificationTapCallback: (notificationData) {
        setState(
          () {
            _bodyText = 'notification open: '
                '${notificationData[notificationKey].toString()}';
          },
        );
      },
    )..requestPermissions(
        requestSoundPermission: true,
        requestAlertPermission: true,
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarik Saldo'),
        backgroundColor: const Color(0xFF1a247f),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20.0,
                ),
                Container(
                  padding: const EdgeInsets.all(20.0),
                  // height: 100.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: const Color.fromARGB(255, 10, 7, 139),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('masukan Jumlah Tarik !'),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        controller: jumlah_tarikan,
                        // onChanged: (value) => jumlah_tarikan,
                        // controller: jumlah_transfer,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Tolong Masukan Jumlah Pnarikan !';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      // Spacer(),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.height * 0.2,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (jumlah_tarikan.text.isNotEmpty) {
                                tarikSaldo(jumlah_tarikan.text);
                                jumlah_tarikan.clear();
                              }
                              // ignore: use_build_context_synchronously
                            },
                            child: const Text('Tarik !'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 120,
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
