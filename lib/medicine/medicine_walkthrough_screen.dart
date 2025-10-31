import 'package:flutter/material.dart';
import 'medicine_walkthrough_screen1.dart';

const kPrimaryBlue = Color(0xFF0017A8);
const kLightBlue = Color(0xFFCCD2FF);

class MedicineWalkthroughScreen extends StatelessWidget {
  const MedicineWalkthroughScreen({Key? key}) : super(key: key);

  void _goToNext(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MedicineWalkthroughScreen1()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Image.asset(
              'assets/man_illustration.jpg',
              width: 250,
              height: 210,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            const Text(
              "Buy medicines\nonline",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                "Choose and purchase the necessary medications without visiting the pharmacy.",
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => _goToNext(context),
                    child: const Text(
                      "Skip",
                      style: TextStyle(
                        color: kPrimaryBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Row(
                    children: const [
                      DotIndicator(isActive: true),
                      DotIndicator(),
                      DotIndicator(),
                    ],
                  ),
                  TextButton(
                    onPressed: () => _goToNext(context),
                    child: const Text(
                      "Next",
                      style: TextStyle(
                        color: kPrimaryBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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

class DotIndicator extends StatelessWidget {
  final bool isActive;
  const DotIndicator({this.isActive = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: isActive ? 10 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? kPrimaryBlue : kLightBlue,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
