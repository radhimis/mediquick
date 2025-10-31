import 'package:flutter/material.dart';
import '../doctor/doctor_flow_screen.dart';

const kPrimaryBlue = Color(0xFF0017A8);
const kLightBlue = Color(0xFFCCD2FF);

class FastDeliveryScreen extends StatelessWidget {
  const FastDeliveryScreen({Key? key}) : super(key: key);

  void _goBack(BuildContext context) {
    Navigator.pop(context);
  }

  void _finish(BuildContext context) {
    // Navigate directly to Doctor App
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DoctorFlowScreen()),
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
              'assets/man_illustration2.jpg',
              width: 250,
              height: 210,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            const Text(
              "Fast delivery\nin 10 minutes.",
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
                "We will deliver your medicines quickly. Couriers use protective equipment.",
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
                    onPressed: () => _goBack(context),
                    child: const Text(
                      "Back",
                      style: TextStyle(
                        color: kPrimaryBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Row(
                    children: const [
                      DotIndicator(),
                      DotIndicator(),
                      DotIndicator(isActive: true),
                    ],
                  ),
                  TextButton(
                    onPressed: () => _finish(context),
                    child: const Text(
                      "Finish",
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
