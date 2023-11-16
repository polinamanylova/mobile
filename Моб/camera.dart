import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_application_1/api/geolocate.dart';
import 'package:path_provider/path_provider.dart';

bool orietntationIsPortrait(MagnetometerEvent event) {
  return event.x.abs() + event.z.abs() <= 50;
}



class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, required this.camera});

  final CameraDescription camera;

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool isPortrait = true;
  String isPortraitText = 'Портретная';
  late GyroscopeEvent gyroscopeEvent;
  int _selectedIndex = 0;
    int currentPageIndex = 0;


  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        gyroscopeEvent = event;
      });
    });
    magnetometerEvents.listen((MagnetometerEvent event) {
      setState(() {
        isPortrait = orietntationIsPortrait(event);
        isPortraitText = isPortrait ? 'Портретная' : 'Альбомная';
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('фото')),
      bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.gps_fixed),
              label: 'GPS',
              
            ),
            NavigationDestination(
              icon: Icon(Icons.accessible_forward_sharp),
              label: 'Gyroscope',
            ),
            NavigationDestination(
              icon: Icon(Icons.assist_walker),
              label: 'in future',
            ),
          ],
        ),
      body:
      <Widget>[
          Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[FutureBuilder(
      future: getadress("sdfasf"),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          return Text(snapshot.data.toString());
        }
        return CircularProgressIndicator();
      },),
          ],
        ),
      ),
          Center(
            

            child: StreamBuilder<GyroscopeEvent>(
              stream: gyroscopeEvents,
              builder: (context, snapshot) {
                return Text("x = ${snapshot.data!.x.toStringAsFixed(3)}\n y = ${snapshot.data!.y.toStringAsFixed(3)} \n z=${snapshot.data!.z.toStringAsFixed(3)} ");
              }
            ),



          ),
       Center(
          child: Stack(children: [
        FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(_controller);
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              )
            ,
        Column(
          children: [
            Text('гироскоп:'),
            Text('X ${gyroscopeEvent.x.toStringAsFixed(2)}'),
            Text('Y ${gyroscopeEvent.y.toStringAsFixed(2)}'),
            Text('Z ${gyroscopeEvent.z.toStringAsFixed(2)}'),
            
          ],
        )
      ])),][currentPageIndex],
      floatingActionButton: StreamBuilder<MagnetometerEvent>(
        stream: magnetometerEvents,
        builder: (context, snapshot) {
          if (isPortrait){
               
          return FloatingActionButton(
            child: const Icon( Icons.camera_alt),
            onPressed: () async {
    // Take the Picture in a try / catch block. If anything goes wrong,
    // catch the error.
    
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;
      print(Directory.current.path);
      final image = await _controller.takePicture();
      getExternalStorageDirectory().then((dir) {
        
      //final Directory tempDir = await getApplicationDocumentsDirectory();
      image.saveTo("${dir?.path}/pic.jpg");
      });
      // Attempt to take a picture and then get the location
      // where the image file is saved.
    
  },
          );
          } 
          else{
            return FloatingActionButton(
            child: const Icon( Icons.dangerous_rounded ),
            onPressed: () {},
          );
          }
        }
      ),
    );
  }
}
