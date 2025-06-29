import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main.dart';
import 'menu.dart';

class Cart extends StatefulWidget {
  final int? num;
  final int? quantity;

  /// key1: menu番号(0〜2)　key2: 人数(1〜5)
  const Cart({super.key, this.num, this.quantity});

  @override
  State<Cart> createState() => _Cart();
}

class _Cart extends State<Cart> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  Menu _menu = Menu(name: "", itemList: []);
  int _total = 0;

  @override
  void initState() async {
    super.initState();
    await setMenu(widget.num, widget.quantity);
  }

  Future<void> setMenu(int? num, int? quantity) async {
    num = num ?? 0;
    String data = await loadJsonAsset(num);
    _menu = convertJsonToMenu(data, quantity);
    _total = await sumMenu();
    setState(() {});
  }

  Menu convertJsonToMenu(String value, int? quantity) {
    quantity = quantity ?? 1;
    Map<String, dynamic> map = jsonDecode(value);
    Menu menu = Menu(name: map["name"], itemList: []);
    List<dynamic> list = map["itemList"];
    for (var item in list) {
      menu.itemList.add(
        Item(
          name: item["name"],
          price: item["price"],
          quantity: quantity,
          images: item["images"],
        ),
      );
    }
    return menu;
  }

  Future<int> sumMenu() async {
    List<int> sum = [];
    for (var item in _menu.itemList) {
      sum.add(item.price * item.quantity);
      sum.add(item.price * item.quantity);
    }
    return sum.reduce((a, b) => a + b);
  }

  Future<String> loadJsonAsset(int num) async {
    const menuNameList = [
      "curry-rice.json",
      "taco-rice.json",
      "cream-shoe.json",
    ];
    String data = await rootBundle.loadString(
      'assets/json/${menuNameList[num]}',
    );
    return data;
  }

  void _incrementCounter(Item item) {
    setState(() {
      int count = item.quantity;
      if (count < 5) {
        item.quantity++;
        _update();
      }
    });
  }

  void _decrementCounter(Item item) {
    setState(() {
      int count = item.quantity;
      if (count > 1) {
        item.quantity--;
        _update();
      }
    });
  }

  void _update() {
    _total = 0;
    for (var item in _menu.itemList) {
      _total += item.price * item.quantity;
    }
  }

  void _deleteItem(Item item) {
    int removeIndex = _menu.itemList.indexOf(item);
    Item removedItem = _menu.itemList.removeAt(removeIndex);

    builder(context, animation) {
      return _buildIemList(removedItem, animation);
    }

    _listKey.currentState?.removeItem(removeIndex, builder);
    setState(() {
      _update();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _appBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 10,
            child:
                _menu.itemList.isEmpty
                    ? EmptyCart()
                    : AnimatedList(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(20),
                      key: _listKey,
                      initialItemCount: _menu.itemList.length,
                      itemBuilder: (
                        BuildContext context,
                        int index,
                        Animation<double> animation,
                      ) {
                        return _buildIemList(_menu.itemList[index], animation);
                      },
                    ),
          ),
          bottomBarTitle(),
          bottomBarButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      title: Text(
        _menu.name,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      automaticallyImplyLeading: false,
      backgroundColor: Colors.grey[100],
      elevation: 0,
    );
  }

  Widget _buildIemList(Item item, Animation<double> animation) {
    return SizeTransition(sizeFactor: animation, child: menuItem(item));
  }

  Widget menuItem(Item item) {
    return Stack(
      children: [
        itemContainer(item),
        Positioned(
          top: 5,
          right: 7,
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.black87,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              iconSize: 16,
              splashRadius: 23,
              onPressed: () {
                _deleteItem(item);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget itemContainer(Item item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(13),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[300]?.withAlpha(153),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                "assets/images/${item.images}",
                width: 80,
                height: 130,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.23,
                  child: Text(
                    item.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                SizedBox(
                  child: Text(
                    ("${item.price}円"),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          quantityCount(item),
        ],
      ),
    );
  }

  Widget quantityCount(Item item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          IconButton(
            splashRadius: 10.0,
            onPressed: () {
              _decrementCounter(item);
            },
            icon: const Icon(Icons.remove, color: Color(0xFFEC6813)),
          ),
          Text(
            "${item.quantity}人前",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          IconButton(
            splashRadius: 10.0,
            onPressed: () {
              _incrementCounter(item);
            },
            icon: const Icon(Icons.add, color: Color(0xFFEC6813)),
          ),
        ],
      ),
    );
  }

  Widget bottomBarTitle() {
    return Expanded(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "合計",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Text(
                "$_total円",
                key: ValueKey<int>(_total),
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFEC6813),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomBarButton() {
    return Expanded(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: SizedBox(
                      child: Padding(
                        padding: EdgeInsets.only(top: 30, bottom: 10),
                        child: Text("注文を確定しますか？"),
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('いいえ'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('はい'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyHomePage(flag: true),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text("注文"),
          ),
        ),
      ),
    );
  }
}

class EmptyCart extends StatelessWidget {
  const EmptyCart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/images/empty-cart.png', fit: BoxFit.contain),
        const SizedBox(height: 30),
        const Text(
          "カートが空です。",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ],
    );
  }
}
