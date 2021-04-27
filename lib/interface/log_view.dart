import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hds_overlay/controllers/socket_server_controller.dart';
import 'package:hds_overlay/model/log_message.dart';
import 'package:hds_overlay/utils/themes.dart';

class LogView extends StatelessWidget {
  final SocketServerController socketServerController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.black),
      width: Themes.sideBarWidth,
      child: Obx(
        () {
          final logs = socketServerController.logs.reversed.toList();
          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Text(
                log.message,
                style: TextStyle(color: log.level.color),
              );
            },
          );
        },
      ),
    );
  }
}
