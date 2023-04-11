package com.example.keystore_strongbox

import android.content.Context
import com.google.gson.Gson
import android.os.Build
import android.util.Base64
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.lang.Exception


/** KeystoreStrongboxPlugin */
@RequiresApi(Build.VERSION_CODES.M)
class KeystoreStrongboxPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var cryptoManager: CryptoManager
    private var gson = Gson()

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "keystore_strongbox")
        context = flutterPluginBinding.applicationContext
        channel.setMethodCallHandler(this)
        cryptoManager = CryptoManager(context)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${Build.VERSION.RELEASE}")
            "encrypt" -> encrypt(call, result)
            "decrypt" -> decrypt(call, result)
            "storeSharedPreferences" -> storeSharedPreferences(call, result)
            "loadSharedPreferences" -> loadSharedPreferences(call, result)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun encrypt(call: MethodCall, result: Result) {
        try {
            val params = call.arguments as Map<*, *>
            val tag = params["tag"] as String
            val message = params["message"] as String
            val iv = params["iv"] as String?

            val cipher =
                cryptoManager.getInitializedCipherForEncryption(tag, iv)
            val ciphertext = cryptoManager.encryptData(message, cipher)

            val jsonString = gson.toJson(
                ResultEncryption(
                    Base64.encodeToString(
                        ciphertext.initializationVector,
                        Base64.NO_WRAP
                    ),
                    Base64.encodeToString(
                        ciphertext.ciphertext,
                        Base64.NO_WRAP
                    ),
                )
            )
            return result.success(jsonString)
        } catch (e: Exception) {
            return result.error("0", "Encryption Error", e.message)
        }
    }

    private fun decrypt(call: MethodCall, result: Result) {
        try {
            val params = call.arguments as Map<*, *>
            val tag = params["tag"] as String
            val message = params["message"] as String
            val iv = params["iv"] as String

            val ciphertext: Ciphertext =
                Ciphertext(
                    Base64.decode(message, Base64.DEFAULT),
                    Base64.decode(iv, Base64.DEFAULT)
                )

            val cipher =
                cryptoManager.getInitializedCipherForDecryption(
                    tag,
                    ciphertext.initializationVector
                )

            val plainText = cryptoManager.decryptData(ciphertext.ciphertext, cipher)

            val jsonString = gson.toJson(
                ResultDecryption(
                    plainText
                )
            )
            return result.success(jsonString)
        } catch (e: Exception) {
            return result.error("1", "Decryption Error", e.message)
        }
    }

    private fun storeSharedPreferences(call: MethodCall, result: MethodChannel.Result) {
        return try {
            val params = call.arguments as Map<*, *>
            val tag = params["tag"] as String
            val sharedPreferenceName = params["sharedPreferenceName"] as String
            val message = params["message"] as String

            val sharedPreferences =
                context.getSharedPreferences(sharedPreferenceName, Context.MODE_PRIVATE)
            val editor = sharedPreferences.edit()
            editor.putString(tag, message)
            editor.apply()
            result.success(true)
        } catch (e: Exception) {
            result.error("2", "Store Shared Preferences Error", e.message)
        }
    }

    private fun loadSharedPreferences(call: MethodCall, result: MethodChannel.Result) {
        try {
            val params = call.arguments as Map<*, *>
            val tag = params["tag"] as String
            val sharedPreferenceName = params["sharedPreferenceName"] as String

            val sharedPreferences =
                context.getSharedPreferences(sharedPreferenceName, Context.MODE_PRIVATE)
            val res = sharedPreferences.getString(tag, null)
            result.success(res)
        } catch (e: Exception) {
            result.error("3", "Load Shared Preferences Error", e.message)
        }
    }
}

data class ResultEncryption(
    val iv: String,
    val ciphertext: String
)

data class ResultDecryption(
    val plainText: String
)