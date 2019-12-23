package io.kommunicate.phonegap;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;

import com.applozic.mobicomkit.Applozic;
import com.applozic.mobicomkit.api.account.register.RegistrationResponse;
import com.applozic.mobicomkit.api.account.user.MobiComUserPreference;
import com.applozic.mobicomkit.api.account.user.PushNotificationTask;
import com.applozic.mobicomkit.api.conversation.ApplozicConversation;
import com.applozic.mobicomkit.api.conversation.Message;
import com.applozic.mobicomkit.channel.service.ChannelService;
import com.applozic.mobicomkit.exception.ApplozicException;
import com.applozic.mobicomkit.feed.ChannelFeedApiResponse;
import com.applozic.mobicomkit.listners.MessageListHandler;
import com.applozic.mobicomkit.uiwidgets.conversation.ConversationUIService;
import com.applozic.mobicomkit.uiwidgets.conversation.activity.ConversationActivity;
import com.applozic.mobicommons.json.GsonUtils;
import com.applozic.mobicommons.people.channel.Channel;
import com.applozic.mobicomkit.api.notification.MobiComPushReceiver;
import com.applozic.mobicomkit.uiwidgets.async.AlChannelInfoTask;

import org.json.JSONObject;

import io.kommunicate.KmChatBuilder;
import io.kommunicate.KmConversationHelper;
import io.kommunicate.KmException;
import io.kommunicate.Kommunicate;
import io.kommunicate.callbacks.KMLoginHandler;
import io.kommunicate.callbacks.KMStartChatHandler;
import io.kommunicate.callbacks.KmCallback;
import io.kommunicate.users.KMUser;
import io.kommunicate.callbacks.KMLogoutHandler;
import io.kommunicate.utils.KmConstants;
import io.kommunicate.utils.KmUtils;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class KommunicateCordovaPlugin extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {
        final Context context = cordova.getActivity().getApplicationContext();
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
        } else if (action.equals("loginAsVisitor")) {
            String appId = data.getString(0);
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
        } else if (action.equals("startSingleChat")) {
            try {
                final JSONObject jsonObject = new JSONObject(data.getString(0));
                KMUser user = null;
                String groupName = null;
                boolean withPrechat = false;
                boolean isUnique = true;
                List<String> agentIds = new ArrayList<String>();
                List<String> botIds;

                if (jsonObject.has("appId")) {
                    Kommunicate.init(context, jsonObject.getString("appId"));
                }

                if (jsonObject.has("withPreChat")) {
                    withPrechat = jsonObject.getBoolean("withPreChat");
                }
                if (!withPrechat) {
                    if (jsonObject.has("kmUser")) {
                        user = (KMUser) GsonUtils.getObjectFromJson(jsonObject.getString("kmUser"), KMUser.class);
                    } else {
                        user = Kommunicate.getVisitor();
                    }
                }

                if (jsonObject.has("isUnique")) {
                    isUnique = jsonObject.getBoolean("isUnique");
                }

                if (jsonObject.has("agentIds")) {
                    agentIds = (List<String>) GsonUtils.getObjectFromJson(jsonObject.getString("agentIds"), List.class);
                } else {
                    callback.error("Agent List is empty. Please pass agentIds paramter");
                }

                botIds = jsonObject.has("botIds") ? (List<String>) GsonUtils.getObjectFromJson(jsonObject.getString("botIds"), List.class) : null;

                if (jsonObject.has("groupName")) {
                    groupName = jsonObject.getString("groupName");
                }

                Kommunicate.launchSingleChat(cordova.getActivity(), groupName == null ? "Support" : groupName, user, withPrechat, isUnique, agentIds, botIds, null, new KmCallback() {
                    @Override
                    public void onSuccess(Object message) {
                        callback.success(message != null ? message.toString() : "Success");
                    }

                    @Override
                    public void onFailure(Object error) {
                        callback.error(error != null ? error.toString() : "Unknown error occurred");
                    }
                });


            } catch (Exception e) {
                callback.error(e.getMessage());
            }
        } else if (action.equals("conversationBuilder")) {
            try {
                final JSONObject jsonObject = new JSONObject(data.getString(0));

                KmChatBuilder chatBuilder = new KmChatBuilder(cordova.getActivity());

                if (jsonObject.has("appId")) {
                    chatBuilder.setApplicationId(jsonObject.getString("appId"));
                }

                if (jsonObject.has("withPreChat")) {
                    chatBuilder.setWithPreChat(jsonObject.getBoolean("withPreChat"));
                }

                if (jsonObject.has("kmUser")) {
                    chatBuilder.setKmUser((KMUser) GsonUtils.getObjectFromJson(jsonObject.getString("kmUser"), KMUser.class));
                }

                if (jsonObject.has("isUnique")) {
                    chatBuilder.setSingleChat(jsonObject.getBoolean("isUnique"));
                }

                if (jsonObject.has("agentIds")) {
                    chatBuilder.setAgentIds((List<String>) GsonUtils.getObjectFromJson(jsonObject.getString("agentIds"), List.class));
                }

                if (jsonObject.has("botIds")) {
                    chatBuilder.setBotIds((List<String>) GsonUtils.getObjectFromJson(jsonObject.getString("botIds"), List.class));
                }

                if (jsonObject.has("groupName")) {
                    chatBuilder.setChatName(jsonObject.getString("groupName"));
                }

                if (jsonObject.has("deviceToken")) {
                    chatBuilder.setDeviceToken(jsonObject.getString("deviceToken"));
                }

                if (jsonObject.has("metadata")) {
                    chatBuilder.setMetadata((Map<String, String>) GsonUtils.getObjectFromJson(jsonObject.getString("metadata"), Map.class));
                }

                if (jsonObject.has("launchAndCreateIfEmpty") && jsonObject.getBoolean("launchAndCreateIfEmpty")) {
                    ApplozicConversation.getLatestMessageList(cordova.getActivity(), false, new MessageListHandler() {
                        @Override
                        public void onResult(List<Message> messageList, ApplozicException e) {
                            if (e == null) {
                                if (messageList.isEmpty()) {
                                    chatBuilder.setSkipChatList(false);
                                    chatBuilder.launchChat(getLaunchChatCallback(callback));
                                } else if (messageList.size() == 1) {
                                    openParticularConversation(cordova.getActivity(), false, messageList.get(0).getGroupId(), getLaunchChatCallback(callback));
                                } else {
                                    Kommunicate.openConversation(cordova.getActivity(), getLaunchChatCallback(callback));
                                }
                            }
                        }
                    });
                } else if (jsonObject.has("createOnly") && jsonObject.getBoolean("createOnly")) {
                    chatBuilder.createChat(new KmCallback() {
                        @Override
                        public void onSuccess(Object message) {
                            Channel channel = ChannelService.getInstance(context).getChannelByChannelKey((Integer) message);
                            callback.success(channel != null && !TextUtils.isEmpty(channel.getClientGroupId()) ? channel.getClientGroupId() : (String) message);
                        }

                        @Override
                        public void onFailure(Object error) {
                            callback.error(error != null ? error.toString() : "Unknown error occurred");
                        }
                    });
                } else {
                    chatBuilder.launchChat(getLaunchChatCallback(callback));
                }
            } catch (Exception e) {
                e.printStackTrace();
                callback.error(e.getMessage());
            }
        } else if (action.equals("launchConversation")) {
            try {
                Intent intent = new Intent(context, ConversationActivity.class);
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
                        Intent intent = new Intent(context, ConversationActivity.class);
                        intent.putExtra(ConversationUIService.GROUP_ID, channelInfoModel.getChannel().getKey());
                        try {
                            intent.putExtra(ConversationUIService.TAKE_ORDER, jsonObject.getBoolean("takeOrder")); //Skip chat list for showing on back press
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        cordova.getActivity().startActivity(intent);
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
                boolean isUnique = false;
                try {
                    groupName = jsonObject.getString("groupName");
                    isUnique = jsonObject.getBoolean("isUnique");
                } catch (Exception e) {
                }
                final List<String> agentIds = jsonObject.has("agentIds") ? (List<String>) GsonUtils.getObjectFromJson(jsonObject.getString("agentIds"), List.class) : null;
                final List<String> botIds = jsonObject.has("botIds") ? (List<String>) GsonUtils.getObjectFromJson(jsonObject.getString("botIds"), List.class) : null;

                KmChatBuilder builder = new KmChatBuilder(cordova.getActivity())
                        .setAgentIds(agentIds)
                        .setBotIds(botIds)
                        .setChatName(groupName)
                        .setSingleChat(isUnique);
                Kommunicate.startConversation(builder, new KMStartChatHandler() {
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

        } else if (action.equals("processPushNotification")) {
            try {
                Map<String, String> pushData = (Map) GsonUtils.getObjectFromJson(data.getString(0), Map.class);
                if (MobiComPushReceiver.isMobiComPushNotification(pushData)) {
                    MobiComPushReceiver.processMessageAsync(context, pushData);
                }
            } catch (Exception e) {

            }
        } else if (action.equals("updateChatContext")) {
            try {
                HashMap<String, Object> chatContext = (HashMap<String, Object>) GsonUtils.getObjectFromJson(data.getString(0), HashMap.class);
                if (Kommunicate.isLoggedIn(context)) {
                    Kommunicate.updateChatContext(context, getStringMap(chatContext));
                    callback.success("Success");
                } else {
                    callback.error("User not authorised. This usually happens when calling the function before conversationBuilder or loginUser. Make sure you call either of the two functions before updating the chatContext");
                }
            } catch (Exception e) {
                callback.error(e.toString());
            }
        } else {
            return false;
        }
        return true;
    }

    private Map<String, String> getStringMap(HashMap<String, Object> objectMap) {
        if (objectMap == null) {
            return null;
        }
        Map<String, String> newMap = new HashMap<>();
        for (Map.Entry<String, Object> entry : objectMap.entrySet()) {
            newMap.put(entry.getKey(), entry.getValue() instanceof String ? (String) entry.getValue() : entry.getValue().toString());
        }
        return newMap;
    }

    private KmCallback getLaunchChatCallback(CallbackContext callback) {
        return new KmCallback() {
            @Override
            public void onSuccess(Object message) {
                callback.success(message != null ? message.toString() : "Success");
            }

            @Override
            public void onFailure(Object error) {
                callback.error(error != null ? error.toString() : "Unknown error occurred");
            }
        };
    }

    private void openParticularConversation(Context context, boolean skipConversationList, Integer conversationId, KmCallback callback) {
        try {
            Intent intent = new Intent(context, KmUtils.getClassFromName(KmConstants.CONVERSATION_ACTIVITY_NAME));
            intent.putExtra(KmConstants.GROUP_ID, conversationId);
            intent.putExtra(KmConstants.TAKE_ORDER, skipConversationList);
            context.startActivity(intent);
            if (callback != null) {
                callback.onSuccess(conversationId);
            }
        } catch (ClassNotFoundException e) {
            if (callback != null) {
                callback.onFailure(e.getMessage());
            }
        }
    }
}
