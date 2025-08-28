
// 
// 
// Copyright erwin.rieger@ibieger.de 2025
// Attribution-NonCommercial-ShareAlike 4.0 International License, see LICENSE file.
// 
// Parametrisches OpenScad modell um Presswerkzeuge für
// flexible Busbars herzustellen (3D-Druck). 
// Siehe https://www.akkudoktor.net/t/3d-druck-pressform-fuer-flexible-busbars-lifepo4/31301.
// 
// 

//
// Customize parameters
//

// Blechstärke
blechdicke = 2.0; // [1.0:0.1:5.0]

// Höhe des bügels
hbuegel = 15; // [10:50]

// Eve 280k ist 72mm dick, plus 0.5mm isolierplatte = 72.5
// Abstand bolzen zelle
abstandbolzen = 72.5; // [40.0:0.1:150.0]

// Breite busbar
breite = 20; // [15:100]

// Bohrung
dbohrung=6.25; // [5.0:0.1:25.0]

// Länge gesamt im gebogenen zustand: abstandbolzen + 2*ueberstand
// Überstand Mitte Loch bis Ende Busbar
ueberstand = 10.0; // [0.0:0.1:50]

// 3d Druck Anordnung
for_print = false;

// Debug, blech länge im gebogenen zustand
debug = true;

/* [Hidden] */
$fa=0.1; // max fragments of a circle
$fs=0.5; // segment length of circle min long

toleranz = 0.5;
tolhalbe = toleranz / 2;

dinner_ut = blechdicke * 4;
douter_ut = dinner_ut+blechdicke;
dmid = (dinner_ut + blechdicke)/2 + (douter_ut + blechdicke)/2;

dinner_ot = dinner_ut - blechdicke - toleranz;
douter_ot = dinner_ut + 2*(blechdicke + toleranz);

h = hbuegel - dinner_ut/2;
l = (abstandbolzen - dinner_ut - douter_ut)/2;
echo(h=h, l=l);

lblech0 = 2 * (ueberstand + l + dmid*PI/2 + h); // ausgangs-länge blech 
laenge_gebogen=abstandbolzen + 2*ueberstand;

echo(dinner_ut=dinner_ut, douter_ut=douter_ut, dmid=dmid);
echo(blechdicke=blechdicke, mit_toleranz=blechdicke+toleranz);
echo(abstandbolzen=abstandbolzen, breite=breite);
echo(laenge_blech=lblech0, laenge_gebogen=laenge_gebogen);
echo(querschnitt1=breite*blechdicke);

lw = 0.8;

hboden = 7*lw;
hupper = 10*lw+hbuegel;
hseit = hboden + hbuegel + 5;

module rundung(dr) {
    difference(){
        cube([dr/2, dr/2, breite]);
        cylinder(d=dr, h=breite+0.001);
    }
}

module lowerbusbar0(mitnase) {

    hull() {
        cylinder(d=dinner_ut, h=breite);
        translate([-dinner_ut/2, -h])
           cube([dinner_ut, 1, breite]);
    }
    translate([0, -(h + hboden)])
        cube([lblech0/2, hboden, breite]);
    translate([dinner_ut/2+douter_ut/2, -h+douter_ut/2])
        rotate([0, 0, 180])
            rundung(dr=douter_ut);

    // seitlicher anschlag
    translate([lblech0/2, -(hboden+h)])
        cube([0.5, hboden, breite]);
    translate([lblech0/2+0.5, -(hboden+h)])
        cube([5*lw, hseit, breite]);

    if (mitnase) {
        translate([lblech0/2+0.5, -hseit+dinner_ut/2+5, breite/2])
          rotate([-90, 0])
            difference() {
              cylinder(d=10*lw, h=hseit);
              translate([-5*lw, -breite/2])
                cube([5*lw, breite, hseit-5]);
            }
    }
}

module lowerbusbar(mitnase=true) {
    lowerbusbar0(mitnase);
     mirror([1, 0])
        lowerbusbar0(mitnase);
}

module lowerbusbarmitrand() {
    lowerbusbar();
    translate([0, 0, -3.5]) {
        scale([1, 1, 3.5/breite])
            lowerbusbar(false);
        translate([lblech0/2+0.5-10, -(hboden+h)])
            cube([10+5*lw, hseit, 3]);
        translate([-lblech0/2-0.5, -(hboden+h)])
            cube([10+5*lw, hseit, 3]);
    }
}

module upperbusbar0() {

    difference() {
        translate([0, 0])
                cube([lblech0/2, hupper, breite]);
        translate([0, hbuegel - douter_ot/2])
            hull() {
                cylinder(d=douter_ot, h=breite+0.001);
                translate([-douter_ot/2, -hbuegel + douter_ot/2])
                    cube([douter_ot, 1, breite]);
            }
        translate([dinner_ot/2 + douter_ot/2, dinner_ot/2])
            rotate([0, 0, 180])
                rundung(dr=dinner_ot);

        translate([lblech0/2, 0, breite/2])
          rotate([-90, 0])
            cylinder(d=10*lw+0.5, h=50);

        // bohrungen
        translate([abstandbolzen/2, 0, breite/2])
            rotate([-90]) {
                cylinder(d=dbohrung, h=50);
                translate([0, 0, dbohrung])
                    cylinder(d=dbohrung*1.5, h=hseit);
            }
    }
}

module upperbusbar() {

    difference() {
        union() {
            upperbusbar0();
            mirror([1, 0])
                upperbusbar0();
        }
    }
}


module tube(h, r, wall) {

    difference() {
        cylinder(r=r, h=h);
        cylinder(r=r-wall, h=h);
    }
}

module busbar0() {

    translate([dinner_ut/2+douter_ut/2, -h+tolhalbe]) {
        cube([l+ueberstand, blechdicke, breite]);

        hh = h - douter_ut/2 + tolhalbe;
        if (hh > 0) 
            translate([-dinner_ut/2-blechdicke/2+tolhalbe, douter_ut/2-tolhalbe])
                cube([blechdicke, hh, breite]);

        rtub1 = douter_ot/2-tolhalbe;
        translate([rtub1-douter_ut/2+blechdicke+tolhalbe-2*rtub1, h-tolhalbe])
            intersection() {
                tube(h=breite, r=rtub1, wall=blechdicke);
                translate([-douter_ot/2, 0])
                    cube([douter_ot, rtub1, breite+0.001]);
            }

        rtub2 = douter_ut/2-tolhalbe;
        translate([0, rtub2])
            intersection() {
                tube(h=breite+0.001, r=rtub2, wall=blechdicke);
                translate([-douter_ut, -rtub2])
                    cube([douter_ut, rtub2, breite]);
            }
    }
}

module busbar() {
    busbar0();
    mirror([1, 0])
        busbar0();
}

lowerbusbarmitrand();

if (for_print) {
    // für druck
    translate([0, hseit/2+5, -3.5])
        upperbusbar();
}
else {
    translate([0, -h+blechdicke+toleranz, 0])
        upperbusbar();
    if (debug) {
        // busbar zur anschauung:
        color("red")
           busbar();
    }
}


