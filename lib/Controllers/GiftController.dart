import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import '../Models/Authentication.dart';
import '../Models/Database.dart';
import '../Models/Event.dart';
import '../Models/Friend.dart';
import '../Models/Gift.dart';
import '../Views/GiftDetails.dart';
import '../Views/GiftList.dart';

class GiftController{
  bool isOnline=false;
  final Databaseclass db = Databaseclass();
  final databaseRef = FirebaseDatabase.instance.ref();
  final AuthService auth = AuthService();
  late StreamSubscription<DatabaseEvent> _giftsSubscription;

  fetchGiftsFromLocalDb(int eventid) async {
    Event? e = await Event.getEventById(eventid);
    return e;
  }

  OnGiftCardTap(bool isOwner, BuildContext context, Gift gift,
      String isPledged, Friend User, int eventid) async {
    if (isOwner) {
      print("okash");
      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => GiftDetails(
            gift: gift,
            isOwner: isOwner,
            isPledged: gift.status == "Pledged" ? true : false,
            isPledger: false,
            User: User,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Start position: to the right
            const end = Offset.zero; // End position: original position
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      );
    } else {
      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => GiftDetails(
            gift: gift,
            isOwner: isOwner,
            isPledged: gift.status == "Pledged" ? true : false,
            isPledger: (gift.PledgerID == User.id) ? true : false,
            User: User,
          ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0); // Start position: to the right
              const end = Offset.zero; // End position: original position
              const curve = Curves.easeInOut;

              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
        ),
      );
    }

    return await Event.getEventById(eventid);
  }

  syncGiftsTableToFirebase()async{
    await db.syncGiftsTableToFirebase();
  }
  OnSaveGiftPressed(File? imageFile,String? encodedImage,Gift? gift,Event event,
      TextEditingController nameController,TextEditingController categoryController,
      TextEditingController descriptionController,
      TextEditingController priceController,String status,BuildContext context)async{
    // Check if an image is selected and encode it
    if (imageFile != null) {
      final imageBytes = await File(imageFile!.path).readAsBytes();
      encodedImage = base64Encode(imageBytes);
    }

    if (gift == null) {
      // Adding a new gift
      event.giftlist!.add(Gift(
        name: nameController.text,
        category: categoryController.text,
        status: status,
        description: descriptionController.text,
        price: int.tryParse(priceController.text) ?? 0,
        image: encodedImage ?? '',
        eventId: event.id,
      ));

      bool addGift = await Gift.addGift(Gift(
        name: nameController.text,
        category: categoryController.text,
        status: status,
        description: descriptionController.text,
        price: int.tryParse(priceController.text) ?? 0,
        image: encodedImage ?? '',
        eventId: event.id,
      ));


      showCustomSnackBar(context, "Gift Added Successfully", backgroundColor: Colors.green);
    } else {
      // Editing an existing gift
      gift.name = nameController.text;
      gift.category = categoryController.text;
      gift.status = status;
      gift.description = descriptionController.text;
      gift.price = int.tryParse(priceController.text) ?? gift.price;
      gift.image = encodedImage ?? gift.image;

      bool updateStatus = await Gift.updateGift(gift);


      showCustomSnackBar(context, "Gift Updated Successfully", backgroundColor: Colors.green);
    }
   event.giftlist = await Gift.getGiftList(event.id!);
    await db.syncGiftsTableToFirebase();
    return event;



    Navigator.of(context).pop();

  }

  DeleteGift(Gift gift,int eventid)async{
    bool delgift = await Gift.DeleteGift(gift.id!);
    await db.syncGiftsDeletionToFirebase(gift.id!);
    return await Gift.getGiftList(eventid);
  }
  FetchGiftByID(int giftid)async{
    return await Gift.getGiftById(giftid);
  }
  UpdateGift(Gift gift)async{
    return await Gift.updateGift(gift);
  }
  BackToGiftList(int eventid)async{
    return await Gift.getGiftList(eventid);
  }

  ScanBarcode(BuildContext context,int eventid)async{

    String? res = await SimpleBarcodeScanner.scanBarcode(
      context,
      barcodeAppBar:  BarcodeAppBar(
        appBarTitle: 'Test',
        centerTitle: false,
        enableBackButton: true,
        backButtonIcon: Icon(Icons.arrow_back_ios),
      ),
      isShowFlashIcon: true,
      delayMillis: 500,
      cameraFace: CameraFace.back,
      scanFormat: ScanFormat.ONLY_BARCODE,
    );
    if(await Gift.CheckBarcode(res as String)){
      Gift gift = await Gift.CreateGiftByBarcode(res as String,eventid);
      bool addGift = await Gift.addGift(gift);
      return await Gift.getGiftList(eventid);
    }
    else{
      showCustomSnackBar(context, "Barcode Number: ${res as String}",backgroundColor: Colors.green);
    }
  }
  void showCustomSnackBar(BuildContext context, String message, {Color backgroundColor = Colors.red}) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.white,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  PledgedButtonPressed(int eventid,BuildContext context)async {
    Event? e = await Event.getEventById(eventid);
    await db.syncGiftsTableToFirebase();
    return e!;
  }




}