import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:velotask/models/tag.dart';
import 'package:velotask/services/todo_storage.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('duplicate tag updates color without crash', (tester) async {
    final storage = TodoStorage();

    final tag1 = Tag(name: 'Work', color: '#FF0000');
    final tag2 = Tag(name: 'Work', color: '#00FF00');

    await storage.addTag(tag1);
    await storage.addTag(tag2);

    final tags = await storage.loadTags();
    final matches = tags.where((t) => t.name == 'Work').toList();

    expect(matches.length, 1);
    expect(matches.first.color, '#00FF00');
  });
}
