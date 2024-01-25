package com.fraazo.delivery

import com.loctoc.knownuggetssdk.KnowNuggetsSDK
import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugins.GeneratedPluginRegistrant


class FraazoApplication : FlutterApplication() {
    private val SDKInstance: KnowNuggetsSDK = KnowNuggetsSDK.getInstance()
    override fun onCreate() {
        super.onCreate()
//        FirebaseApp.initializeApp(applicationContext)
    }



}

