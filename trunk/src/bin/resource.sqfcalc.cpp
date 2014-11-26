// OFP
// Predefined controls
#define IDC_OK 1
#define IDC_CANCEL 2
#define IDC_AUTOCANCEL 3

// Control types
#define CT_STATIC 0
#define CT_BUTTON 1
#define CT_EDIT 2
#define CT_SLIDER 3
#define CT_COMBO 4
#define CT_LISTBOX 5
#define CT_TOOLBOX 6
#define CT_CHECKBOXES 7
#define CT_PROGRESS 8
#define CT_HTML 9
#define CT_STATIC_SKEW 10
#define CT_ACTIVETEXT 11
#define CT_TREE 12
#define CT_3DSTATIC 20
#define CT_3DACTIVETEXT 21
#define CT_3DLISTBOX 22
#define CT_3DHTML 23
#define CT_3DSLIDER 24
#define CT_3DEDIT 25
#define CT_OBJECT 80
#define CT_OBJECT_ZOOM 81
#define CT_OBJECT_CONTAINER 82
#define CT_OBJECT_CONT_ANIM 83
#define CT_USER 99

// Static styles
#define ST_HPOS 0x0F
#define ST_LEFT 0
#define ST_RIGHT 1
#define ST_CENTER 2
#define ST_UP 3
#define ST_DOWN 4
#define ST_VCENTER 5

#define ST_TYPE 0xF0
#define ST_SINGLE 0
#define ST_MULTI 16
#define ST_TITLE_BAR 32
#define ST_PICTURE 48
#define ST_FRAME 64
#define ST_BACKGROUND 80
#define ST_GROUP_BOX 96
#define ST_GROUP_BOX2 112
#define ST_HUD_BACKGROUND 128
#define ST_TILE_PICTURE 144
#define ST_WITH_RECT 160
#define ST_LINE 176

#define ST_SHADOW 256
#define ST_NO_RECT 512

#define ST_TITLE ST_TITLE_BAR + ST_CENTER

// Slider styles
#define SL_DIR 0x01
#define SL_VERT 0
#define SL_HORZ 1

#define FontS "tahomaB24"
#define FontM "tahomaB36"

#define FontHTML "courierNewB64"
#define FontHTMLBold "courierNewB64"
#define FontMAP "courierNewB64"
#define FontMAIN "SteelfishB64"
#define FontMAINCZ "SteelfishB64CE"
#define FontTITLE "SteelfishB128"
#define FontTITLEHalf "SteelfishB64"
#define FontBOOK "garamond64"
#define FontNOTES "AudreysHandI48"

// Tree styles
#define TR_SHOWROOT 1
#define TR_AUTOCOLLAPSE 2

// MessageBox styles
#define MB_BUTTON_OK 1
#define MB_BUTTON_CANCEL 2

// My definitions
#define DEFAULTFONT FontM
#define SIZEEX 0.017
#define BTNH   0.02
#define LINEH  0.020
#define LINEV  0.005
#define PIX    (1/1024)

#define WINDOW(T,X,Y,W,H) \
    idd=-1;\
    class _1_: VDMJ_RscTitle {x=##X##-PIX*7; y=##Y##-PIX*4; w=##W##+PIX*13; h=##H##+PIX*4; };\
    class _2_: VDMJ_RscTitleGround {text=T; x=##X##; y=##Y##; w=##W##; h=0.03; };\
    class _3_: VDMJ_RscGround {text=""; x=##X##; y=##Y##+0.03; w=##W##; h=##H##-0.03; };


#define WIN_CTRL _1_,_2_,_3_

class RscVDMJSqfCalc {
    class VDMJ_RscCommonStyle {
        idc = -1;
        x = .001;
        y = .001;
        w = .002;
        h = .002;
        text = ;
        action = ;
        font = FontM;
        style = ST_LEFT;
        sizeEx = SIZEEX;
        color[] = {1, 1, 1, 1};
        colorText[] = {1, 1, 1, 1};
        colorActive[] = {.8, .9, .3, 1};
        colorBackground[] = {0, 0, 0, 0};
        colorSelection[] = {.2, .2, .2, 1};
        colorSelect[] = {0, .05, .05, 1};
        colorSelectBackground[] = {.2, .2, .2, 1};
        soundEnter[] = {"ui\ui_over", .2, 1};
        soundPush[] = {, .2, 1};
        soundClick[] = {"ui\ui_ok", .2, 1};
        soundEscape[] = {"ui\ui_cc", .2, 1};
        default = false;
        autocomplete = false;
        rowHeight = .02;
        wholeHeight = .3;
    };

    class VDMJ_RscText: VDMJ_RscCommonStyle {
        type = CT_STATIC;
    };
    class VDMJ_RscTextMulti: VDMJ_RscText {
        style = ST_MULTI;
        lineSpacing = 1;
    };
    class VDMJ_RscTitle: VDMJ_RscText {
        style = ST_TITLE;
    };
    class VDMJ_RscFrame: VDMJ_RscText {
        style = ST_FRAME;
    };
    class VDMJ_RscGround: VDMJ_RscText {
        colorBackground[] = {0, .05, .08, .7};
    };
    class VDMJ_RscTitleGround: VDMJ_RscText {
        colorBackground[] = {0, .05, .08, .75};
    };
    class VDMJ_RscLink: VDMJ_RscCommonStyle {
        type = CT_ACTIVETEXT;
        style = ST_CENTER;
    };
    class VDMJ_RscEdit: VDMJ_RscCommonStyle {
        type = CT_EDIT;
    };
    class VDMJ_RscListBox: VDMJ_RscCommonStyle {
        type = CT_LISTBOX;
    };

    movingEnable = true;
    WINDOW($STR/SQFCALC/NAME,0.2,0.3,0.62,0.55)
    controlsBackground[] = { WIN_CTRL, TypeStringChecking };
    controls[] = { Input, DisplayList, DisplayEdit, DisplayFrame, EvalButton, FormattedModeButton, ShowTypesModeButton };

    class TypeStringChecking : VDMJ_RscText {
        idc = 98743;
    };
    class Input : VDMJ_RscEdit {
        idc = 100;
        x = 0.21; y = 0.35; w = 0.6; h = 0.03;
        autocomplete = "scripting";
    };

    #define DISPLAYPOS x = 0.21; y = 0.42; w = 0.6; h = 0.4

    class DisplayList : VDMJ_RscListBox {
        idc = 103;
        DISPLAYPOS;
    };

    class DisplayEdit : VDMJ_RscTextMulti {
        idc = 104;
        type = CT_EDIT;
        DISPLAYPOS;
    };

    class DisplayFrame : VDMJ_RscFrame {
        idc = 105;
        DISPLAYPOS;
    };

    class EvalButton : VDMJ_RscLink {
        idc = 106;
        x = 0; y = 0; w = 0; h = 0;
        text = "";
        action = "0 exec {\vdmj_sqfcalc\eval.sqs}";
        default = 1;
    };

    class FormattedModeButton : VDMJ_RscLink {
        idc = 107;
        x = 0.21; y = .385; w = 0.138; h = 0.03;
        style = ST_LEFT;
        text = "$STR/SQFCALC/FORMATTED-ON";
        action = "ctrlSetText [107, localize (if (ctrlText 107 == localize {STR/SQFCALC/FORMATTED-ON}) then { ctrlShow [103, false]; ctrlShow [104, true]; {STR/SQFCALC/FORMATTED-OFF} } else { ctrlShow [104, false]; ctrlShow [103, true]; {STR/SQFCALC/FORMATTED-ON} })]";
    };

    class ShowTypesModeButton : VDMJ_RscLink {
        idc = 108;
        x = 0.348; y = .385; w = 0.4; h = 0.03;
        style = ST_LEFT;
        text = "$STR/SQFCALC/SHOW-TYPES-ON";
        action = "ctrlSetText [108, localize (if(ctrlText 108 == localize {STR/SQFCALC/SHOW-TYPES-ON}) then { {STR/SQFCALC/SHOW-TYPES-MODE-OFF} } else { {STR/SQFCALC/SHOW-TYPES-ON} })]";
    };
};
