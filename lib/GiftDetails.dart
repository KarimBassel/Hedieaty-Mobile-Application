import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'GiftList.dart';
import 'Base Classes/Gift.dart';
import 'Base Classes/Friend.dart';
import 'Base Classes/Event.dart';
bool flag = false;

class GiftDetails extends StatefulWidget {
  bool isOwner;
  bool isPledged;
  bool isPledger;//this boolean tells if this gift is pledged by User or not to grant him the cancel pledge option
  Friend? User;
  final Gift gift;

  GiftDetails({super.key,required this.isOwner,required this.isPledged, required this.gift,required this.isPledger,this.User});

  @override
  _GiftDetailsState createState() => _GiftDetailsState();
}

class _GiftDetailsState extends State<GiftDetails> {
  File? _image;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.gift.name;
    _descriptionController.text = widget.gift.description;
    _categoryController.text = widget.gift.category;
    _priceController.text = widget.gift.price.toString();
    _statusController.text = widget.isPledged ? 'Pledged' : 'Available';
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final imageBytes = await File(pickedImage.path).readAsBytes();
      String encodedImage = base64Encode(imageBytes);
      widget.gift.image=encodedImage;
      bool updatestatus = await Gift.updateGift(widget.gift);
      setState(() {

      });
    }
  }

  void _togglePledge() async{
    if (widget.gift.status == "Available") {
      widget.gift.status = "Pledged";
      _statusController.text = "Pledged";
      widget.isPledged = true;
      widget.isPledger=true;
      widget.gift.PledgerID = widget.User!.id;
      bool updatestatus = await Gift.updateGift(widget.gift);

    } else {
      widget.gift.status = "Available";
      _statusController.text = "Available";
      widget.isPledged = false;
      widget.isPledger=false;
      widget.gift.PledgerID = -1;
      bool updatestatus = await Gift.updateGift(widget.gift);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: ()async{
          List<Gift> updatedlist = await Gift.getGiftList(widget.gift.eventId!);
          Navigator.pop(context,updatedlist);
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
          // if (widget.isOwner && !widget.isPledged)
          //   IconButton(
          //     icon: Icon(Icons.camera_alt),
          //     onPressed: _pickImage,
          //     iconSize: 30,
          //   ),
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
                    onPressed: ()async{
                      _togglePledge();
                      Event? e = await Event.getEventById(widget.gift.eventId!);
                      Navigator.of(context)
                        ..pop()
                        ..pop();

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GiftListPage(event: e!, isOwner: widget.isOwner, User: widget.User!)),
                      );
                      setState(() {

                      });
                    },
                    child: Text(
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
