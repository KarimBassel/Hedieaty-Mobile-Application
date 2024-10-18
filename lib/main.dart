import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyanAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            FloatingActionButton.extended(onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  GiftDetails()));
            }, label: Text("Gift Details Page")),
            FloatingActionButton.extended(onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  Home()));
            }, label: Text("Homepage")),

            FloatingActionButton.extended(onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  Profile()));
            }, label: Text("Profile")),
          ],
        ),
      ),

    );
  }
}



class GiftDetails extends StatefulWidget {
  bool isOwner;
  bool isPledged;
  GiftDetails({super.key, this.isOwner = true,this.isPledged=false});

  @override
  _GiftDetailsState createState() => _GiftDetailsState();
}

class _GiftDetailsState extends State<GiftDetails> {
  File? _image;
  final TextEditingController _nameController = TextEditingController(text: 'iPhone 15');
  final TextEditingController _descriptionController = TextEditingController(text:
  'The iPhone 15 has a 6.1-inch display, 48MP main camera, A16 Bionic chip, and USB-C port. It supports Dynamic Island, runs iOS 17, and starts at 799.');
  final TextEditingController _categoryController = TextEditingController(text: 'Electronics');
  final TextEditingController _priceController = TextEditingController(text: '1200');


  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
        print(pickedImage.path);
      });
    }
  }

  void _editField(String field, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter $field"),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  //to update controller.text
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(
          child: Text(
            "Gift Details",
            style: TextStyle(fontSize: 30),
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
                  // Avatar
                  CircleAvatar(
                    radius: 150,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : NetworkImage(
                        'https://shop.switch.com.my/cdn/shop/files/iPhone_15_Pink_PDP_Image_Position-1__GBEN_7cf60425-0d5a-4bc9-bfd9-645b9c86e68e.jpg?v=1717694179&width=823')
                    as ImageProvider,
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

                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[900],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  _nameController.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blueGrey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.isOwner && !widget.isPledged)
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _editField('Name', _nameController);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),


                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[900],
                                ),
                              ),
                              if (widget.isOwner && !widget.isPledged)
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _editField('Description', _descriptionController);
                                  },
                                ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            _descriptionController.text,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blueGrey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Category',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey[900],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        _categoryController.text,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.blueGrey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (widget.isOwner && !widget.isPledged)
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      _editField('Category', _categoryController);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Price',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey[900],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        _priceController.text,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.blueGrey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (widget.isOwner && !widget.isPledged)
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      _editField('Price', _priceController);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // Buttons Row
                  if(!widget.isOwner && !widget.isPledged)
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
}




class FriendsCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String eventStatus;

  const FriendsCard({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.eventStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundImage: NetworkImage(imageUrl),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    eventStatus,
                    style: TextStyle(
                        color: Colors.red, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>{
  final List<Map<String, String>> friends = [
    {
      'imageUrl':
      'https://img.freepik.com/free-photo/portrait-white-man-isolated_53876-40306.jpg?w=900&t=st=1729004634~exp=1729005234~hmac=cb0fb1a6e2dd8ce69411b07aecac4347fa1bad93feb2cbbe5070ef06955202d8',
      'name': 'Cristiano Ronaldo',
      'eventStatus': 'Upcoming Events: 2',
    },
    {
      'imageUrl':
      'https://img.freepik.com/premium-psd/man-with-beard-mustache-stands-front-white-background_1233986-1241.jpg',
      'name': 'Leonel Messi',
      'eventStatus': 'No Upcoming Events',
    },
    {
      'imageUrl':
      'https://img.freepik.com/free-photo/headshot-attractive-man-smiling-pleased-looking-intrigued-standing-blue-background_1258-65733.jpg?w=1060&t=st=1729004724~exp=1729005324~hmac=d4b3ea4ca32703e4beceb1d315a56d3d817890879c6cb523591fa770fde90195',
      'name': 'Mohamed Salah',
      'eventStatus': 'Upcoming Events: 1',
    },
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(
          child: Text(
            "Homepage",
            style: TextStyle(fontSize: 30),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  SearchBar(
                    padding: const MaterialStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 16.0)),
                    leading: const Icon(Icons.search),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan, // Button background color

                        padding: EdgeInsets.symmetric(vertical: 15), // Button padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        "Create your own Event/List",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Dynamic Card Generation
                  ...friends.map((friend) => Column(
                    children: [
                      FriendsCard(
                        imageUrl: friend['imageUrl']!,
                        name: friend['name']!,
                        eventStatus: friend['eventStatus']!,
                      ),
                      SizedBox(height: 10),
                    ],
                  )),

                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {

            friends.add({
              'imageUrl':
              'https://img.freepik.com/premium-psd/man-with-beard-mustache-stands-front-white-background_1233986-1241.jpg',
              'name': 'New Friend',
              'eventStatus': 'Upcoming Events: 0',
            });

          });

        },
        tooltip: 'Add Friend',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Profile extends StatefulWidget{
  @override
  _ProfileState createState() => _ProfileState();
}
class _ProfileState extends State<Profile>{
  File? _image;
  TextEditingController _nameController = TextEditingController(text: "Cristiano Ronaldo");
  TextEditingController _emailController = TextEditingController(text: "Cristiano@eng.asu.edu.eg");
  TextEditingController _preferencesController = TextEditingController(text : "Electronics, Sports");

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();

    final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image =
            File(pickedImage.path);
      });
    }
  }

  Widget _buildEditIcon(String label, TextEditingController controller) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        _editField(label, controller);
      },
    );
  }

  void _editField(String field, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter $field"),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {

                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(
          child: Text(
            "User Details",
            style: TextStyle(fontSize: 30),
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
                  // Avatar
                  CircleAvatar(
                    radius: 150,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : NetworkImage(
                      'https://img.freepik.com/free-photo/portrait-white-man-isolated_53876-40306.jpg?w=900&t=st=1729004634~exp=1729005234~hmac=cb0fb1a6e2dd8ce69411b07aecac4347fa1bad93feb2cbbe5070ef06955202d8',
                    ) as ImageProvider,
                  ),
                  IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: _pickImage,
                  color: Colors.blue,
                  iconSize: 30,
                  ),

                  SizedBox(height: 10),

                  // Name Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[900],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  _nameController.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blueGrey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildEditIcon('Name', _nameController),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Email Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[900],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  _emailController.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blueGrey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildEditIcon('Email', _emailController),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Preferences Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Preferences',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[900],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  _preferencesController.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blueGrey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildEditIcon('Preferences', _preferencesController),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,

                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        "Go to Events List",
                        style: TextStyle(
                          fontSize: 18, // Font size
                          fontWeight: FontWeight.bold, // Bold text
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan, // Button background color

                        padding: EdgeInsets.symmetric(vertical: 15), // Button padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        "My Pledged Gifts",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

