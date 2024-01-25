package com.fraazo.delivery

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.graphics.Color
import android.os.Build
import android.util.Log
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import com.loctoc.knownuggetssdk.KnowNuggetsSDK


class FcmMessageListenerService : FirebaseMessagingService() {
    private val SDKInstance: KnowNuggetsSDK = KnowNuggetsSDK.getInstance()
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        if (remoteMessage.data.isNotEmpty()) {

            if (remoteMessage.data.containsKey("classification_type")) {
                if (SDKInstance.isAuthenticated(applicationContext)
                ) {
                    SDKInstance.writeRecordReceptionEvent(applicationContext,remoteMessage.data["classification_type"],remoteMessage.data["nugget_id"])
                } else {
                    // TODO: handle authentication failure. Ex: Show login screen
                    Log.e("isUserAuthenticated", "Failed")
                }
                addNotification(remoteMessage.data);
            }



        }
    }



    override fun onNewToken(token: String) {
        super.onNewToken(token)


    }
    lateinit var notificationChannel: NotificationChannel
    lateinit var builder: Notification.Builder
    private fun addNotification(data: MutableMap<String, String>) {
        var notificationManager: NotificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        // pendingIntent is an intent for future use i.e after
        // the notification is clicked, this intent will come into action
        val intent = Intent(this, HomeViewActivity::class.java)

        // FLAG_UPDATE_CURRENT specifies that if a previous
        // PendingIntent already exists, then the current one
        // will update it with the latest intent
        // 0 is the request code, using it later with the
        // same method again will get back the same pending
        // intent for future reference
        // intent passed here is to our afterNotification class
        val pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT)

        // RemoteViews are used to use the content of
        // some different layout apart from the current activity layout


        // checking if android version is greater than oreo(API 26) or not
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notificationChannel = NotificationChannel("new_assigned_task", "This channel is used for new upcoming task.", NotificationManager.IMPORTANCE_HIGH)
            notificationChannel.enableLights(true)
            notificationChannel.lightColor = Color.GREEN
            notificationChannel.enableVibration(false)
            notificationManager.createNotificationChannel(notificationChannel)

            builder = Notification.Builder(this, "new_assigned_task")
                .setContentTitle(data["title"])
                .setContentText(data["body"])
                .setSmallIcon(R.mipmap.ic_launcher_foreground)
                .setLargeIcon(BitmapFactory.decodeResource(this.resources, R.mipmap.ic_launcher_foreground))
                .setContentIntent(pendingIntent)
        } else {

            builder = Notification.Builder(this)
                .setContentTitle(data["title"])
                .setContentText(data["body"])
                .setSmallIcon(R.mipmap.ic_launcher_foreground)
                .setLargeIcon(BitmapFactory.decodeResource(this.resources, R.mipmap.ic_launcher_foreground))
                .setContentIntent(pendingIntent)
        }
        notificationManager.notify(data["title"].hashCode(), builder.build())
    }

}