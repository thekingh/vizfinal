float SPRING_CONST = 1500;
float GBUNDLE_CONST = 200000;
float BUNDLE_CONST = GBUNDLE_CONST;
int NUM_SUBS = 4;
float DAMPCONST = 0.7;
float DIST_COEFF_DENOM = max(width,height);
boolean SHOW_ORIGINAL = false;
float STARTUP_TIME = 100;
float MAG_CUTOFF = 4;
float COEFF_CUTOFF = 0.7;
float CP_MIN_DIST = 5;

boolean BEZLINE = true && false;
boolean DRAW_BUNDLE_FORCE = false;
boolean LENSWITCH = true;
boolean ANGLESWITCH = true;
boolean DISTSWITCH = true;

float NODE_COLOR = #666666;
float NODE_RADIUS = 5;
float EDGE_WEIGHT = 1;

float MIN_CONSTRAINT_DISTANCE = 100.0;
boolean DEBUG_CONSTR_ON = true;
