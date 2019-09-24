package io.kommunicate.phonegap;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;

import com.applozic.mobicomkit.Applozic;
import com.applozic.mobicomkit.api.account.register.RegistrationResponse;
import com.applozic.mobicomkit.api.account.user.MobiComUserPreference;
import com.applozic.mobicomkit.api.account.user.PushNotificationTask;
import com.applozic.mobicomkit.channel.service.ChannelService;
import com.applozic.mobicomkit.feed.ChannelFeedApiResponse;
import com.applozic.mobicomkit.uiwidgets.async.AlChannelCreateAsyncTask;
import com.applozic.mobicomkit.uiwidgets.async.AlGroupInformationAsyncTask;
import com.applozic.mobicomkit.uiwidgets.conversation.ConversationUIService;
import com.applozic.mobicomkit.uiwidgets.conversation.activity.ConversationActivity;
import com.applozic.mobicommons.json.GsonUtils;
import com.applozic.mobicommons.people.channel.Channel;
import com.applozic.mobicomkit.api.notification.MobiComPushReceiver;
import com.applozic.mobicomkit.uiwidgets.async.AlChannelInfoTask;

import org.json.JSONObject;

import io.kommunicate.KMGroupInfo;
import io.kommunicate.KmChatBuilder;
import io.kommunicate.KmConversationBuilder;
import io.kommunicate.KmException;
import io.kommunicate.Kommunicate;
import io.kommunicate.callbacks.KMLoginHandler;
import io.kommunicate.callbacks.KMStartChatHandler;
import io.kommunicate.callbacks.KmCallback;
import io.kommunicate.users.KMUser;
import io.kommunicate.callbacks.KMLogoutHandler;

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

                if (jsonObject.has("createOnly") && jsonObject.getBoolean("createOnly")) {
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
                    chatBuilder.launchChat(new KmCallback() {
                        @Override
                        public void onSuccess(Object message) {
                            callback.success(message != null ? message.toString() : "Success");
                        }

                        @Override
                        public void onFailure(Object error) {
                            callback.error(error != null ? error.toString() : "Unknown error occurred");
                        }
                    });
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
                Kommunicate.startConversation(builder,  new KMStartChatHandler() {
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

                final List<String> agentIds = (List<String>) GsonUtils.getObjectFromJson(jsonObject.getString("agentIds"), List.class);
                final List<String> botIds = jsonObject.has("botIds") ? (List<String>) GsonUtils.getObjectFromJson(jsonObject.getString("botIds"), List.class) : null;

                String clientGroupId = getClientGroupId(MobiComUserPreference.getInstance(context).getUserId(), agentIds, botIds);

                AlGroupInformationAsyncTask.GroupMemberListener groupMemberListener = new AlGroupInformationAsyncTask.GroupMemberListener() {
                    @Override
                    public void onSuccess(Channel channel, Context context) {
                        if (channel != null) {
                            callback.success(channel.getClientGroupId());
                        }
                    }

                    @Override
                    public void onFailure(Channel channel, Exception e, Context context) {
                        try {
                            String groupName = null;
                            try {
                                groupName = jsonObject.getString("groupName");
                            } catch (Exception e1) {
                            }

                            startNewConversation(context, groupName, agentIds, botIds, true, new KMStartChatHandler() {
                                @Override
                                public void onSuccess(Channel channel, Context context) {
                                    callback.success(channel.getClientGroupId());
                                }

                                @Override
                                public void onFailure(ChannelFeedApiResponse channelFeedApiResponse, Context context) {
                                    callback.error(GsonUtils.getJsonFromObject(channelFeedApiResponse, ChannelFeedApiResponse.class));
                                }
                            });
                        } catch (KmException e1) {
                            callback.error(e1.getMessage());
                        }
                    }
                };

                new AlGroupInformationAsyncTask(context, clientGroupId, groupMemberListener).execute();
            } catch (Exception e) {
                callback.error(e.getMessage());
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

    public static void startNewConversation(Context context, String groupName, List<String> agentIds, List<String> botIds, boolean isUniqueChat, KMStartChatHandler handler) throws KmException {
        List<KMGroupInfo.GroupUser> users = new ArrayList<KMGroupInfo.GroupUser>();

        KMGroupInfo channelInfo = new KMGroupInfo(TextUtils.isEmpty(groupName) ? "Kommunicate Support" : groupName, new ArrayList<String>());

        if (agentIds == null || agentIds.isEmpty()) {
            throw new KmException("Agent Id list cannot be null or empty");
        }
        for (String agentId : agentIds) {
            users.add(channelInfo.new GroupUser().setUserId(agentId).setGroupRole(1));
        }

        users.add(channelInfo.new GroupUser().setUserId("bot").setGroupRole(2));
        users.add(channelInfo.new GroupUser().setUserId(MobiComUserPreference.getInstance(context).getUserId()).setGroupRole(3));

        if (botIds != null) {
            for (String botId : botIds) {
                if (botId != null && !"bot".equals(botId)) {
                    users.add(channelInfo.new GroupUser().setUserId(botId).setGroupRole(2));
                }
            }
        }

        channelInfo.setType(10);
        channelInfo.setUsers(users);

        if (!agentIds.isEmpty()) {
            channelInfo.setAdmin(agentIds.get(0));
        }

        if (isUniqueChat) {
            channelInfo.setClientGroupId(getClientGroupId(MobiComUserPreference.getInstance(context).getUserId(), agentIds, botIds));
        }

        Map<String, String> metadata = new HashMap<String, String>();
        metadata.put("CREATE_GROUP_MESSAGE", "");
        metadata.put("REMOVE_MEMBER_MESSAGE", "");
        metadata.put("ADD_MEMBER_MESSAGE", "");
        metadata.put("JOIN_MEMBER_MESSAGE", "");
        metadata.put("GROUP_NAME_CHANGE_MESSAGE", "");
        metadata.put("GROUP_ICON_CHANGE_MESSAGE", "");
        metadata.put("GROUP_LEFT_MESSAGE", "");
        metadata.put("DELETED_GROUP_MESSAGE", "");
        metadata.put("GROUP_USER_ROLE_UPDATED_MESSAGE", "");
        metadata.put("GROUP_META_DATA_UPDATED_MESSAGE", "");
        metadata.put("HIDE", "true");

        channelInfo.setMetadata(metadata);

        if (handler == null) {
            handler = new KMStartChatHandler() {
                @Override
                public void onSuccess(Channel channel, Context context) {

                }

                @Override
                public void onFailure(ChannelFeedApiResponse channelFeedApiResponse, Context context) {

                }
            };
        }

        new AlChannelCreateAsyncTask(context, channelInfo, handler).execute();
    }

    private static String getClientGroupId(String userId, List<String> agentIds, List<String> botIds) throws KmException {

        if (agentIds == null || agentIds.isEmpty()) {
            throw new KmException("Please add at-least one Agent");
        }

        Collections.sort(agentIds);

        List<String> tempList = new ArrayList<String>(agentIds);
        tempList.add(userId);

        if (botIds != null && !botIds.isEmpty()) {
            if (botIds.contains("bot")) {
                botIds.remove("bot");
            }
            Collections.sort(botIds);
            tempList.addAll(botIds);
        }

        StringBuilder sb = new StringBuilder();

        Iterator<String> iterator = tempList.iterator();

        while (iterator.hasNext()) {
            String temp = iterator.next();
            sb.append(temp);

            if (!temp.equals(tempList.get(tempList.size() - 1))) {
                sb.append("_");
            }
        }

        if (sb.toString().length() > 255) {
            throw new KmException("Please reduce the number of agents or bots");
        }

        return sb.toString();
    }
}
