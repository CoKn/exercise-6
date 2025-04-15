// personal assistant agent

broadcast(jason).

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: true (the plan is always applicable)
 * Body: greets the user
*/
@start_plan
+!start : true <-
    .print("Hello world");
    createArtifact("room.MQTTArtifact", "personal_assistant", []);
    focus("personal_assistant", "room.MQTTArtifact");
    .print("MQTTArtifact created and focused").

+!wakeUpUser : true <-
    .print("Sending message via MQTT");
    sendMsg("personal_assistant", "tell", "Upcoming event").

+mqtt_message(Sender, Performa, Content) : Performa == tell <-
    .print("Received MQTT message from ", Sender, " with content: ", Content).

+owner_state(State) : true <-
    .print("Received owner state: ", State).

+upcoming_event(Event) : true <-
    .print("Received upcoming event: ", Event).

+blinds(State) : true <-
    .print("Received blinds state: ", State).

+lights(State) : true <-
    .print("Received lights state: ", State).


/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }