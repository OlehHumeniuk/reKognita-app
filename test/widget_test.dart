import 'package:flutter_test/flutter_test.dart';
import 'package:rekognita_app/app/app.dart';

void main() {
  testWidgets('shows manager login screen', (tester) async {
    await tester.pumpWidget(const RekognitaApp());

    expect(find.text('Re::kognita'), findsOneWidget);
    expect(find.text('Увійти'), findsOneWidget);
  });
}
