
class CfgPatches {
    class vdmj_sqfcalc {
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.76;
    };
};

class CfgVehicles {
    class All {};
    class vdmj_sqfcalc : All {
        displayName = "$STR/SQFCALC/DISPLAY-NAME";
        nameSound = "";
        scope = 2;
        vehicleClass = "Objects";
        simulation = "invisible";
        side = 7;
        icon = "marker_dot";
        model = "empty";
        picture = "";
        class EventHandlers {
            init = "player addAction [localize ""STR/SQFCALC/DISPLAY-NAME"", ""\vdmj_sqfcalc\open.sqs""]";
        };
    };
};
