import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

class HomeController extends GetxController {
 var nfcData = 'Scan a NFC tag to write data'.obs;
  var messageToWrite = 'Hello, NFC!'.obs;

  @override
  void onInit() {
    super.onInit();
    startNfcSession();
  }

  void startNfcSession() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      String result;
      if (Ndef.from(tag) != null) {
        result = await writeNdef(tag);
      } else if (MifareClassic.from(tag) != null) {
        result = await writeMifareClassic(tag);
      } else if (NdefFormatable.from(tag) != null) {
        result = await formatAndWriteNdef(tag);
      } else {
        result = 'Unsupported tag technology';
      }
      nfcData.value = result;
      NfcManager.instance.stopSession();
    });
  }

  Future<String> writeNdef(NfcTag tag) async {
    try {
      Ndef? ndef = Ndef.from(tag);
      if (ndef == null || !ndef.isWritable) {
        return 'Tag is not NDEF writable';
      }
      NdefMessage message = NdefMessage([NdefRecord.createText(messageToWrite.value)]);
      await ndef.write(message);
      return 'NDEF data written successfully';
    } catch (e) {
      return 'Failed to write NDEF data: $e';
    }
  }

  Future<String> writeMifareClassic(NfcTag tag) async {
    try {
      MifareClassic? mifareClassic = MifareClassic.from(tag);
      if (mifareClassic == null) {
        return 'Tag is not MIFARE Classic';
      }

       Uint8List defaultKey = Uint8List.fromList([0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]);

      await mifareClassic.authenticateSectorWithKeyA(
        sectorIndex: 1,
        key: defaultKey,
      );



     
            // Konversi string pesan ke dalam bentuk byte
      Uint8List dataToWrite = Uint8List.fromList(
        messageToWrite.value.codeUnits,
      );

      // Periksa panjang data
      if (dataToWrite.length < 16) {
        // Jika panjang data kurang dari 16 byte, tambahkan padding
        Uint8List paddedData = Uint8List(16);
        paddedData.setRange(0, dataToWrite.length, dataToWrite);
        dataToWrite = paddedData;
      } else if (dataToWrite.length > 16) {
        // Jika panjang data lebih dari 16 byte, ambil hanya 16 byte pertama
        dataToWrite = dataToWrite.sublist(0, 16);
      }

      // Tulis data ke blok pada kartu MIFARE Classic
      await mifareClassic.writeBlock(
        blockIndex: 6,
        data: dataToWrite,
      );


      return 'MIFARE Classic data written successfully';
    } catch (e) {
      print("Failed to write MIFARE Classic data");
      print(e.toString());
      return 'Failed to write MIFARE Classic data: $e';
    }
  }

  void readNfcTag() async {
  try {
    // Pastikan NFC dinyalakan
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      // Tampilkan pesan bahwa NFC tidak tersedia
      return;
    }

    // Mulai sesi NFC untuk membaca tag
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        // Lakukan pembacaan tag NFC di sini
        String data = await readMifareClassic(tag);
        print('Data yang dibaca dari kartu MIFARE Classic: $data');
        // Tampilkan data yang dibaca ke pengguna, misalnya dengan menggunakan setState() jika Anda menggunakan StatefulWidget
      },
    );
  } catch (e) {
    print('Failed to start NFC session: $e');
  }
}



  Future<String> readMifareClassic(NfcTag tag) async {
  try {
    MifareClassic? mifareClassic = MifareClassic.from(tag);
    if (mifareClassic == null) {
      return 'Tag is not MIFARE Classic';
    }

    // Authenticate to the sector first
    Uint8List defaultKey = Uint8List.fromList([0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]);
    await mifareClassic.authenticateSectorWithKeyA(
      sectorIndex: 1,
      key: defaultKey,
    );

    // Read the data from the block
    Uint8List data = await mifareClassic.readBlock(blockIndex: 5);
    print(data);
    // Convert the data back to String
    String message = String.fromCharCodes(data);

    return message;
  } catch (e) {
    print("Failed to read MIFARE Classic data");
    print(e.toString());
    return 'Failed to read MIFARE Classic data: $e';
  }
}





  Future<String> formatAndWriteNdef(NfcTag tag) async {
    try {
      NdefFormatable? ndefFormatable = NdefFormatable.from(tag);
      if (ndefFormatable == null) {
        return 'Tag is not NDEF Formatable';
      }
      NdefMessage message = NdefMessage([NdefRecord.createText(messageToWrite.value)]);
      await ndefFormatable.format(message);
      return 'NDEF data formatted and written successfully';
    } catch (e) {
      return 'Failed to format and write NDEF data: $e';
    }
  }
}
