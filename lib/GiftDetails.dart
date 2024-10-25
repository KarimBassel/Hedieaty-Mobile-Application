import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'GiftList.dart';
import 'Gift.dart';

class GiftDetails extends StatefulWidget {
  bool isOwner;
  bool isPledged;
  final Gift gift;

  GiftDetails({super.key, this.isOwner = false, this.isPledged = true, required this.gift});

  @override
  _GiftDetailsState createState() => _GiftDetailsState();
}

class _GiftDetailsState extends State<GiftDetails> {
  File? _image;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with gift details
    _nameController.text = widget.gift.name;
    _descriptionController.text = widget.gift.description;
    _categoryController.text = widget.gift.category;
    _priceController.text = widget.gift.price.toString();
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(
          child: Text(
            "Gift Details",
            style: TextStyle(fontSize: 25),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    width: 250,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: widget.gift.image != null
                            ? FileImage(widget.gift.image!)
                            : NetworkImage(
                          'https://shop.switch.com.my/cdn/shop/files/iPhone_15_Pink_PDP_Image_Position-1__GBEN_7cf60425-0d5a-4bc9-bfd9-645b9c86e68e.jpg?v=1717694179&width=823',
                        ) as ImageProvider,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  if (widget.isOwner && !widget.isPledged)
                    IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: _pickImage,
                      color: Colors.blue,
                      iconSize: 30,
                    ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      widget.isPledged ? 'Pledged' : 'Available',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: widget.isPledged ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Editable Name Field
                  _buildEditableField("Name", _nameController),
                  SizedBox(height: 10),

                  // Editable Description Field
                  _buildEditableField("Description", _descriptionController),
                  SizedBox(height: 10),

                  // Editable Category Field
                  _buildEditableField("Category", _categoryController),
                  SizedBox(height: 10),

                  // Editable Price Field
                  _buildEditableField("Price", _priceController),

                  SizedBox(height: 10),

                  if (!widget.isOwner && !widget.isPledged)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text(
                              "Pledge",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 20),
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 20),
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
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
