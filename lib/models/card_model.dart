// 🃏 Lớp mô hình của thẻ bài trong trò chơi
class CardModel {
  // 🔹 Mỗi thẻ bài có một mã định danh duy nhất
  final int id;

  // 🔹 Đường dẫn đến hình ảnh đại diện cho thẻ
  final String imagePath;

  // 🔹 Biến đánh dấu thẻ này có phải là "boom" (bom) hay không
  final bool isBoom;

  // 🔹 Trạng thái lật (true = đang hiển thị, false = đang úp)
  bool isFlipped;

  // 🔹 Trạng thái khớp (true = đã ghép đôi thành công)
  bool isMatched;

  // 🔹 Tọa độ x, y của thẻ trên màn hình (phục vụ di chuyển hoặc hiệu ứng)
  double x;
  double y;

  // 🧩 Hàm khởi tạo (constructor)
  CardModel({
    required this.id,
    required this.imagePath,
    this.isBoom = false,     // mặc định không phải bom
    this.isFlipped = false,  // mặc định chưa lật
    this.isMatched = false,  // mặc định chưa ghép
    this.x = 0,              // mặc định vị trí gốc
    this.y = 0,
  });

  // 🔄 Lật hoặc úp thẻ
  void flip() => isFlipped = !isFlipped;

  // ✅ Đánh dấu thẻ đã được ghép đôi
  void match() => isMatched = true;

  // 💣 Hàm tạo nhanh một thẻ "bom"
  factory CardModel.boom() {
    return CardModel(
      id: -1, // id đặc biệt cho thẻ bom
      imagePath: 'assets/cards/boom.png', // ảnh bom
      isBoom: true, // đánh dấu là bom
    );
  }
}
