
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

// Bohrung 1
dbohr1=6.25; // [5.0:0.1:25.0]
// Bohrung 2
dbohr2=6.25; // [5.0:0.1:25.0]

// Überstand Mitte Loch bis Ende Busbar
ueberstand = 10.0; // [0.0:0.1:50]

// 3d Druck Anordnung
for_print = false;

/* [Hidden] */
$fa=0.1; // max fragments of a circle
$fs=0.5; // segment length of circle min long

// Blechstärke insgesamt
sblech = blechdicke + 0.5;    // erwin calb+eve

hbohr=10;

d = blechdicke * 4; // kleiner radius
dout = d+2*sblech; // äußerer radius
dmid = d + sblech; // mittlerer radius

h = hbuegel - d - 2*sblech;
l = abstandbolzen/2 - (dout/2+d/2);
echo(h=h, l=l);

lges = 2 * (ueberstand + l + dmid*PI/ + h); // ausgangs-länge blech 
echo(d=d, dout=dout, dmid=dmid);
echo(blechdicke=blechdicke, mit_toleranz=sblech);
echo(abstandbolzen=abstandbolzen, breite=breite);
echo(lges0=lges);
echo(querschnitt1=breite*(sblech-0.5));

lw = 0.8;

hboden = 7*lw;
hupper = 10*lw+hbuegel;
hseit = hboden + hbuegel + 5;

module rundung(dr) {
    difference(){
        cube([dr/2, dr/2, breite+0.001]);
        cylinder(d=dr, h=breite);
    }
}

module lowerbusbar0(mitnase) {

    hull() {
        cylinder(d=d, h=breite);
         translate([-d/2, -(hbuegel - sblech -d/2)])
           cube([d, 1, breite]);
    }
    translate([0, -(hbuegel - sblech - d/2 + hboden)])
        cube([lges/2, hboden, breite]);

    translate([d/2+dout/2, -(hbuegel - sblech -d/2 - dout/2 + 0.0001)])
        rotate([0, 0, 180])
            rundung(dr=dout);

    // seitlicher anschlag
    translate([lges/2, -(hbuegel - sblech - d/2 + hboden)])
        cube([0.5, hboden, breite]);
    translate([lges/2+0.5, -(hbuegel - sblech - d/2 + hboden)])
        cube([5*lw, hseit, breite]);

    if (mitnase) {
        translate([lges/2+0.5, -(hbuegel - sblech - d/2 + hboden), breite/2])
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
        translate([lges/2+0.5-10, d/2+sblech-hseit+5])
            cube([10+5*lw, hseit, 3]);
        translate([-lges/2-0.5, d/2+sblech-hseit+5])
            cube([10+5*lw, hseit, 3]);
    }
}

module upperbusbar0() {

    difference() {
        translate([0, 0])
                cube([lges/2, hupper, breite]);
        translate([0, hbuegel - (sblech + dout/2)])
            hull() {
                cylinder(d=dout, h=breite+0.001);
                translate([-dout/2, -hbuegel + dout/2])
                    cube([dout, 1, breite]);
            }
        translate([dout/2 + d/2 - 0.0001, d/2 - 0.0001])
            rotate([0, 0, 180])
                rundung(dr=d);

        translate([lges/2, 0, breite/2])
          rotate([-90, 0])
            cylinder(d=10*lw+0.5, h=50);
    }
}

module upperbusbar() {

    difference() {
        union() {
            upperbusbar0();
            mirror([1, 0])
                upperbusbar0();
        }
        bohrungen();
    }
}

module bohrungen() {
    translate([abstandbolzen/2, 0, breite/2])
        rotate([-90]) {
            cylinder(d=dbohr1, h=50);
            translate([0, 0, 5])
                cylinder(d=dbohr1*1.5, h=hbohr);
        }
    translate([-abstandbolzen/2, 0, breite/2])
        rotate([-90]) {
            cylinder(d=dbohr2, h=50);
            translate([0, 0, 5])
                cylinder(d=dbohr1*1.5, h=hbohr);
        }
}

lowerbusbarmitrand();
if (for_print) {
    // für druck
    translate([0, hseit/2+5, -3.5])
        upperbusbar();
}
else {
    upperbusbar();
}



