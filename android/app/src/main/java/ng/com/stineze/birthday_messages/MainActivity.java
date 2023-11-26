package ng.com.stineze.birthday_messages;
import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.telephony.SmsManager;
import android.telephony.SubscriptionInfo;
import android.telephony.SubscriptionManager;
import android.telephony.TelephonyManager;

import java.util.ArrayList;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;


/** @noinspection rawtypes*/
public class MainActivity extends FlutterActivity {

    public int selectedSim;
    public int activeSim;
    private SubscriptionManager subsManager;
    private SmsManager smsManager;
    private String carrier, carrier1, carrier2, activeCarrier, providers, shortCode, on, off;
    private Context context;
    private final String[] PERMISSIONS = new String[]{
            Manifest.permission.INTERNET,
            Manifest.permission.SEND_SMS,
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.READ_PHONE_NUMBERS,
            Manifest.permission.READ_SMS,
    };
    private int simCount = 0;
    private int activeSimCount = 0;
    Map<String, String> simProperties = new HashMap<>();

    private static final String CHANNEL = "my_channel";

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        context = this;
        subsManager = this.getSystemService(SubscriptionManager.class);
        carrier = carrier1 = carrier2 = activeCarrier = providers = shortCode = on = off = "";
        int defaultSmsSimSlotIndex = getDefaultSmsSimSlotIndex();
        if (defaultSmsSimSlotIndex != -1) {
            afterSimChange(defaultSmsSimSlotIndex + 1);
        }
    }

    @Override
    @SuppressWarnings("unchecked")
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            switch (call.method) {
                                case "sendMessages":
                                    Map<String, Object> messagePack = call.arguments();
                                    //noinspection DataFlowIssue
                                    int smsSim = (int) messagePack.get("SimSlot");
                                    List<List<Object>> listOfListsRaw = (List<List<Object>>) messagePack.get("messages");
                                    assert listOfListsRaw != null;
                                    List<List<String>> messages = convertList(listOfListsRaw);
                                    sendMessages(smsSim, messages, result);
                                    result.success("Messages received successfully");
                                    break;
                                case "getSimProperties":
                                    String simProperties = getSimProperties();
                                    result.success(simProperties);
                                    break;
                                default:
                                    result.notImplemented();
                            }
                        }
                );
    }


    private void callDartMethod(String methodName, String optionalParam) {
        MethodChannel methodChannel = new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL);
        methodChannel.invokeMethod(methodName, optionalParam);
    }

    private void callDartMethod(String methodName) {
        MethodChannel methodChannel = new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL);
        methodChannel.invokeMethod(methodName, null);
    }


    private List<List<String>> convertList(List<List<Object>> rawList) {
        List<List<String>> result = new ArrayList<>();

        for (List<Object> innerList : rawList) {
            List<String> convertedInnerList = new ArrayList<>();
            for (Object obj : innerList) {
                convertedInnerList.add((String) obj);
            }
            result.add(convertedInnerList);
        }
        return result;
    }


    private void setActiveSimCount(){

        TelephonyManager telephonyManager = (TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE);
        SubscriptionManager subscriptionManager = context.getSystemService(SubscriptionManager.class);
        int defaultSmsSubscriptionId = SubscriptionManager.getDefaultSmsSubscriptionId();
        int count = 0;
        if (defaultSmsSubscriptionId != SubscriptionManager.INVALID_SUBSCRIPTION_ID) {
            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
                callDartMethod("getPermissions");
            }
            List<SubscriptionInfo> subscriptionInfoList = subscriptionManager.getActiveSubscriptionInfoList();
            if (subscriptionInfoList == null || subscriptionInfoList.isEmpty()) {
                simCount = 0;
            } else {

                for (SubscriptionInfo subscriptionInfo : subscriptionInfoList) {
                    int slotIndex = subscriptionInfo.getSimSlotIndex();
                    // Use slotIndex as needed

                    int simState = telephonyManager.getSimState(slotIndex);
                    if (simState != TelephonyManager.SIM_STATE_ABSENT) {
                        count += 1;
                    }
                }
            }
            activeSimCount = count;
        }

    }
    private String getSimProperties() {
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
            callDartMethod("getPermissions");
        }
        simProperties = new HashMap<>();
        String slot = String.valueOf(getDefaultSmsSimSlotIndex() + 1);
        subsManager = this.getSystemService(SubscriptionManager.class);
        simCount = subsManager.getActiveSubscriptionInfoCount();
        setActiveSimCount();
        String simValues = simCount + "@" + slot + "@" + activeSimCount;
        simProperties.put("Sim1 Label", "");
        simProperties.put("Sim2 Label", "");
        simProperties.put("Sim1 State", "");
        simProperties.put("Sim2 State", "");
        simProperties.put("Sim1 Number", "");
        simProperties.put("Sim2 Number", "");
        simProperties.put("SimValues", simValues);

        if (simCount > 1) {
            dualSimsInfo();
        } else {
            singleSimInfo();
        }

        StringBuilder finalProperties = new StringBuilder();
        simProperties.forEach((key, value) -> {
            String thisPair = key + "@@@" + value;
            finalProperties.append(thisPair).append("\n");
        });

        if (finalProperties.length() > 0) {
            finalProperties.setLength(finalProperties.length() - 1);
        }

        return finalProperties.toString();
    }


    private void sendMessages(int simSlot, List<List<String>> messages, MethodChannel.Result result) {
        try {
            smsManager = getSmsManager(simSlot - 1);
        } catch (Exception e) {
            int slot = getDefaultSmsSimSlotIndex();
            smsManager = getSmsManager(slot);
        }
        String phone, message;
        for (List pack : messages) {
            phone = (String) pack.get(0);
            message = (String) pack.get(1);
            sendTheMessage(smsManager, phone, message);
        }
        result.success("Messages sent successfully");
    }


    void sendTheMessage(SmsManager smsManager, String phone, String message) {
        smsManager.sendTextMessage(phone, null, message, null, null);
    }


    private SmsManager getSmsManager(int slotIndex) {
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
            callDartMethod("getPermissions");
        }
        SubscriptionInfo localSubsInfo = subsManager.getActiveSubscriptionInfoForSimSlotIndex(slotIndex);
        smsManager = getApplicationContext().getSystemService(SmsManager.class).createForSubscriptionId(localSubsInfo.getSubscriptionId());
        return smsManager;
    }


    private void afterSimChange(int chosenSim) {
        activeSim = selectedSim = chosenSim;
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
            callDartMethod("getPermissions");
        }
        simCount = subsManager.getActiveSubscriptionInfoCount();
        assignSims();
        setActiveSimProperties();
    }

    private void assignSims() {
        if (simCount > 1) {
            dualSimsInfo();
            getActiveSim();
        } else {
            singleSimInfo();
        }
    }

    private void setActiveSimProperties() {
        String dCarrier = "";
        if (!activeCarrier.equals("")) {
            if (activeCarrier.contains(" ")) {
                dCarrier = activeCarrier.split(" ")[0].toUpperCase();
            } else if (activeCarrier.contains("-")) {
                dCarrier = activeCarrier.split("-")[0].toUpperCase();
            } else {
                dCarrier = activeCarrier.toUpperCase();
            }
        }
        if (dCarrier.contains("-")) {
            dCarrier = dCarrier.split("-")[0].toUpperCase();
        }
    }


    public int getDefaultSmsSimSlotIndex() {
        SubscriptionManager subscriptionManager = context.getSystemService(SubscriptionManager.class);
        int defaultSmsSubscriptionId = SubscriptionManager.getDefaultSmsSubscriptionId();

        if (defaultSmsSubscriptionId != SubscriptionManager.INVALID_SUBSCRIPTION_ID) {
            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
                callDartMethod("getPermissions");
            }

            List<SubscriptionInfo> activeSubscriptionInfoList = subscriptionManager.getActiveSubscriptionInfoList();
            if (activeSubscriptionInfoList != null) {
                TelephonyManager telephonyManager = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
                if (telephonyManager != null) {
                    for (SubscriptionInfo subscriptionInfo : activeSubscriptionInfoList) {
                        if (subscriptionInfo.getSubscriptionId() == defaultSmsSubscriptionId) {
                            // Found the SIM slot index for the default SMS subscription
                            return subscriptionInfo.getSimSlotIndex();
                        }
                    }
                }
            } else {
                return -1;
            }
        }
        // If not found or any issues, return -1 or handle accordingly
        return -1;

    }


    private void getActiveSim() {
        int simIndex = selectedSim - 1;
        int slot;
        if (simIndex != -1) {
            activeSim = selectedSim;
            slot = activeSim + 1;
            if (slot == 1) {
                activeCarrier = carrier1;
            } else {
                activeCarrier = carrier2;
            }
        }
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
            callDartMethod("getPermissions");
        }
        SubscriptionInfo localSubsInfo = subsManager.getActiveSubscriptionInfoForSimSlotIndex(simIndex);
        smsManager = getApplicationContext().getSystemService(SmsManager.class)
                .createForSubscriptionId(localSubsInfo.getSubscriptionId());

    }


    private void dualSimsInfo() {
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
            callDartMethod("getPermissions");
        }
        List<SubscriptionInfo> list = subsManager.getActiveSubscriptionInfoList();
        SubscriptionInfo subsInfo1 = list.get(0);
        SubscriptionInfo subsInfo2 = list.get(1);
        String phone1 = subsInfo1.getNumber();
        String phone2 = subsInfo2.getNumber();
        String carrier1 = subsInfo1.getDisplayName().toString();
        String carrier2 = subsInfo2.getDisplayName().toString();
        String sim1State = "true";
        String sim2State = "true";
        simProperties.replace("Sim1 Number", phone1);
        simProperties.replace("Sim2 Number", phone2);
        simProperties.replace("Sim1 Label", carrier1);
        simProperties.replace("Sim2 Label", carrier2);
        simProperties.replace("Sim1 State", sim1State);
        simProperties.replace("Sim2 State", sim2State);
    }

    private void singleSimInfo() {
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
            callDartMethod("getPermissions");
        }
        SubscriptionInfo subsInfo = subsManager.getActiveSubscriptionInfo(SubscriptionManager.getDefaultSmsSubscriptionId());
        String phone = subsInfo.getNumber();
        String carrier = subsInfo.getDisplayName().toString();
        int slot = subsInfo.getSimSlotIndex();
        int simSlot = slot + 1;
        smsManager = getApplicationContext().getSystemService(SmsManager.class);
        if (simSlot == 1) {
            String carrier1 = carrier;
            String sim1State = "true";
            String sim2State = "false";
            simProperties.replace("Sim1 Number", phone);
            simProperties.replace("Sim1 Label", carrier1);
            simProperties.replace("Sim1 State", sim1State);
            simProperties.replace("Sim2 State", sim2State);
        } else {
            String carrier2 = carrier;
            String sim1State = "false";
            String sim2State = "true";
            simProperties.replace("Sim2 Number", phone);
            simProperties.replace("Sim2 Label", carrier2);
            simProperties.replace("Sim1 State", sim1State);
            simProperties.replace("Sim2 State", sim2State);
        }
    }



}
