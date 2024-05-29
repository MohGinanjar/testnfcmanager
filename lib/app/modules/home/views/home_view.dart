import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeView'),
        centerTitle: true,
      ),
      body:Center(
        child: Obx(() => Text(controller.nfcData.value)),
      ),
      floatingActionButton: Row(
        children: [
          ElevatedButton(
  onPressed: () {
    controller.readNfcTag(); // Memulai pembacaan tag NFC saat tombol ditekan
  },
  child: Text('Read NFC Tag'),
),
          FloatingActionButton(
            onPressed: () {
              // You can update the message to write here if needed
              controller.messageToWrite.value = '{"nik": "2"}';
            },
            child: Icon(Icons.edit),
          ),
        ],
      ),
    );
  }
}
