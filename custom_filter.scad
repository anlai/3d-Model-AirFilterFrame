use <grid.scad>;

/* [rendering] */
// render the filter spacer
render_spacer=false;
// render the filter cartridge
render_filter=false;
// render the filter cartridge top
render_filter_top=false;

render_ghost=false;

/* [filter housing dimensions] */
// interior width of the box (side to side)
box_width = 120;
// interior depth of the box (front to back)
box_depth = 120;
// interior height of the box
box_height = 26;

/* [hepa filter dimensions] */
// hepa filter width
hepa_width = 109;
// hepa filter depth
hepa_depth = 109;
// hepa filter height
hepa_height = 15;

/* [custom filter settings] */

// custom filter width
custom_filter_width = -1;

// custom filter depth
custom_filter_depth = -1;

// custom filter_height
custom_filter_height = -1;

// filter wall thickness
filter_wall_thickness = 2;

// filter grid frame thickness
filter_frame_thickness = 15;

// multiplier on grid sizing
filter_frame_multiplier = .2;

// diameter of magnet being insert
filter_magnet_diameter = 10;

// height of magnet being insert
filter_magnet_height = 1;

/* [spacer settings] */
// fudge factor for spacer
fudge = 1;

/* [hidden] */
// filter calculated measurements
filter_width = custom_filter_width>0 ? custom_filter_width : hepa_width;
filter_depth = custom_filter_depth>0 ? custom_filter_depth : hepa_depth;
filter_height = custom_filter_height>0 ? custom_filter_height : box_height-hepa_height;

// magnet location calculations
magnet_offset = (filter_wall_thickness*.5+filter_magnet_diameter/2);
magnet_locations = [
    // corners
    [magnet_offset+filter_wall_thickness, magnet_offset+filter_wall_thickness],
    [filter_width-magnet_offset-filter_wall_thickness, magnet_offset+filter_wall_thickness],
    [magnet_offset+filter_wall_thickness,filter_depth-magnet_offset-filter_wall_thickness],
    [filter_width-magnet_offset-filter_wall_thickness,filter_depth-magnet_offset-filter_wall_thickness],
    // centers
    [filter_width/2, magnet_offset+filter_wall_thickness],
    [filter_width/2, filter_depth-magnet_offset-filter_wall_thickness],
    [magnet_offset+filter_wall_thickness, filter_depth/2],
    [filter_width-magnet_offset-filter_wall_thickness, filter_depth/2]
];
magnet_cover_thickness=1.5;

module custom_filter() {
    cavity_offset = 2*filter_wall_thickness;

    difference(){
        // shell
        cube([filter_width, filter_depth, filter_height]);

        // cut out the center cavity
        translate([filter_wall_thickness, filter_wall_thickness, filter_wall_thickness]){
            cube([filter_width-cavity_offset, filter_depth-cavity_offset, filter_height-cavity_offset]);
        }

        // cut out the grid holes
        translate([filter_width/2,filter_depth/2,filter_height/2+1]){
            invert_grid(filter_width-filter_frame_thickness, filter_depth-filter_frame_thickness,filter_height+4,filter_frame_multiplier);
        }
    }

    // add supports for magnets
    for (coord = magnet_locations)
        custom_filter_magnet_support(coord.x, coord.y);
}

// interior supports for the magnets
module custom_filter_magnet_support (x_offset,y_offset) {
    // height of the cylinder only on the interior of the filter
    cylinder_height = filter_height;
    cylinder_diameter = filter_magnet_diameter+(2*fudge);

    // render the cylinder
    translate([x_offset,y_offset]) {
        cylinder(h=cylinder_height,d=cylinder_diameter);        
    }
}

// hole for the magnet
module magnet_cavity(x_offset,y_offset,z_offset){
    translate([x_offset,y_offset,z_offset])
        cylinder(h=filter_magnet_height+fudge,d=filter_magnet_diameter+fudge);
}

// invert the grid so the holes cut out from the shell
module invert_grid(width,depth,height,frame_hole_multiplier) {
    difference(){
        cube([width, depth, height], true);
        translate([0,0,-1])
        grid(width+10, depth+10, gridThickness=height+1,sizeMultipler=frame_hole_multiplier);
    }
}

// separates the top
module custom_filter_top_cutout() {
    translate([0,0,filter_height-filter_wall_thickness]){
        cube([filter_width,filter_depth,filter_height]);
    }

    // add supports for magnets
    for (coord = magnet_locations)
        custom_filter_top_magnet_support(coord.x, coord.y);
}

module custom_filter_top_magnet_support(x_offset,y_offset) {
    cylinder_height = filter_magnet_height+fudge+(2*magnet_cover_thickness);
    cylinder_diameter = filter_magnet_diameter+(2*fudge);

    translate([x_offset,y_offset,filter_height-cylinder_height])
        cylinder(h=cylinder_height,d=cylinder_diameter);
}

// spacer that goes full depth front to back
module depth_spacer() {
    spacer_width = ((box_width-hepa_width)/2)-fudge;
    spacer_depth = box_depth-fudge;
    spacer_height = box_height-fudge;

    cube([spacer_width, spacer_depth, spacer_height]);
}

// spacer that goes full width side to side
module width_spacer() {
    spacer_width = box_width-fudge;
    spacer_depth = ((box_depth-hepa_depth)/2)-fudge;
    spacer_height = box_height-fudge;

    cube([spacer_width, spacer_depth, spacer_height]);
}

// final parts
module spacer() {
    depth_spacer();
    width_spacer();
    translate([box_width-(((box_width-hepa_width)/2-fudge)),0,0]) depth_spacer();
}

module filter() {
    difference(){
        custom_filter();
        translate([0,0,-1])
        custom_filter_top_cutout();

        // cut outs for the magnet cavities
        for(coord = magnet_locations)
            magnet_cavity(coord.x,coord.y,filter_height-(2*(filter_magnet_height+fudge)+3*(magnet_cover_thickness)));
    }
}

module filter_top() {
    // height of the lip all the way to the top of the filter
    lip_fudge = .25;
    lip_height = filter_magnet_height+fudge+(2*magnet_cover_thickness);
    lip_offset = filter_wall_thickness+lip_fudge;
    lip_height_offset = filter_height-lip_height;
    lip_thickness = 1.5;
    lip_width = filter_width-(2*filter_wall_thickness)-lip_fudge;
    lip_depth = filter_depth-(2*filter_wall_thickness)-lip_fudge;

    difference() {
        union() {
            // part that overlaps with the whole frame
            intersection() {
                custom_filter();
                custom_filter_top_cutout();
            }

            // front/back lips
            translate([lip_offset,lip_offset,lip_height_offset]) cube([lip_width,lip_thickness,lip_height]);
            translate([lip_offset,filter_depth-lip_thickness-lip_offset,lip_height_offset]) cube([lip_width,lip_thickness,lip_height]);

            // left/right lips
            translate([lip_offset,lip_offset,lip_height_offset]) cube([lip_thickness,lip_depth,lip_height]);
            translate([filter_width-lip_thickness-lip_offset,lip_offset,lip_height_offset]) cube([lip_thickness,lip_depth,lip_height]);

            // tab to make it easier to lift
            translate([0,filter_depth/8,filter_height-filter_wall_thickness]) cylinder(r=filter_wall_thickness,h=filter_wall_thickness,$fn=360);
        }

        // cut outs for the magnet cavities
        for (coord = magnet_locations)
            magnet_cavity(coord.x,coord.y,filter_height-(filter_magnet_height+fudge+magnet_cover_thickness));

        // clear out the spacing outside the lip
        translate([0,0,lip_height_offset]) cube([filter_width,lip_offset,lip_height-filter_wall_thickness]);
        translate([0,filter_depth-lip_offset,lip_height_offset]) cube([filter_width,lip_offset,lip_height-filter_wall_thickness]);
        translate([0,0,lip_height_offset]) cube([lip_offset,filter_depth,lip_height-filter_wall_thickness]);
        translate([filter_width-lip_offset,0,lip_height_offset]) cube([lip_offset,filter_depth,lip_height-filter_wall_thickness]);
    }    
}

if (render_spacer){
    spacer();
}

if (render_filter){
    filter();
    if (render_ghost) %filter_top();
}

if (render_filter_top){
    rotate([180,0,0]) filter_top();
}