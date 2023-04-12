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

module pulley(teeth = 40, height = 12) {
    additional_tooth_width = 0.2; //mm
    additional_tooth_depth = 0.2; //mm

    
    pulley_OD = (2*((teeth*2)/(3.14159265*2)-0.254));
    tooth_depth = 0.764;
    tooth_width = 1.494;
    
	tooth_distance_from_centre = sqrt( pow(pulley_OD/2,2) - pow((tooth_width+additional_tooth_width)/2,2));
	tooth_width_scale = (tooth_width + additional_tooth_width ) / tooth_width;
	tooth_depth_scale = ((tooth_depth + additional_tooth_depth ) / tooth_depth) ;

    module GT2_2mm() {
        linear_extrude(height=height+2) polygon([[0.747183,-0.5],[0.747183,0],[0.647876,0.037218],
        [0.598311,0.130528],[0.578556,0.238423],[0.547158,0.343077],[0.504649,0.443762],[0.451556,0.53975],
        [0.358229,0.636924],[0.2484,0.707276],[0.127259,0.750044],[0,0.76447],[-0.127259,0.750044],
        [-0.2484,0.707276],[-0.358229,0.636924],[-0.451556,0.53975],[-0.504797,0.443762],[-0.547291,0.343077],
        [-0.578605,0.238423],[-0.598311,0.130528],[-0.648009,0.037218],[-0.747183,0],[-0.747183,-0.5]]);
    }

	difference() {	
		rotate ([0,0,360/(teeth*4)]) 
		cylinder(r=pulley_OD/2,h=height, $fn=teeth*4);
	
		//teeth - cut out of shaft
		
		for(i=[1:teeth]) 
        rotate([0,0,i*(360/teeth)]) 
        translate([0,-tooth_distance_from_centre,-1]) 
        scale ([ tooth_width_scale , tooth_depth_scale , 1 ]) 
        {
         GT2_2mm();
        }
	}		
}

module spacer (height = 50, width = 3, hole = shaft_d) {
	difference() {
		cylinder(h = height, d = hole + 2 * width, center = true);
		cylinder(h = height + 1, d = hole, center = true);
	};
}

module arm_side (lenght = 180, width = 30, height = 5, narrowing = true, gear_h = 10, teeth = 40) {
	module body() {
		cube([lenght, width, height], center = true);
		translate([lenght / 2, 0, 0]) 
            cylinder(h = height, d = width, center = true);		
		translate([-lenght / 2, 0, 0]) 
			cylinder(h = height, d = width, center = true);
	}

	module holes() {
		translate([lenght / 2, 0, 0]) 
			cylinder(h = height + 1, d = bearing_d, center = true);
		translate([-lenght / 2, 0, gear_h / 2]) 
			cylinder(h = height + gear_h + 1, d = shaft_d, center = true);
		mirror2([1,0,0]) 
            translate([width / 2, 0, 0]) 
				cylinder(h = height + 1, d = screw_d, center = true);
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
            translate([-lenght / 2,0,height / 2])
                pulley(teeth = teeth, height = gear_h);
		};
		union(){
			holes();
			if(narrowing == true) { 
				side_cuts();
			}
		};	
	};
}

module end(lenght = 50, height = 30, width = 20, gear_w = 10, teeth = 40) {
	module center() {
		translate([lenght / 2 - height / 4, 0, 0])
			cube([lenght - height / 2, width - gear_w, height], center = true);
		rotate([90,0,0])
			cylinder(h = width - gear_w, d = height, center = true);
		
	}
    
	module sides() {
		difference() {
			translate([(lenght - height / 2 )/ 2, 0, 0])
				cube([lenght - height / 2, width, height], center = true);
			rotate([90,0,0])
				cylinder(h = width + 1, d = (2*((teeth*2)/(3.14159265*2)-0.254)) + 1, center = true);
            mirror2([0,0,1])
                rotate([0,-45,0])
                translate([height / 2, 0, height / 2])
                cube([height, width + 1, height], center = true);
		}
	}
	
	difference() {
		union() {
            translate([0,gear_w / 2,0])
                center();
            translate([0, -(width - gear_w-gear_w) / 2,0])
                rotate([90,0,0])
                pulley(teeth = teeth, height = gear_w);
			sides();
		}
		union() {
			rotate([90,45 / 2,0])
				cylinder(h = width + 1, d = shaft_d, center = true);
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


//spacer(height = 29);
arm_side();

//end();
//motor();
//body();


/*
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