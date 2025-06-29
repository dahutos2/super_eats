import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'cart.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 画面の向きを固定
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Super Eats',
      theme: ThemeData(primarySwatch: Colors.red),
      home: MyHomePage(flag: false),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final bool flag;
  const MyHomePage({super.key, required this.flag});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> menuList = ["カレーライス", "タコライス", "クリームシチュー"];
  int _quantity = 1;
  int _num = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      if (widget.flag && mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: SizedBox(
                child: Padding(
                  padding: EdgeInsets.only(top: 30, bottom: 10),
                  child: Text("注文を完了しました。"),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('はい'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  void _incrementCounter() {
    setState(() {
      if (_quantity < 5) {
        _quantity++;
      }
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
      }
    });
  }

  void _randomSet() {
    setState(() {
      _num = Random().nextInt(3);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("本日発送は15時まで"),
        backgroundColor: Color.fromRGBO(0xE6, 0x13, 0x10, 1.0),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [quantityCount(), SizedBox(height: 50), gachaButton(context)],
      ),
    );
  }

  Widget quantityCount() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            splashRadius: 10.0,
            onPressed: () {
              _decrementCounter();
            },
            icon: const Icon(Icons.remove, color: Color(0xFFEC6813)),
          ),
          Text(
            "$_quantity人前",
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
          ),
          IconButton(
            splashRadius: 10.0,
            onPressed: () {
              _incrementCounter();
            },
            icon: const Icon(Icons.add, color: Color(0xFFEC6813)),
          ),
        ],
      ),
    );
  }

  Widget gachaButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _randomSet();
        screenTransitionAnimation(context, 'assets/json/gacha-dora05.json', () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: SizedBox(
                  child: Padding(
                    padding: EdgeInsets.only(top: 30, bottom: 10),
                    child: Text("${menuList[_num]}の注文を確定しますか？"),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('いいえ'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      screenTransitionAnimation(
                        context,
                        'assets/json/dragon-fire02.json',
                        () {},
                      );
                    },
                  ),
                  TextButton(
                    child: const Text('はい'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => Cart(num: _num, quantity: _quantity),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        });
      },
      // 対象の画像を記述
      child: Image.asset('assets/images/button-start1.png'),
    );
  }
}

void screenTransitionAnimation(
  BuildContext context,
  String lottieName,
  Function screenTransFunc,
) {
  showDialog(
    context: context,
    builder: (context) {
      return _LottieAnimation(
        onAnimeCompleted: () {
          screenTransFunc();
        },
        lottieName: lottieName,
      );
    },
  );
}

class _LottieAnimation extends StatefulWidget {
  const _LottieAnimation({
    required this.onAnimeCompleted,
    required this.lottieName,
  });
  final Function onAnimeCompleted;
  final String lottieName;

  @override
  State<_LottieAnimation> createState() => _LottieAnimationState();
}

class _LottieAnimationState extends State<_LottieAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final String lottieName;

  @override
  void initState() {
    super.initState();
    lottieName = widget.lottieName;
    _controller = AnimationController(vsync: this)..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pop();
        widget.onAnimeCompleted();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      lottieName,
      controller: _controller,
      onLoaded: (composition) {
        setState(() {
          _controller.duration = composition.duration;
        });
        _controller.forward();
      },
    );
  }
}
