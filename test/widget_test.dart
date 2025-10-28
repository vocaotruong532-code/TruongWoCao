
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/menu_screen.dart'; 

void main() {
  testWidgets('Ứng dụng khởi chạy và hiển thị MenuScreen',
      (WidgetTester tester) async {
    // Khởi tạo app
    await tester.pumpWidget(const MemoryCardFlipApp());

    // Kiểm tra xem có chữ "Bậc Thầy Trí Nhớ" (title) hay không
    expect(find.text('Bậc Thầy Trí Nhớ'), findsOneWidget);

    // Kiểm tra MenuScreen được hiển thị
    expect(find.byType(MenuScreen), findsOneWidget);
  });
}
