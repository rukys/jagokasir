import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_kasir/shared/providers/app_lifecycle_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  TestWidgetsFlutterBinding.ensureInitialized();

  test('should default to 5 minutes timeout', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Read the provider
    final timeout = container.read(appLifecycleProvider);
    expect(timeout, 5);
  });

  test('should update timeout and persist value', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(appLifecycleProvider.notifier);
    await notifier.updateTimeoutMinutes(10);

    expect(container.read(appLifecycleProvider), 10);

    // Verify it is saved in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('idle_timeout_minutes'), 10);
  });

  test('should allow 0 minutes for Never', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(appLifecycleProvider.notifier);
    await notifier.updateTimeoutMinutes(0);

    expect(container.read(appLifecycleProvider), 0);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('idle_timeout_minutes'), 0);
  });

  test('should ignore out of bounds timeout values', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(appLifecycleProvider.notifier);
    
    // Greater than 60
    await notifier.updateTimeoutMinutes(99);
    expect(container.read(appLifecycleProvider), 5); // remains 5

    // Negative value
    await notifier.updateTimeoutMinutes(-1);
    expect(container.read(appLifecycleProvider), 5); // remains 5
  });
}
