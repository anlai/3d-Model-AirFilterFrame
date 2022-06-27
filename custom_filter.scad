use <grid.scad>;

/* [rendering] */
// render the filter spacer
render_spacer=false;
// render the filter cartridge
render_filter=false;
// render the filter cartridge top
render_filter_top=false;

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
filter_wall_thickness = 3;

// filter grid frame thickness
filter_frame_thickness = 15;

// multiplier on grid sizing
filter_frame_multiplier = .5;

/* [spacer settings] */
// fudge factor for spacer
spacer_fudge = 1;


// filter calculated measurements
filter_width = custom_filter_width>0 ? custom_filter_width : hepa_width;
filter_depth = custom_filter_depth>0 ? custom_filter_depth : hepa_depth;
filter_height = custom_filter_height>0 ? custom_filter_height : box_height-hepa_height;

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
}

// spacer that goes full depth front to back
module depth_spacer() {
    spacer_width = ((box_width-hepa_width)/2)-spacer_fudge;
    spacer_depth = box_depth-spacer_fudge;
    spacer_height = box_height-spacer_fudge;

    cube([spacer_width, spacer_depth, spacer_height]);
}

// spacer that goes full width side to side
module width_spacer() {
    spacer_width = box_width-spacer_fudge;
    spacer_depth = ((box_depth-hepa_depth)/2)-spacer_fudge;
    spacer_height = box_height-spacer_fudge;

    cube([spacer_width, spacer_depth, spacer_height]);
}

if (render_spacer){
    depth_spacer();
    width_spacer();
}

if (render_filter){
    difference(){
        custom_filter();
        custom_filter_top_cutout();
    }
}

if (render_filter_top){
    intersection(){
        custom_filter();
        custom_filter_top_cutout();
    }
}
