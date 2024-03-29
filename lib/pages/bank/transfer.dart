import 'dart:ffi';
import 'dart:math';
// import 'package:push_notification/push_notification.dart';
import 'package:flutter/material.dart';
import 'package:project_uas/pages/home/wrapper.dart';
import 'package:project_uas/service/service_app.dart';
import 'package:push_notification/push_notification.dart';

import '../../model/list_users_model.dart';
import '../../model/userpreference.dart';

class Transfer extends StatefulWidget {
  const Transfer({
    Key? key,
  }) : super(key: key);

  @override
  State<Transfer> createState() => _TransferState();
}

class _TransferState extends State<Transfer> {
  String? qrData;

  UserReferences pref = UserReferences();

  Service service = Service();

  List<ListUsersModel?> user = [];

  String? userId;

  ListUsersModel? myUser;

  int? biayaAdmin;

  late Notificator notification;

  String notificationKey = 'key';
  late String _bodyText = 'notification test';

  // ignore: non_constant_identifier_names
  final jumlah_tarik = TextEditingController();
  // ignore: non_constant_identifier_names
  final nomor_rekening = TextEditingController();
  final pinController = TextEditingController();
  // ignore: unused_field

  void getUser() async {
    userId = await pref.getUserId();
    user = await service.getUser(user_id: userId!);
    setState(() {
      myUser = user[0];
      biayaAdmin = int.parse(myUser!.nomor_rekening.substring(1));
    });
  }

  void transferSaldo(String nominal, rekening) async {
    List<ListUsersModel?> users = await service.getAllUser();
    bool isExist = false;
    for (var i = 0; i < users.length; i++) {
      if (users[i]!.nomor_rekening == rekening) {
        isExist = true;
        break;
      }
    }
    userId = await pref.getUserId();

    if (isExist) {
      // check password

      // check saldo

      // biaya admin adalah 4 digit nomor rekening terakhir akun yang melakukan transfer
      // rekening memiliki total 5 digit

      if (myUser!.saldo >= (int.parse(nominal) + biayaAdmin!)) {
        await service
            .transfer(
                nominal: nominal, user_id: userId!, rekeningTujuan: rekening)
            .then((value) {
          notification.show(
            1,
            'Transfer berhasil',
            'Transfer sebesar $nominal berhasil',
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transfer gagal'),
              backgroundColor: Colors.red,
            ),
          );
        });

        await service.tarikan(nominal: biayaAdmin.toString(), user_id: userId!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saldo tidak cukup'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {}

    user = await service.getUser(user_id: userId!);
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

  TextEditingController jumlah_transfer = TextEditingController();
  TextEditingController nomor_tujuan = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // ignore: non_constant_identifier_names

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer'),
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
                      const Text('Masukan Nomor Rekening Tujuan'),
                      const SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        controller: nomor_rekening,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Masukan Nomor Tujuan';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          enabledBorder: UnderlineInputBorder(),
                          hintText: "Nomor rekening Tujuan...",
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      // Text(user.user_id.toString()),
                      const Text('Masukan Jumlah Transfer'),
                      const SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        // controller: jumlah_transfer,
                        controller: jumlah_transfer,
                        // controller: jumlah_transfer,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Masukan Jumlah Transfer...",
                          border: UnderlineInputBorder(),
                          enabledBorder: UnderlineInputBorder(),
                        ),
                      ),
                      // Spacer(),
                      const SizedBox(
                        height: 20.0,
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.height * 0.2,
                          child: ElevatedButton(
                            onPressed: () async {
                              transferSaldo(
                                jumlah_transfer.text,
                                nomor_rekening.text,
                              );
                            },
                            child: const Text('Transfer'),
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

  // void getUser() async {
  //   UserReferences pref = UserReferences();
  //   userId = await pref.getUserId();
  //   user = await service.getUser(userId: userId!);
  //   setState(() {
  //     myUser = user[0];
  //     biayaAdmin = int.parse(myUser!.nomorRekening.substring(1));
  //   });
  // }
}
