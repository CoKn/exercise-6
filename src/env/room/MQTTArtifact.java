package room;

import cartago.Artifact;
import cartago.INTERNAL_OPERATION;
import cartago.OPERATION;
import org.eclipse.paho.client.mqttv3.*;

/**
 * A CArtAgO artifact that provides an operation for sending messages to agents 
 * with KQML performatives using the dweet.io API
 */
public class MQTTArtifact extends Artifact {

    MqttClient client;
    String broker = "tcp://test.mosquitto.org:1883";
    String clientId; //TODO: Initialize in init method.
    String topic = "epic-topic"; //TODO: change topic name to make it specific to you.
    int qos = 2;

    public void init(String name){
        //TODO: subscribe to the right topic of the MQTT broker and add observable properties for perceived messages (using a custom MQTTCallack class, and the addMessage internal operation).
        //The name is used for the clientId.
        this.clientId = name;
        try {
            client = new MqttClient(broker, clientId);
            MqttConnectOptions opts = new MqttConnectOptions();
            opts.setCleanSession(true);
            client.connect(opts);
            
            // Custom callback
            client.setCallback(new MQTTCallbackImpl(this));
            
            // Subscribe to QoS.
            client.subscribe(topic, qos);
            
            // Observable property 
            defineObsProperty("status", "connected");
        } catch (MqttException e) {
            System.err.println("Error initializing MQTT client: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @OPERATION
    public void sendMsg(String agent, String performative, String content){
        //TODO: complete operation to send messages

        String messagePayload = agent + "," + performative + "," + content;
        MqttMessage msg = new MqttMessage(messagePayload.getBytes());
        msg.setQos(qos);
        try {
            client.publish(topic, msg);
        } catch (MqttException e) {
            System.err.println("Error publishing MQTT message: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @INTERNAL_OPERATION
    public void addMessage(String agent, String performative, String content){
        //TODO: complete to add a new observable property.
        defineObsProperty("mqtt_message", agent, performative, content);
    }

    //TODO: create a custom callback class from MQTTCallack to process received messages
    private class MQTTCallbackImpl implements MqttCallback {
        private MQTTArtifact artifact;

        public MQTTCallbackImpl(MQTTArtifact artifact) {
            this.artifact = artifact;
        }

        @Override
        public void connectionLost(Throwable cause) {
            System.err.println("MQTT connection lost: " + cause.getMessage());
            // Optionally implement reconnection logic here.
        }

        @Override
        public void messageArrived(String topic, MqttMessage message) throws Exception {
            String payload = new String(message.getPayload());
            // Expect message format: "sender,performative,content"
            String[] parts = payload.split(",");
            if (parts.length == 3) {
                artifact.addMessage(parts[0], parts[1], parts[2]);
            } else {
                System.err.println("Received malformed MQTT message: " + payload);
            }
        }

        @Override
        public void deliveryComplete(IMqttDeliveryToken token) {
        }
    }
    
}
