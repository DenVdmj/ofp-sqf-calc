// SQF

//
// Controls IDC & display mode control
//

#define IDC_Input         100
#define IDC_DisplayText   102
#define IDC_DisplayList   103
#define IDC_DisplayEdit   104
#define IDC_DisplayFrame  105
#define IDC_EvalButton    106
#define IDC_FormattedButton 107
#define IDC_ShowTypesButton 108

#define arg(i) (_this select (i))
#define log2(num) ((log(num))/.3010299956639812)
#define floor(num) (num - num % 1)
#define ceil(num) (num - num % 1 + (if (num % 1 != 0) then {1} else {0}))

// save local names scope
private "_ourContext";

_ourContext = [
    // self variable
    "_ourContext",
    // functions
    "_fSetDisplayMode",
    "_fGetVarType",
    "_fIsNil",
    "_fJoinString",
    "_fParseTree",
    "_fValueToString",
    "_fValueToFormatString",
    "_fValueFormat",
    // varialbes
    "_typesTable",
    "_evalResult",
    "_emptyDetector",
    "_sideUnknown"
];

private _ourContext;

//
// Native data types
//
#define ARRAY_TYPE     0
#define GROUP_TYPE     1
#define OBJECT_TYPE    2
#define SIDE_TYPE      3
#define BOOL_TYPE      4
#define STRING_TYPE    5
#define NUMBER_TYPE    6
#define UNKNOWN_TYPE   7
#define UNDEFINED_TYPE 8

// syntax: [_type, _value] call _fValueToString
_fValueToString = {
    #define __fValueToString__fValueFormat (_typesTable select (arg(0) * 2 + 1))
    [arg(1)] call __fValueToString__fValueFormat
};

// syntax: [_type, _value, _showTypeFlag] call _fValueToFormatString
_fValueToFormatString = {
    #define __fValueToFormatString__typeName (_typesTable select (arg(0) * 2))
    #define __fValueToFormatString__fValueFormat (_typesTable select (arg(0) * 2 + 1))
    (if (arg(2)) then {
        __fValueToFormatString__typeName + ": "
    } else {
        ""
    }) + ([arg(1)] call __fValueToFormatString__fValueFormat)
};

_fValueFormat = {
    format ["%1", arg(0)]
};

_typesTable = [
//  type, format function
    "ARRAY",     _fValueFormat,
    "GROUP",     _fValueFormat,
    "OBJECT",    _fValueFormat,
    "SIDE",      _fValueFormat,
    "BOOL",      _fValueFormat,
    "STRING",    { """" + arg(0) + """" },
    "NUMBER",    _fValueFormat,
    "UNKNOWN",   _fValueFormat,
    "UNDEFINED", _fValueFormat
];

_fGetVarType = {
    if (_this in [1e+999, -1e+999, 1e+999-1e+999]) then { NUMBER_TYPE } else {
        if (!(_this in [_this])) then { ARRAY_TYPE } else {
            if (_this in [true, false]) then { BOOL_TYPE } else {
                if (_this in [east, west, resistance, civilian, sideFriendly, sideEnemy, sideLogic, side objNull]) then { SIDE_TYPE } else {
                    if (_this in [""]) then { STRING_TYPE } else {
                        ctrlSetText [98743, ""];
                        ctrlSetText [98743, _this];
                        if (ctrlText 98743 != "") then { STRING_TYPE } else {
                            if ((("all" countType [_this]) != 0) || (_this in [grpNull, objNull]) || (format ["%1", _this] in ["NOID empty", "NOID camera"])) then {
                                if (_this in [group leader _this]) then { GROUP_TYPE } else { OBJECT_TYPE }
                            } else {
                                if (_this - _this == 0) then { NUMBER_TYPE } else { UNKNOWN_TYPE }
                            }
                        }
                    }
                }
            }
        }
    }
};

_fIsNil = {
    private "_result";
    _result = true;
    arg(0) call { _result = false };
    _result
};

/*
_fJoinString = {
    private "_str";
    _str = "";
    { _str = _str + _x } foreach _this;
    _str
};
*/

_fJoinString = {
    private ["_list", "_size", "_subsize", "_oversize", "_i", "_j"];
    _list = _this;
    if (count _list < 1) then {
        ""
    } else {
        while { count _list > 1 } do {
            _size = count _list / 2;
            _subsize = floor(_size);
            _oversize = ceil(_size);
            _i = 0;
            _j = 0;
            while { _i < _subsize } do {
                 _list set [_i,
                     (_list select (_j  )) +
                     (_list select (_j+1))
                 ];
                 _i = _i + 1;
                 _j = _j + 2;
            };
            if (_subsize != _oversize) then {
                _list set [_j/2, _list select _j];
            };
            _list resize _oversize;
        };
        _list select 0
    }
};


_fParseTree = {
    // Arguments:
    // [ value or values tree, base text indent, callback functions for : event Scalar, event ArrayOpen, event ArrayClose ],
    // functions context space: _value, _depth, _comma, _indent, _type
    // (comment: current value, current depth, needs comma, current indent, type of current value)
    private ["_input", "_baseIndent", "_ehScalar", "_ehArrayOpen", "_ehArrayClose", "_fWalkTree"];

    _fWalkTree = {
        // arguments: current value, current depth, current indent, needs comma
        private ["_value", "_depth", "_indent", "_comma", "_type", "_i"];
        _value  = arg(0);
        _depth  = arg(1);
        _indent = arg(2);
        _comma  = arg(3);
        if ([_value] call _fIsNil) then {
            _type = UNDEFINED_TYPE;
            call _ehScalar;
        };

        _type = _value call _fGetVarType;

        if (_type == ARRAY_TYPE) then {
            _i = count _value;
            call _ehArrayOpen;
            {
                _i = _i-1;
                [_x, _depth+1, _indent+_baseIndent, ["", ","] select (_i != 0)] call _fWalkTree
            } foreach _value;
            call _ehArrayClose;
        } else {
            call _ehScalar
        };
    };

    _input = arg(0);
    _baseIndent = arg(1);
    _ehScalar = arg(2);
    _ehArrayOpen = arg(3);
    _ehArrayClose = arg(4);

    [_input, 0, "", ""] call _fWalkTree;
};

_fSetDisplayMode = {
    // disable all excepting inquired
    {
        ctrlShow [_x, _x == _this]
    } foreach [IDC_DisplayText, IDC_DisplayList, IDC_DisplayEdit];

    // frame for multiline display
    ctrlShow [IDC_DisplayFrame, IDC_DisplayText == _this];
};

// eval user input, with protection our context
_evalResult = call {
    private _ourContext;
    [] call ctrlText IDC_Input
};

call {

    private ["_isShowTypesOn", "_isFormattedOn"];

    _isShowTypesOn = ctrlText IDC_ShowTypesButton == localize "STR/SQFCALC/SHOW-TYPES-ON";
    _isFormattedOn = ctrlText IDC_FormattedButton == localize "STR/SQFCALC/FORMATTED-ON";

    lbClear IDC_DisplayList;

    ([IDC_DisplayEdit, IDC_DisplayList] select _isFormattedOn) call _fSetDisplayMode;

    private "_resultArray";
    _resultArray = [];
    [
        _evalResult, "    ",
        // variables: _value, _depth, _comma, _indent, _type
        {
            _resultArray set [count _resultArray, ([_type, _value] call _fValueToString) + _comma];
            lbAdd [IDC_DisplayList, _indent + ([_type, _value, _isShowTypesOn] call _fValueToFormatString) + _comma];
        },
        {
            _resultArray set [count _resultArray, "["];
            lbAdd [IDC_DisplayList, _indent + "[" ];
        },
        {
            _resultArray set [count _resultArray, "]" + _comma];
            lbAdd [IDC_DisplayList, _indent + "]" + _comma];
        }
    ] call _fParseTree;

    ctrlSetText [IDC_DisplayEdit, _resultArray call _fJoinString];
};

