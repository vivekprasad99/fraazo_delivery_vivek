package com.fraazo.delivery

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import com.google.firebase.ktx.Firebase
import com.google.firebase.ktx.initialize
import com.loctoc.knownuggetssdk.KnowNuggetsSDK
import com.loctoc.knownuggetssdk.KnowNuggetsSDK.KNAppInit
import com.loctoc.knownuggetssdk.KnowNuggetsSDK.SdkAuthCallBacks
import com.loctoc.knownuggetssdk.activities.ShareActivity
import com.loctoc.knownuggetssdk.modelClasses.KNError
import com.loctoc.knownuggetssdk.modelClasses.KNInstanceCredentials
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import zendesk.messaging.android.Messaging

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {

    private val SDKInstance: KnowNuggetsSDK = KnowNuggetsSDK.getInstance()


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)


        val channel = MethodChannel(flutterEngine?.dartExecutor, "com.rbdevs/zendesk_messaging")
        channel.setMethodCallHandler(this);

        val knowChannel = MethodChannel(flutterEngine?.dartExecutor, "knowNotificationService")
        knowChannel.setMethodCallHandler(this);
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialise" -> initialise(call.arguments, result)
            "open_messaging" -> openMessaging(result)
            "initialiseKnow" -> initialiseKNOW(call.arguments, result)
            "initialiseFirebase" -> initialiseFirebase()
            "openKnowNotification" -> openKnowNotificationPage()
            "knowSignOut" -> knowSignOut()
            "knowReadEvent" -> sendKnowMessageEvent(call.arguments)
            else -> result.notImplemented()
        }
    }

    private fun initialiseFirebase() {

//        val firebaseApp: FirebaseOptions = FirebaseOptions.Builder()
//            .setApplicationId("1:132439669770:android:c5f5934bec122e982c73f3")
//            .setApiKey("AIzaSyCgOvOSVQ9IqKZXYXzU2TvED-CsUBAt6hs")
//            .setDatabaseUrl("https://fraazo-delivery-default-rtdb.asia-southeast1.firebasedatabase.app")
//            .setGcmSenderId("132439669770").setProjectId("fraazo-delivery")
//            .setStorageBucket("fraazo-delivery.appspot.com").build()
//        FirebaseApp.initializeApp(applicationContext)
        Log.e("FirebaseApp", FirebaseApp.getApps(context).toString())

    }

    private fun initialise(arguments: Any, result: MethodChannel.Result) {
        Messaging.initialize(
            context = this,
            channelKey = arguments as String,
            successCallback = {
                Log.i("ZendeskSupport", "Initialization successful")
                result.success(true)

            },
            failureCallback = { cause ->
                // Tracking the cause of exceptions in your crash reporting dashboard will help to triage any unexpected failures in production
                Log.e("IntegrationApplication", "Initialization failed", cause)
                result.error("ZendeskSupport", "Initialization failed", cause)
            }
        )
    }

    private fun initialiseKNOW(arguments: Any, result: MethodChannel.Result) {

        SDKInstance.initKNSDK(this, getCredentials())
        SDKInstance.initKNApp(object : KnowNuggetsSDK.KNAppInit {
            override fun onSuccess() {

            }

            override fun onFailure(knError: KNError) {
                // NOTE: No action required, this is just for a cold start
            }
        }, this)

        val userInfo: Map<String, String> = arguments as Map<String, String>

//        Log.e("android userInfo", userInfo.toString())
        val tags = ArrayList<String>()
        userInfo["city"]?.let { tags.add(it) }
        userInfo["status"]?.let { tags.add(it) }
        userInfo["store"]?.let { tags.add(it) }
//        tags.add("Rider Status")


        if (SDKInstance.isAuthenticated(context)
        ) {
            SDKInstance.setTags(
                applicationContext,
                tags
            )
            SDKInstance.updateName(
                applicationContext,
                userInfo["firstName"],
                userInfo["lastName"]
            )
        } else {
            // TODO: handle authentication failure. Ex: Show login screen
            SDKInstance.authenticateUser(this,
                context.getString(R.string.know_tokenKey),
                userInfo["id"],
                object : SdkAuthCallBacks {
                    override fun onSdkAuthSuccess() {

                        // Update user's profile here.
                        // When a new user login for the first time that user will be created
                        // in Know and here we have to update his firstName and lastName
                        SDKInstance.setTags(
                            applicationContext,
                            tags
                        )
                        SDKInstance.updateName(
                            applicationContext,
                            userInfo["firstName"],
                            userInfo["lastName"]
                        )

                    }

                    override fun onSdkAuthFailure(knError: KNError) {
                        // TODO: handle authentication failure properly.
                        Log.e("onSdkAuthFailure", knError.errorMessage)

                    }
                })
        }


    }

    private fun openMessaging(result: MethodChannel.Result) {
        Messaging.instance().showMessaging(this@MainActivity)
        result.success(true)
    }

    private fun openKnowNotificationPage() {
        if (SDKInstance.isAuthenticated(context)
        ) {
            val intent = Intent(this, HomeViewActivity::class.java)
            startActivity(intent)
        } else {
            // TODO: handle authentication failure. Ex: Show login screen
            Log.e("isUserAuthenticated", "Failed")
        }
    }

    private fun knowSignOut() {
        SDKInstance.signOut(context)
    }

    private fun sendKnowMessageEvent(arguments: Any)
    {
        val info: Map<String, String> = arguments as Map<String, String>
        if (SDKInstance.isAuthenticated(context)
        ) {
             SDKInstance.writeRecordReceptionEvent(context,info["type"],info["id"])
        } else {
            // TODO: handle authentication failure. Ex: Show login screen
            Log.e("isUserAuthenticated", "Failed")
        }
    }

    private fun getCredentials(): KNInstanceCredentials {
        val credentials = KNInstanceCredentials()
        credentials.databaseUrl =
            context.getString(R.string.know_databaseUrl)//Set the FB DB key
        credentials.apiKey = context.getString(R.string.know_apiKey)// Set the FB API key
        credentials.appId = context.getString(R.string.know_appId) // Set the App ID
        credentials.storageBucket = context.getString(R.string.know_storageBucket)
        credentials.senderId = "132439669770"
        credentials.projectId = "hockey-stick-in"

        return credentials
    }

}
