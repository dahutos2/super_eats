class Item {
  String name;
  int price;
  int quantity;
  String images;

  Item({
    required this.name,
    required this.price,
    required this.quantity,
    required this.images,
  });
}

class Menu {
  String name;
  List<Item> itemList;

  Menu({
    required this.name,
    required this.itemList,
  });
}
