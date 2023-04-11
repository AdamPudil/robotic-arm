lever_w = 10;
lever_l = 25;

bearing_d = 16;
bearing_h = 5;
shaft_d = 8;

screw_d = 3.2; 

motor_d = 25;

$fn = 100;

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

module pull_lever (angle = 90, lenght_a = 25, lenght_b = 25, width = 8, height = 5) {
    module lever(lenght) {
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

			lever(lenght = lenght_a);
			if(angle >= 15 || angle <= -15) {
				rotate([0,0,angle])
					lever(lenght_b);
			}
        };
        cylinder(h = height + 1, d = bearing_d, center = true);
	};
}

module motor_lever ( lenght = 25, width = 8, height = 6) {
    module lever() {
		cylinder(h = height, d = center_diameter, center = true);
		translate([lenght / 2, 0, 0]) 
			cube([lenght, width, height], center = true);
		translate([lenght, 0, 0]) 
			cylinder(h = height, d = width, center = true);
	}
	module holes() {
        cylinder(h = height + 1, d = hole, center = true);
        translate([0, 7, 0])
            cube([5.4, 2.4, 7], center = true);
        translate([0, 10, 0])
            rotate([90,00,0])
                cylinder(h = 20, d = screw_d, center = true);
        translate([lenght, 0, 0]) 
			cylinder(h = height + 1, d = screw_d, center = true);
	}
	
	hole = 4.4;
    ofset = 0.5;
    center_diameter = 24;

    difference() {
        lever();
        holes();
    };
}

module spacer (height = 50, width = 3, hole = shaft_d) {
	difference() {
		cylinder(h = height, d = hole + 2 * width, center = true);
		cylinder(h = height + 1, d = hole, center = true);
	};
}

module arm_side (lenght = 180, width = 30, height = 5, angle = 0, spacer = 1, narrowing = true, rounded = true) {
	module body() {
		cube([lenght, width, height], center = true);
		translate([lenght / 2, 0, 0]) 
			rotate([0,0,30]) 
				if(rounded) 
					cylinder(h = height, d = width, center = true);
				else 
					cylinder(h = height, d = width, center = true, $fn = 6);
					
		translate([-lenght / 2, 0, 0]) 
			cylinder(h = height, d = width, center = true);
		translate([lenght / 2,0,(height + spacer) / 2])
			cylinder(h = spacer, d = shaft_d + 6, center = true);
	}
	
	module arm() {
		translate([-lenght / 2, 0, 0]) 
				rotate([0,0,angle])
					union(){
						translate([lever_l / 2, 0, 0]) 
							cube([lever_l, lever_w, height], center = true);
						translate([lever_l, 0, 0]) 
							cylinder(h = height, d = lever_w, center = true);
					};
	}

	module holes() {
		translate([lenght / 2, 0, spacer / 2]) 
					cylinder(h = height + spacer + 1, d = shaft_d, center = true);
			translate([-lenght / 2, 0, 0]) 
					cylinder(h = height + 1, d = bearing_d, center = true);
			translate([-lenght / 2, 0, 0]) 
				rotate([0,0,angle])
					translate([lever_l, 0, 0]) 
						cylinder(h = height + 1, d = screw_d, center = true);
			mirror2([1,0,0]) {
                translate([width / 2, 0, 0]) 
					cylinder(h = height + 1, d = screw_d, center = true);
			}
	}

	module side_cuts() {
		mirror2([0,1,0]) {
                linear_extrude(height = height + 1, center = true) {
                    polygon([[lenght/2 - 10, width/2+1], 
                            [-lenght/2 + 20, width/2+1],
                            [ -lenght/2 + 30, width/2 - 3],
                            [lenght/2 - 20, width/2 - 3]]);
                }
            }
	}

	translate([lenght / 2, 0, 0]) 
	difference() {
		union() {
			body();
			arm();
		};
		union(){
			holes();
			if(narrowing == true) { 
				side_cuts();
			}
		};	
	};
}

module end(lenght = 50, width = 30, center_w = 15, angle = 45) {
	module center() {
		translate([lenght / 2 - width / 4, 0, 0])
			cube([lenght - width / 2, center_w, width], center = true);
		rotate([90,0,0])
			cylinder(h = center_w, d = width, center = true);
		// pull rod attach point
		translate([0, 0, 0])
			difference() {
				rotate([-90,180-angle,0]) {
				// lever
					translate([-lever_l, 0, 0]) 
						cylinder(h = 5, d = lever_w, center = true);
					// round lever end
					translate([-lever_l / 2, 0, 0]) 
						cube([lever_l, lever_w, 5], center = true);
					if(angle <= 45) {
						translate([(-lever_l - lever_w)  / 2, -5, 0]) 
							cube([lever_l, 10 , 5], center = true);
					}
				}
				rotate([-90,180-angle,0])
					translate([-lever_l, 0, 0]) 
						cylinder(h = 5 + 1, d = screw_d, center = true);	
			}
	}
	module sides() {
		difference() {
			translate([(lenght - width / 2 + 12) / 2, 0, 0])
				cube([lenght - width / 2 - 12, width, width], center = true);
			rotate([90,0,0])
				cylinder(h = width + 1, d = width + 4, center = true);
			rotate([90,0,0]) 
				linear_extrude(height = width + 1, center = true)
				polygon([[0,0],[28,20],[0,20]]);
			mirror([0,0,1])
				rotate([90,0,0]) 
				linear_extrude(height = width + 1, center = true)
				polygon([[0,0],[20,20],[0,20]]);
		}
	}
	module bearing_hole() {
		difference() {
			union() {
				rotate([0,-45,0])
					translate([bearing_d / 4, (center_w - bearing_h + 1) / 2, bearing_d / 4])
					cube([bearing_d / 2, bearing_h + 1, bearing_d / 2], center = true);
				translate([0,(center_w - bearing_h + 1) / 2,0])
					rotate([90,0,0])
					cylinder(h = bearing_h + 1, d = bearing_d, center = true);
			}
			translate([0, 0, (bearing_d + 10) / 2])
			cube([bearing_d ,center_w + 2 , 10], center = true);
		}
	}
	
	difference() {
		union() {
			center();
			sides();
		}
		union() {
			mirror2([0,1,0])
				bearing_hole();
			rotate([90,45 / 2,0])
				cylinder(h = bearing_h + 1, d = shaft_d * 1.5, center = true, $fn = 8);
		}
	}
}

module motor() {
		motor_d = 28;
		motor_l = 60; 
		shaft_d = 7;
		screw_ch_w = 1;
		screw_ch_h = 2;
		screw_pos = 17 / 2;
		
		height = 3;
		
		translate([0, 0, - motor_l / 2])
			cylinder(h = motor_l, d = motor_d, center = true);
		translate([0, 0, height / 2])
			cylinder(h = height + 1, d = shaft_d, center = true);
		mirror2([1,0,0]) {
			translate([screw_pos, 0, 0])
				union(){
					translate([0, 0, height / 2])
						cylinder(h = height + 1, d = screw_d, center = true);
					translate([0, 0, height + 0.25])
						cylinder(h = 0.5, d = screw_d + 2 * screw_ch_w,
								center = true);
					translate([0, 0, 0])
						rotate_extrude() 
							polygon([[ screw_d / 2,height - screw_ch_h],
									[0,height - screw_ch_h],
									[0,height],
									[ screw_d / 2 + screw_ch_w,height]]);
						
					};
		}
	}


module body() {
    height = 60;
    arm_width = 55;
    
    module side_holder() {
        difference() {
            union() {
                translate([0,0,-height / 2])
                    cube([30,5,height], center = true);
                rotate([90,0,0])
                    cylinder(h = 5, d = 30, center = true);
                }
            
            rotate([90,0,0])
                    cylinder(h = 6, d = shaft_d, center = true);
        }
    }
    
    module stabilizer() {
        difference() {
            union() {
                translate([-20,0,-height / 2])
                    cube([40,5,height], center = true);
                translate([-40,0,-height / 2])
                    cube([10,5,height], center = true);
                translate([-40,0,0])
                    rotate([90,0,0])
                    cylinder(h = 5, d = 10, center = true);
            }
            union() {
                translate([-40,0,0])
                    rotate([90,0,0])
                    cylinder(h = 6, d = screw_d, center = true);
                rotate([90,0,0])
                    cylinder(h = 6, r = 35, center = true);
            }
        }   
    }
    
    module center() {
        difference() {
            union() {
                translate([0,0,(-height - 35) / 2])
                      cube([5,arm_width ,height - 35], center = true);
                translate([0,0,-height + (5 / 2)])
                      cube([30,arm_width ,5], center = true);
            }
        }
    }
    
    module motor_back() {
        translate([-20,-17,(-height - 35) / 2])
            cube([40, 5, height - 35], center = true);
        translate([-20,-8.5,-height + (5 / 2)])
            cube([40, 12, 5], center = true);
    }
    
    module motor_front() {
        translate([20,5,(-height - 35) / 2])
            cube([40, 5, height - 35], center = true);
    }
    
    difference() {
        union() {
            center();
            stabilizer();
            motor_front();
            motor_back();
            mirror2([0,1,0]) 
                translate([0, arm_width / 2 + 2.5,0])
                    side_holder();
        }
        union() {
            translate([-25,-16.5,-45])
                rotate([90,0,0])
                motor();
            translate([25,4.5,-45])
                rotate([-90,0,0])
                motor();
            
        }
    }
}
//---------//
// testing //
//---------//

//pull_rod();
//pull_rod(lenght = 51.5);
//pull_lever(angle = 20);
//motor_lever();
//spacer(height = 29);
//arm_side(angle = 90);
//end(angle = 90);
//motor();
body();


    
translate([0,11,0])
    rotate([90,0,0])
    color("red")
    pull_lever(angle = 20);

translate([0,-6,0])
    rotate([90,0,0])
    color("blue")
    spacer(height = 29);

translate([0,17,0])
    rotate([90,0,0])
    color("blue")
    spacer(height = 7);

mirror2([0,1,0])
    translate([0,26.5,0])
    rotate([90,0,0])
    color("green")
    spacer(height = 2);

mirror2([0,1,0])
    translate([0,23,0])
    rotate([90,-90,0])
    color("red")
    arm_side(angle = 90);
    //*/