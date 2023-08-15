
import 'package:adheos/globals.dart';
import 'package:flutter/material.dart';

class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home,color: Colors.white,),
          onPressed: () {
            // Handle home button press
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          appName,
          style: TextStyle(
            color: Color.fromRGBO(255, 255, 255, 1),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app,color: Colors.white,),
            onPressed: () {

            },
          ),
        ],
      ),
    );
  }
}
