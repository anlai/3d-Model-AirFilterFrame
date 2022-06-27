module grid(width=193,depth=88,roundness=4.5,gridThickness=5,sizeMultipler=1) {
    grid_gap = 0.5;
    
    border = 1.7;
    hex_d =  14*sizeMultipler; //7;//14;
    
    x_sep =  10.5*sizeMultipler; //5.25;//10.5;
    y_sep = 0;
    
    x_shift = x_sep + hex_d;
    y_shift = y_sep + hex_d;
    
    hlf_width = width/2;
    hlf_depth = depth/2;
    
    edgeOffset = (gridThickness-2)*.5;
    
    // outer edge
    translate([0,0,-edgeOffset])
    difference() {
        round_cube([width-grid_gap*2, depth-grid_gap*2, gridThickness], roundness-1, $fn=40);
        translate([0,0,-1])
        round_cube([width-grid_gap*2-border*2, depth-grid_gap*2-border*2, gridThickness*2], roundness-1, $fn=40);
    }
    
    
    difference() {
        translate([0,0,1])
        cube([width-grid_gap*2-border*2, depth-grid_gap*2-border*2, gridThickness], center=true);
        
        x_steps = floor((hlf_width - border/2) / x_shift);
        y_steps = floor(hlf_depth / y_shift);
        
        for(x = [-x_steps : x_steps],
            y = [-y_steps : y_steps]) {
        
            translate([x_shift*x,y_shift*y,0])
            cylinder(d=hex_d, h=gridThickness*3, center=true, $fn=6);
        }
        
        alt_x_steps = floor((hlf_width - x_shift/2 - border/2) / x_shift);
        alt_y_steps = floor((hlf_depth - y_shift/2) / y_shift);
        
        for(x = [ -alt_x_steps - 1 : alt_x_steps ],
            y = [ -alt_y_steps - 1 : alt_y_steps ]) {
        
            translate([x_shift*x,y_shift*y,0])
            translate([x_shift/2,y_shift/2,0])
            cylinder(d=hex_d, h=gridThickness*3, center=true, $fn=6);
        }
    }
}

module round_cube(coords, r=0) {
        
    if (r<=0) {
        translate([0,0,coords[2]/2])
        cube(coords, center=true);
    } else {
    
        x = coords[0];
        y = coords[1];
        z = coords[2];
        hull() {
            translate([ x/2 - r,  y/2 - r]) cylinder(r=r, h=z);
            translate([-x/2 + r,  y/2 - r]) cylinder(r=r, h=z);
            translate([ x/2 - r, -y/2 + r]) cylinder(r=r, h=z);
            translate([-x/2 + r, -y/2 + r]) cylinder(r=r, h=z);
        }

    }   
}