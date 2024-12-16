import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hedieatymobileapplication/Controllers/GiftController.dart';
import 'package:hedieatymobileapplication/Models/Database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'GiftList.dart';
import '../Models/Gift.dart';
import '../Models/Friend.dart';
import '../Models/Event.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
bool flag = false;

class GiftDetails extends StatefulWidget {
  bool isOwner;
  bool isPledged;
  bool isPledger;//this boolean tells if this gift is pledged by User or not to grant him the cancel pledge option
  Friend? User;
   Gift gift;

  GiftDetails({super.key,required this.isOwner,required this.isPledged, required this.gift,required this.isPledger,this.User});

  @override
  _GiftDetailsState createState() => _GiftDetailsState();
}

class _GiftDetailsState extends State<GiftDetails> {
  final GiftController controller = GiftController();
  late StreamSubscription<DatabaseEvent> _giftsSubscription;
  late StreamSubscription<List<ConnectivityResult>> subscription ;
  File? _image;
  bool isloading=false;
  bool isOnline=false;
  bool onflag=false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  //real-time sync & updating class attributtes
  Future<void> fetchGiftFromLocalDb() async{

    await Future.delayed(const Duration(seconds: 1));
    Gift? g = await controller.FetchGiftByID(widget.gift.id!);
    widget.gift=g!;
    widget.isPledged = (widget.gift.status=="Available")?false:true;
    widget.isPledger = (widget.gift.PledgerID==widget.User!.id);
    _statusController.text = widget.isPledged ? 'Pledged' : 'Available';

  }


  @override
  void initState() {
    super.initState();
    subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      // Received changes in available connectivity types!
      if (result.contains(ConnectivityResult.mobile) || result.contains(ConnectivityResult.wifi)) {
        isOnline=true;
        if(onflag)controller.showCustomSnackBar(context, "Connection Restored!",backgroundColor: Colors.green);
        if(mounted)setState(() {

        });
      }
      else{
        isOnline=false;
        if(onflag)controller.showCustomSnackBar(context, "Connection Lost!");
        if(mounted)setState(() {

        });
      }
      onflag=true;
    });

    //for real-time sync
    final DatabaseReference _giftsRef = FirebaseDatabase.instance.ref('Gifts/${widget.gift.id}');
    _giftsSubscription=_giftsRef.onValue.listen((event) async {
      if (event.snapshot.exists) {
        await fetchGiftFromLocalDb();
      }
    });


    _nameController.text = widget.gift.name;
    _descriptionController.text = widget.gift.description;
    _categoryController.text = widget.gift.category;
    _priceController.text = widget.gift.price.toString();
    _statusController.text = widget.isPledged ? 'Pledged' : 'Available';
  }
  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    _giftsSubscription.cancel();
    subscription.cancel();
    super.dispose();
  }

  void _togglePledge() async{
    if (widget.gift.status == "Available") {
      widget.gift.status = "Pledged";
      _statusController.text = "Pledged";
      widget.isPledged = true;
      widget.isPledger=true;
      widget.gift.PledgerID = widget.User!.id;
      bool updatestatus = await controller.UpdateGift(widget.gift);

    } else {
      widget.gift.status = "Available";
      _statusController.text = "Available";
      widget.isPledged = false;
      widget.isPledger=false;
      widget.gift.PledgerID = -1;
      bool updatestatus = await controller.UpdateGift(widget.gift);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: ()async{
          List<Gift> updatedlist = await controller.BackToGiftList(widget.gift.eventId!);
          Navigator.pop(context);
          // Event? e = await Event.getEventById(widget.gift.eventId!);
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> GiftListPage(event: e!, isOwner: widget.isOwner, User: widget.User!)));
        }, icon: Icon(Icons.arrow_back)),
        title: Center(
          child: Text(
            "Gift Details",
            style: TextStyle(fontSize: 25),
          ),
        ),
      ),
      body: ListView(
        key: Key('GiftDetailsListView'),
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            width: 250,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: widget.gift.image != null
                    ? MemoryImage(base64Decode(widget.gift.image!.split(',').last))
                    : NetworkImage(
                  'https://shop.switch.com.my/cdn/shop/files/iPhone_15_Pink_PDP_Image_Position-1__GBEN_7cf60425-0d5a-4bc9-bfd9-645b9c86e68e.jpg?v=1717694179&width=823',
                ) as ImageProvider,
                fit: BoxFit.fill,
              ),
            ),
          ),

          SizedBox(height: 10),
          Center(
            child: Text(
              _statusController.text,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: widget.isPledged ? Colors.red : Colors.green,
              ),
            ),
          ),
          SizedBox(height: 10),

          _buildEditableField("Name", _nameController),
          SizedBox(height: 10),

          _buildEditableField("Description", _descriptionController),
          SizedBox(height: 10),

          _buildEditableField("Category", _categoryController),
          SizedBox(height: 10),

          _buildEditableField("Price", _priceController),
          SizedBox(height: 10),

          if ((!widget.isOwner && widget.isPledger) || (!widget.isOwner && !widget.isPledged))
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    key: Key('PledgeButton'),
                    onPressed: isloading ? null :  ()async{
                      if(isOnline) {
                        isloading = true;
                        setState(() {});
                        _togglePledge();
                        Event? e = await controller.PledgedButtonPressed(widget
                            .gift.eventId!, context);
                        Navigator.of(context)
                          ..pop()..pop();

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              GiftListPage(event: e!,
                                  isOwner: widget.isOwner,
                                  User: widget.User!)),
                        );
                        //update firebase gifts with the new info
                        await controller.SyncGiftsTabletoFirebase();
                      }
                      else{
                        controller.showCustomSnackBar(context, "No Internet Connection!");
                      }
                    },
                    child: isloading?CircularProgressIndicator(color: Colors.white,):Text(
                      widget.gift.status == "Available" ? "Pledge" : "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20),
                      backgroundColor: widget.gift.status == "Available" ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[900],
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: controller,
              enabled: widget.isOwner && !widget.isPledged,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter $label',
              ),
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueGrey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
