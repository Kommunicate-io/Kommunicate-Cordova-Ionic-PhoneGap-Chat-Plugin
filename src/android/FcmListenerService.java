package io.kommunicate.phonegap.notification;


import android.util.Log;

import com.applozic.mobicomkit.Applozic;
import com.applozic.mobicomkit.api.account.register.RegisterUserClientService;
import com.applozic.mobicomkit.api.account.register.RegistrationResponse;
import com.applozic.mobicomkit.api.account.user.MobiComUserPreference;
import com.applozic.mobicomkit.api.notification.MobiComPushReceiver;
import com.applozic.mobicommons.commons.core.utils.Utils;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;


public class FcmListenerService extends FirebaseMessagingService {

    private static final String TAG = "ApplozicGcmListener";

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {

        Log.i(TAG, "Message data:" + remoteMessage.getData());

        if (remoteMessage.getData().size() > 0) {
            if (MobiComPushReceiver.isMobiComPushNotification(remoteMessage.getData())) {
                Log.i(TAG, "Applozic notification processing...");
                MobiComPushReceiver.processMessageAsync(this, remoteMessage.getData());
                return;
            }
        }
    }

    @Override
    public void onNewToken(String registrationId) {
        super.onNewToken(registrationId);

        Utils.printLog(this, TAG, "Found Registration Id:" + registrationId);
        Applozic.getInstance(this).setDeviceRegistrationId(registrationId);
        if (MobiComUserPreference.getInstance(this).isRegistered()) {
            try {
                RegistrationResponse registrationResponse = new RegisterUserClientService(this).updatePushNotificationId(registrationId);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
