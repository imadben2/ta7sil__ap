package com.example.memo_app

import com.memo.app.DndManagerPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register DND Manager plugin for Focus Mode feature
        flutterEngine.plugins.add(DndManagerPlugin())
    }
}
