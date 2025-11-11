import 'package:flutter/material.dart';
import 'components/page_header.dart';

class AgeOfGoldHome extends StatefulWidget {
  const AgeOfGoldHome({super.key});

  @override
  State<AgeOfGoldHome> createState() => _AgeOfGoldHomeState();
}

class _AgeOfGoldHomeState extends State<AgeOfGoldHome> {

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffEEF1F3),
        body: SingleChildScrollView(
            child: Column(
              children: [
                const PageHeader(),
                Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20),),
                    ),
                    child: Container()
                ),
              ],
            )
        ),
      ),
    );
  }
}
