package com.fahamutech.smartstock.pos

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.PersistableBundle
import android.util.Log
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        startServices()
    }

    private fun startServices(){
        Log.i("MainActivity","Starting the application")
        val salesIntent = Intent(this, SalesSyncService::class.java)
        val stockIntent = Intent(this, StockSyncService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            this.startForegroundService(salesIntent)
            this.startForegroundService(stockIntent)
        } else {
            this.startService(salesIntent)
            this.startService(stockIntent)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)


    }
}
