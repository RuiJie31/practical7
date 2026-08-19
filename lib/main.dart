import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MainPage());
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  //controller
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  Future getImageFromGallery() async{
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if(pickedFile != null){
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void>savePicture()async{
    if(_image != null){
      try{
        final appDocDir = await getApplicationCacheDirectory();
        final newImagePath ='${appDocDir.path}/profile.png';
        await _image!.copy(newImagePath);
        print('File image copied successfully to $newImagePath');
      }catch(e){
        print('File error copying image: $e');
      }
  }else{
      AlertDialog(
        title: const Text('Profile Image'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: [
              Text('Profile Image'),
              Text('Profile Image file is missing')
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: (){Navigator.pop(context);}, child: Text('Close'))
        ],
      );
    }
  }

  void _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final appDocDir = await getApplicationCacheDirectory();
    final imagePath = '${appDocDir.path}/profile.png';

    final file = File(imagePath);

    if(await file.exists()){
      setState(() {
        _image = file;
        print('File path: $imagePath');
      });
    }else{
      print('File no found in $imagePath');
    }

    nameCtrl.text = prefs.getString('name') ?? "";
    emailCtrl.text = prefs.getString('email') ?? "";
  }

  void _updateProfile() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('name', nameCtrl.text);
    prefs.setString('email', emailCtrl.text);
  }

  @override
  void initState() {
    // TODO: implement initState
    _loadProfile();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    nameCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              _image == null
                ? Icon(Icons.person,size: 150)
                : Image.file(_image!, width: 150, height: 150),
            SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: getImageFromGallery, child: Text('Edit')),
                ElevatedButton(
                    onPressed: (){savePicture();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile Picture saved!')));},
                    child: Text('Save'))
              ]),

              TextField(
                controller: nameCtrl,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                    labelText: 'Name'
                ),
              ),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    labelText: 'Email'
                ),
              ),
              Expanded(child: SizedBox()),
              ElevatedButton(
                  onPressed: _updateProfile, child: Text('Update'))
            ],
          ),
        ),
      ),
    );
  }
}
