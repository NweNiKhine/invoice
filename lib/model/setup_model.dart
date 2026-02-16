class StockMaster {
  String code;
  String description;
  double? salePrice;

  StockMaster({
    required this.code,
    required this.description,
    this.salePrice,
  });

  Map<String, dynamic> toMap() => {
    'code': code,
    'description': description,
    'saleprice': salePrice,
  };
}

class PurchaseItem {
  String code;
  int qty;
  double price;
  String description;

  PurchaseItem({
    required this.code,
    required this.qty,
    required this.price,
    required this.description,
  });

  double get amount => qty * price;

  Map<String, dynamic> toMap() => {
    'code': code,
    'qty': qty,
    'price': price,
    'amount': amount,
  };
}
