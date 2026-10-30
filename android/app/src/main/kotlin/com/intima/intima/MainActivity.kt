package com.intima.intima

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Protection contre les captures d'écran et masquage dans le sélecteur d'applications
        // conformément aux exigences de confidentialité et de sécurité du cahier des charges
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
}
