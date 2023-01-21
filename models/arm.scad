lever_w = 10;
lever_l = 25;

bearing_d = 16;
shaft_d = 8;

screw_d = 3.2; 

// macros
module mirror2(v) {
    children();
    mirror(v) children();
}

// modules
module pull_rod (lenght = 180, width = 8, height = 3) {
    difference() {
        union() {
            cube([lenght, width, height], center = true);
            mirror2([1,0,0]) {
                translate([lenght / 2, 0, 0]) 
                    cylinder(h = height, d = width, center = true);
            }
        };
        mirror2([1,0,0]) {
            translate([lenght / 2, 0, 0]) 
                cylinder(h = height + 1, d = screw_d, center = true);
        }
    };
}

module pull_lever (angle = 90, lenght = 25, width = 8, height = 5) {
    module lever() {
		difference(){
			union() {
				translate([lenght / 2, 0, 0]) 
					cube([lenght, width, height], center = true);
				translate([lenght, 0, 0]) 
					cylinder(h = height, d = width, center = true);
			}
			translate([lenght, 0, 0]) 
				cylinder(h = height + 1, d = screw_d, center = true);
		}
	}

	center_diameter = 28;

    difference() {
        union() {
        	cylinder(h = height, d = center_diameter, center = true);

			lever();
			if(angle >= 15 || angle <= -15) {
				rotate([0,0,angle])
					lever();
			}
        };
        cylinder(h = height + 1, d = bearing_d, center = true);
	};
}

// testing
//pull_rod();
pull_lever();