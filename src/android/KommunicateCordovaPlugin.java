package io.kommunicate.phonegap;

import android.content.Context;
import android.content.Intent;

import com.applozic.mobicomkit.Applozic;
import com.applozic.mobicomkit.api.MobiComKitClientService;
import com.applozic.mobicomkit.api.account.register.RegisterUserClientService;
import com.applozic.mobicomkit.api.account.register.RegistrationResponse;
import com.applozic.mobicomkit.api.account.user.MobiComUserPreference;
import com.applozic.mobicomkit.api.account.user.PushNotificationTask;
import com.applozic.mobicomkit.feed.ChannelFeedApiResponse;
import com.applozic.mobicomkit.uiwidgets.conversation.ConversationUIService;
import com.applozic.mobicommons.json.GsonUtils;
import com.applozic.mobicommons.people.channel.Channel;

import org.json.JSONObject;

import io.kommunicate.KmConversationResponse;
import io.kommunicate.Kommunicate;
import io.kommunicate.async.KmCreateConversationTask;
import io.kommunicate.callbacks.KMLoginHandler;
import io.kommunicate.callbacks.KMStartChatHandler;
import io.kommunicate.users.KMUser;
import io.kommunicate.callbacks.KMLogoutHandler;
import io.kommunicate.callbacks.KmCreateConversationHandler;
import io.kommunicate.activities.KMConversationActivity;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

public class KommunicateCordovaPlugin extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {
        Context context = cordova.getActivity().getApplicationContext();
        final String response = "success";

        final CallbackContext callback = callbackContext;

        if (action.equals("login")) {
            String userJson = data.getString(0);
            KMUser user = (KMUser) GsonUtils.getObjectFromJson(userJson, KMUser.class);

            Kommunicate.init(context, user.getApplicationId());

            Kommunicate.login(context, user, new KMLoginHandler() {
                @Override
                public void onSuccess(RegistrationResponse registrationResponse, Context context) {
                    callback.success(GsonUtils.getJsonFromObject(registrationResponse, RegistrationResponse.class));
                }

                @Override
                public void onFailure(RegistrationResponse registrationResponse, Exception exception) {
                    callback.error(GsonUtils.getJsonFromObject(registrationResponse, RegistrationResponse.class));
                }
            });
        } else if (action.equals("registerPushNotification")) {
            PushNotificationTask pushNotificationTask = null;
            PushNotificationTask.TaskListener listener = new PushNotificationTask.TaskListener() {
                @Override
                public void onSuccess(RegistrationResponse registrationResponse) {
                    callback.success(GsonUtils.getJsonFromObject(registrationResponse, RegistrationResponse.class));
                }

                @Override
                public void onFailure(RegistrationResponse registrationResponse, Exception exception) {
                    callback.error(GsonUtils.getJsonFromObject(registrationResponse, RegistrationResponse.class));
                }
            };
            pushNotificationTask = new PushNotificationTask(Applozic.getInstance(context).getDeviceRegistrationId(), listener, context);
            pushNotificationTask.execute((Void) null);
        } else if (action.equals("isLoggedIn")) {
            callbackContext.success(String.valueOf(MobiComUserPreference.getInstance(context).isLoggedIn()));
        } else if (action.equals("updatePushNotificationToken")) {
            if (MobiComUserPreference.getInstance(context).isRegistered()) {
                try {
                    PushNotificationTask pushNotificationTask = null;
                    PushNotificationTask.TaskListener listener = new PushNotificationTask.TaskListener() {
                        @Override
                        public void onSuccess(RegistrationResponse registrationResponse) {
                            callback.success(GsonUtils.getJsonFromObject(registrationResponse, RegistrationResponse.class));
                        }

                        @Override
                        public void onFailure(RegistrationResponse registrationResponse, Exception exception) {
                            callback.error(GsonUtils.getJsonFromObject(registrationResponse, RegistrationResponse.class));
                        }
                    };
                    pushNotificationTask = new PushNotificationTask(data.getString(0), listener, context);
                    pushNotificationTask.execute((Void) null);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        } else if (action.equals("launchConversation")) {
            try {
                Intent intent = new Intent(context, KMConversationActivity.class);
                cordova.getActivity().startActivity(intent);
                callback.success(response);
            } catch (Exception e) {
                callback.error(e.getMessage());
            }
        } else if (action.equals("launchParticularConversation")) {
            try {
                JSONObject jsonObject = new JSONObject(data.getString(0));
                Intent intent = new Intent(context, KMConversationActivity.class);
                intent.putExtra(ConversationUIService.GROUP_ID, jsonObject.getInt("groupId"));
                intent.putExtra(ConversationUIService.TAKE_ORDER, jsonObject.getBoolean("takeOrder")); //Skip chat list for showing on back press
                context.startActivity(intent);
                callback.success(response);
            } catch (Exception e) {
                callback.error(e.getMessage());
            }
        } else if (action.equals("logout")) {
            Kommunicate.logout(context, new KMLogoutHandler() {
                @Override
                public void onSuccess(Context context) {
                    callback.success(response);
                }

                @Override
                public void onFailure(Exception exception) {
                    callback.error(exception.getMessage());
                }
            });
        } else if (action.equals("startNewConversation")) {
            try {
                final JSONObject jsonObject = new JSONObject(data.getString(0));
                final String agentId = jsonObject.getString("agentId");
                String botId = jsonObject.getString("botId");
                Kommunicate.startNewConversation(context, agentId, botId, new KMStartChatHandler() {
                    @Override
                    public void onSuccess(final Channel channel, Context context) {

                        KmCreateConversationHandler handler = new KmCreateConversationHandler() {
                            @Override
                            public void onSuccess(Context context, KmConversationResponse response) {
                                callback.success(channel.getClientGroupId());
                            }

                            @Override
                            public void onFailure(Context context, Exception e, String error) {
                                callback.error(e == null ? error : e.getMessage());
                            }
                        };
                        new KmCreateConversationTask(context, channel.getKey(), MobiComUserPreference.getInstance(context).getUserId(), MobiComKitClientService.getApplicationKey(context), agentId, handler).execute();
                    }

                    @Override
                    public void onFailure(ChannelFeedApiResponse channelFeedApiResponse, Context context) {
                        callback.error(GsonUtils.getJsonFromObject(channelFeedApiResponse, ChannelFeedApiResponse.class));
                    }
                });
            } catch (Exception e) {
                callback.error(e.getMessage());
            }
        } else {
            return false;
        }

        return true;
    }
}
