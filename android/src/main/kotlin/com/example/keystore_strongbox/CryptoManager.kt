package com.example.keystore_strongbox

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import androidx.annotation.RequiresApi
import java.nio.charset.Charset
import java.security.KeyStore
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

data class Ciphertext(val ciphertext: ByteArray, val initializationVector: ByteArray)

@RequiresApi(Build.VERSION_CODES.M)
fun CryptoManager(context: Context): CryptoManager = CryptoManagerImpl(context = context)

@RequiresApi(Build.VERSION_CODES.M)
interface CryptoManager {
    /**
     * This will gets or generates an instance of SecretKey, and then initializes Chiper with the key.
     * The secret key uses [ENCRYPT_MODE][Cipher.ENCRYPT_MODE].
     *
     * @return [Cipher]
     */
    fun getInitializedCipherForEncryption(
        tag: String,
        iv: String?
    ): Cipher

    /**
     * This will gets or generates an instance of SecretKey, and then initializes Cipher with the key.
     * The secret key uses [DECRYPT_MODE][Cipher.DECRYPT_MODE].
     *
     * @return [Cipher]
     */
    fun getInitializedCipherForDecryption(
        tag: String,
        initializationVector: ByteArray,
    ): Cipher

    /**
     * Cipher created with [getInitializedCipherForEncryption] is used here to encrypt [message].
     *
     * @return [Ciphertext]
     */
    fun encryptData(message: String, cipher: Cipher): Ciphertext

    /**
     * Cipher created with [getInitializedCipherForDecryption] is used here to decrypt [ciphertext].
     *
     * @return [String]
     */
    fun decryptData(ciphertext: ByteArray, cipher: Cipher): String
}

@RequiresApi(Build.VERSION_CODES.M)
class CryptoManagerImpl(context: Context) : CryptoManager {
    private val context: Context = context
    private val KEY_SIZE = 256
    private val ANDROID_KEYSTORE = "AndroidKeyStore"
    private val ENCRYPTION_BLOCK_MODE = KeyProperties.BLOCK_MODE_GCM
    private val ENCRYPTION_PADDING = KeyProperties.ENCRYPTION_PADDING_NONE
    private val ENCRYPTION_ALGORITHM = KeyProperties.KEY_ALGORITHM_AES

    override fun getInitializedCipherForEncryption(
        tag: String,
        iv: String?
    ): Cipher {
        val cipher = getCipher()
        val secretKey = getSecretKey(tag)
        if (iv == null) {
            println("IV not exist")
            val nonce = ByteArray(12)
            SecureRandom().nextBytes(nonce)
            cipher.init(Cipher.ENCRYPT_MODE, secretKey, GCMParameterSpec(128, nonce))
        } else {
            println("IV exist")
            println("IV exist $iv")
            cipher.init(
                Cipher.ENCRYPT_MODE,
                secretKey,
                GCMParameterSpec(128, Base64.decode(iv, Base64.DEFAULT))
            )
            println("IV 2 exist $iv")
        }
        return cipher
    }

    override fun getInitializedCipherForDecryption(
        tag: String,
        initializationVector: ByteArray,
    ): Cipher {
        val cipher = getCipher()
        val secretKey = getSecretKey(tag)

        cipher.init(Cipher.DECRYPT_MODE, secretKey, GCMParameterSpec(128, initializationVector))
        return cipher
    }

    override fun encryptData(message: String, cipher: Cipher): Ciphertext {
        val messageByte = message.toByteArray(Charset.forName("UTF-8"))
        val ciphertext = cipher.doFinal(messageByte)

        return Ciphertext(ciphertext, cipher.iv)
    }

    override fun decryptData(ciphertext: ByteArray, cipher: Cipher): String {
        val messageByte = cipher.doFinal(ciphertext)

        return String(messageByte, Charset.forName("UTF-8"))
    }

    private fun getCipher(): Cipher {
        return Cipher.getInstance("$ENCRYPTION_ALGORITHM/$ENCRYPTION_BLOCK_MODE/$ENCRYPTION_PADDING")
    }

    private fun getSecretKey(tag: String): SecretKey {
        // If Secretkey exist for that keyName, grab and return it.
        val keyStore = KeyStore.getInstance(ANDROID_KEYSTORE)
        keyStore.load(null)
        keyStore.getKey(tag, null)?.let {
            println("Secretkey exist")
            return it as SecretKey
        }
        println("Secretkey no-exist")
        // If not, generate a new one
        val keyGen = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES,
            ANDROID_KEYSTORE
        )

        val keyGenParameterSpec = KeyGenParameterSpec.Builder(
            tag,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P && context.packageManager.hasSystemFeature(
                PackageManager.FEATURE_STRONGBOX_KEYSTORE
            )
        ) {
            keyGenParameterSpec.setIsStrongBoxBacked(true)
        }

        keyGenParameterSpec.setBlockModes(ENCRYPTION_BLOCK_MODE)
        keyGenParameterSpec.setEncryptionPaddings(ENCRYPTION_PADDING)
        keyGenParameterSpec.setKeySize(KEY_SIZE)
        keyGenParameterSpec.setRandomizedEncryptionRequired(false)
        keyGenParameterSpec.build()
        keyGen.init(
            keyGenParameterSpec.build()
        )

        return keyGen.generateKey()
    }
}