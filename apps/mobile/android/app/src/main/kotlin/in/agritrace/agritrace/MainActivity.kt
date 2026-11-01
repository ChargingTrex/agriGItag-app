// The Android activity hosting the Flutter app, plus one small platform call: free storage for the "Phone is full"
// check (lib/core/capture/free_space.dart).
// Requirement: PLAN §7.2 M13 (storage < 100 MB → prompt + purge confirmed photos); mobile-design.md §3.
// Callers: Android (launcher activity in AndroidManifest.xml); Dart calls the channel `in.agritrace/storage`.
package `in`.agritrace.agritrace

import android.os.StatFs
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    /** Registers the plugins, then answers `freeBytes` with the bytes free for this app on its files volume. */
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // A platform API in three lines instead of a disk-space plugin (no dependency for a few lines).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "in.agritrace/storage").setMethodCallHandler { call, result ->
            if (call.method == "freeBytes") result.success(StatFs(filesDir.path).availableBytes) else result.notImplemented()
        }
    }
}
