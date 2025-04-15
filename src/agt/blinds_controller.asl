// blinds controller agent

/* Initial beliefs */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds (was:Blinds)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/blinds.ttl").

// the agent initially believes that the blinds are "lowered"
blinds("lowered").

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:Blinds is located at Url
 * Body: greets the user
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds", Url) <-
    .print("Hello world");
    createArtifact("room.MQTTArtifact", "blinds_controller", []);
    focus("blinds_controller", "room.MQTTArtifact");
    .print("MQTTArtifact created and focused for blinds_controller");
    makeArtifact("blinds_device", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], ArtId);
    .print("Blinds control ThingArtifact created").

+mqtt_message(Sender, Performa, Content) : Performa == tell <-
    .print("blinds_controller received MQTT message from ", Sender, " with content: ", Content).

+!initBlindsControl : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds", Url) <-
    makeArtifact("blinds_device", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], ArtId);
    .print("Blinds control ThingArtifact created").

+!raiseBlinds : true <-
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState", ["raised"]);
    -+blinds(_);
    +blinds("raised");
    .print("Blinds raised");
    .send(personal_assistant, tell, blinds(raised)).

+!lowerBlinds : true <-
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState", ["lowered"]);
    -+blinds(_);
    +blinds("lowered");
    .print("Blinds lowered");
    .send(personal_assistant, tell, blinds(lowered)).


/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }