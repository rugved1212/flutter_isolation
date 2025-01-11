import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class IsolateScreen extends StatefulWidget {
  const IsolateScreen({super.key});

  @override
  State<IsolateScreen> createState() => _IsolateScreenState();
}

class _IsolateScreenState extends State<IsolateScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random random = Random();

  double leftPosition = 0;
  double rightPosition = 0;
  double upPosition = 0;
  double downPosition = 0;

  double counterTimer = 0;

  int fibonacciSum = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        leftPosition = randomValueGenerator(
            (MediaQuery.of(context).size.width / 2).toInt());
        rightPosition = randomValueGenerator(
            (MediaQuery.of(context).size.width / 2).toInt());
        upPosition = randomValueGenerator(
            (MediaQuery.of(context).size.height / 2).toInt());
        downPosition = randomValueGenerator(
            (MediaQuery.of(context).size.height / 2).toInt());

        setState(() {});
      },
    );

    updateCounter();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double randomValueGenerator(int maxValue) {
    return random.nextInt(maxValue).toDouble();
  }

  void updateCounter() async {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 5));
      setState(() {
        counterTimer += 0.1;
      });
    }
  }

  // Isolated Function
  // The function that runs in isolate environment must be static, so it can use without create an instance of class.
  // This function acts as stream function where the data is emitted with delay of 100 milliseconds.
  static Future<void> fibonacciFuncOfIsolate(SendPort sendPort) async {
    int initialValue = 0;
    int secondValue = 1;
    int sum = 0;
    int maxSumValue = 0;

    while (maxSumValue < 100000000) {
      int thirdValue = initialValue + secondValue;
      sum += thirdValue;
      initialValue = secondValue;
      secondValue = thirdValue;
      maxSumValue++;
      sendPort.send(sum); // Send only the sum
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  // Normal Function
  // This function runs on our main thread which makes the UI stops until the function is fully executed.
  void fibonacciFuncWithoutIsolate() {
    int initialValue = 0;
    int secondValue = 1;
    int maxSumValue = 0;

    while (maxSumValue < 100000000) {
      int thirdValue = initialValue + secondValue;
      fibonacciSum += thirdValue;
      initialValue = secondValue;
      secondValue = thirdValue;
      maxSumValue++;
      debugPrint(fibonacciSum.toString());
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedPositioned(
            top: upPosition,
            bottom: downPosition,
            right: rightPosition,
            left: leftPosition,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              color: Colors.amber,
              duration: const Duration(milliseconds: 200),
            ),
          ),
          Center(
            child: Text(
              counterTimer.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    counterTimer = 0;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  "Reset Timer",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 200),
            child: Center(
              child: ElevatedButton(
                onPressed: () {

                  // This is isolate method.
                  // This prevent us from block the rest of the functions.

                  ReceivePort receivePort = ReceivePort();
                  Isolate.spawn(fibonacciFuncOfIsolate, receivePort.sendPort);

                  receivePort.listen((message) {
                    setState(() {
                      fibonacciSum = message;
                    });
                  });


                  // This is the normal method called without isolation.
                  // So, when we called this method our UI gets stucks.
                  // To, prevent the above cause we use Flutter Isolate.

                  // fibonacciFuncWithoutIsolate();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: Text(
                  fibonacciSum == 0 ? "Fibonacci Sum" : fibonacciSum.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
