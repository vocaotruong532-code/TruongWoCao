class CardModel {// mô hình của các the bài trong trò chơi
  final int id;
  final String imagePath;
  final bool isBoom;
  bool isFlipped;
  bool isMatched;

  // 👉 Thêm tọa độ để di chuyển
  double x;
  double y;
//các thuộc tính của thẻ bài
  CardModel({
    required this.id,
    required this.imagePath,
    this.isBoom = false,
    this.isFlipped = false,
    this.isMatched = false,
    this.x = 0,
    this.y = 0,
  });

  void flip() => isFlipped = !isFlipped;

  void match() => isMatched = true;

  factory CardModel.boom() {
    return CardModel(
      id: -1,
      imagePath: 'assets/cards/boom.png', // 🧨 ảnh riêng cho boom
      isBoom: true,
    );
  }
}
