package io.kommunicate.phonegap;

import android.content.Context;
import android.content.Intent;

import com.applozic.mobicomkit.Applozic;
import com.applozic.mobicomkit.api.account.register.RegistrationResponse;
import com.applozic.mobicomkit.api.account.user.MobiComUserPreference;
import com.applozic.mobicomkit.api.account.user.PushNotificationTask;
import com.applozic.mobicomkit.feed.ChannelFeedApiResponse;
import com.applozic.mobicomkit.uiwidgets.conversation.ConversationUIService;
import com.applozic.mobicommons.json.GsonUtils;
import com.applozic.mobicommons.people.channel.Channel;
import com.applozic.mobicomkit.api.notification.MobiComPushReceiver;
import com.applozic.mobicomkit.uiwidgets.async.AlChannelInfoTask;

import org.json.JSONObject;

import io.kommunicate.Kommunicate;
import io.kommunicate.callbacks.KMLoginHandler;
import io.kommunicate.callbacks.KMStartChatHandler;
import io.kommunicate.users.KMUser;
import io.kommunicate.callbacks.KMLogoutHandler;
import io.kommunicate.activities.KMConversationActivity;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

import java.util.List;
import java.util.Map;

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
                final JSONObject jsonObject = new JSONObject(data.getString(0));
                AlChannelInfoTask.ChannelInfoListener listener = new AlChannelInfoTask.ChannelInfoListener() {
                    @Override
                    public void onSuccess(AlChannelInfoTask.ChannelInfoModel channelInfoModel, String response, Context context) {
                        Intent intent = new Intent(context, KMConversationActivity.class);
                        intent.putExtra(ConversationUIService.GROUP_ID, channelInfoModel.getChannel().getKey());
                        try {
                            intent.putExtra(ConversationUIService.TAKE_ORDER, jsonObject.getBoolean("takeOrder")); //Skip chat list for showing on back press
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        context.startActivity(intent);
                        callback.success(response);
                    }

                    @Override
                    public void onFailure(String response, Exception e, Context context) {
                        if (response != null) {
                            callback.error(response);
                        } else if (e != null) {
                            callback.error(e.getMessage());
                        }
                    }
                };
                new AlChannelInfoTask(context, null, jsonObject.getString("clientChannelKey"), false, listener).execute();
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
                String groupName = null;
                try {
                    groupName = jsonObject.getString("groupName");
                } catch (Exception e) {
                }
                final List<String> agentIds = (List<String>) GsonUtils.getObjectFromJson(jsonObject.getString("agentIds"), List.class);
                final List<String> botIds = (List<String>) GsonUtils.getObjectFromJson(jsonObject.getString("botIds"), List.class);

                Kommunicate.startNewConversation(context,
                        groupName,
                        agentIds,
                        botIds,
                        false,
                        new KMStartChatHandler() {
                            @Override
                            public void onSuccess(Channel channel, Context context) {
                                callback.success(channel.getClientGroupId());
                            }

                            @Override
                            public void onFailure(ChannelFeedApiResponse channelFeedApiResponse, Context context) {
                                callback.error(GsonUtils.getJsonFromObject(channelFeedApiResponse, ChannelFeedApiResponse.class));
                            }
                        });
            } catch (Exception e) {
                callback.error(e.getMessage());
            }
        } else if (action.equals("startOrGetConversation")) {
            try {
                final JSONObject jsonObject = new JSONObject(data.getString(0));
                String groupName = null;
                try {
                    groupName = jsonObject.getString("groupName");
                } catch (Exception e) {
                }
                final List<String> agentIds = (List<String>) GsonUtils.getObjectFromJson(jsonObject.getString("agentIds"), List.class);
                final List<String> botIds = (List<String>) GsonUtils.getObjectFromJson(jsonObject.getString("botIds"), List.class);

                Kommunicate.startOrGetConversation(context, groupName, agentIds, botIds, new KMStartChatHandler() {
                    @Override
                    public void onSuccess(Channel channel, Context context) {
                        callback.success(channel.getClientGroupId());
                    }

                    @Override
                    public void onFailure(ChannelFeedApiResponse channelFeedApiResponse, Context context) {
                        callback.error(GsonUtils.getJsonFromObject(channelFeedApiResponse, ChannelFeedApiResponse.class));
                    }
                });
            } catch (Exception e) {

            }
        } else if (action.equals("processPushNotification")) {
            try {
                Map<String, String> pushData = (Map) GsonUtils.getObjectFromJson(data.getString(0), Map.class);
                if (MobiComPushReceiver.isMobiComPushNotification(pushData)) {
                    MobiComPushReceiver.processMessageAsync(context, pushData);
                }
            } catch (Exception e) {

            }
        } else {
            return false;
        }

        return true;
    }
}
