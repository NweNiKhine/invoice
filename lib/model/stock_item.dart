class StockItem {
  String code;
  String description;
  int qty;
  double price;

  StockItem({
    required this.code,
    required this.description,
    required this.qty,
    required this.price,
  });

  double get amount => qty * price;

  Map<String, dynamic> toMap() => {
    'code': code,
    'description': description,
    'qty': qty,
    'price': price,
    'amount': amount,
  };
}
