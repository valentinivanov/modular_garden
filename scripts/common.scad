include <BOSL2/std.scad>;

cm_scale = 10;
preview_gap = 4 * cm_scale;

// Shared dimension chain used by multiple objects.
shell_wall = 0.15 * cm_scale;
shell_width = 16 * cm_scale;
shell_length = 18 * cm_scale;
shell_height = 11 * cm_scale;
shell_rounding = 0.3 * cm_scale;
shell_dovetail_height = 22 * cm_scale;
shell_dovetail_depth = 0.5 * cm_scale;
shell_dovetail_bottom_width = 0.5 * cm_scale;
shell_dovetail_top_width = 1.5 * cm_scale;
shell_dovetail_top_offset = 2 * cm_scale;
shell_dovetail_length = shell_dovetail_height - shell_dovetail_top_offset;
shell_perforation_rows = 3;
shell_perforation_hex_id = 0.7 * cm_scale;
shell_perforation_spacing_x = 1.2 * cm_scale;
shell_perforation_spacing_y = 0.9 * cm_scale;
shell_perforation_keepout = shell_dovetail_top_width + shell_perforation_spacing_x;

insert_clearance = 0.1 * cm_scale;
insert_wall = 0.15 * cm_scale;
insert_height = 21 * cm_scale;
insert_rounding = 0.3 * cm_scale;
insert_drain_margin = 2 * cm_scale;
insert_truncation_size = 3 * cm_scale;

insert_width = shell_width - 2*shell_wall - 2*insert_clearance;
insert_length = shell_length - 2*shell_wall - 2*insert_clearance;
insert_body_height = insert_height;
insert_inner_half_width = insert_width/2 - insert_wall;
insert_inner_half_length = insert_length/2 - insert_wall;
insert_inner_truncation_size = max(0, insert_truncation_size - insert_wall * (2 - sqrt(2)));
insert_drain_x = 0;
insert_drain_y = 0;
insert_drain_size = max(0, min(
    2 * (insert_inner_half_width - insert_drain_margin),
    2 * (insert_inner_half_length - insert_drain_margin)
));

foot_clearance = 0.05 * cm_scale;
foot_wall = 0.16 * cm_scale;
foot_hole_id = (0.55 / 2) * cm_scale;
foot_rows = 8;
foot_hole_spacing = 0.6 * cm_scale;
foot_rib_count = 4;
foot_rib_length = 1.5 * cm_scale;
foot_rib_thickness = 0.3 * cm_scale;
foot_rib_height = 2.7 * cm_scale;
foot_wall_above_ribs = 0.6 * cm_scale;
foot_snap_head_height = 0.3 * cm_scale;
foot_snap_head_length = 0.2 * cm_scale;
foot_snap_head_slope_end = 0.05 * cm_scale;
foot_slice_width = 0.1 * cm_scale;
foot_height = foot_rib_height + foot_wall_above_ribs;
foot_size = insert_drain_size - 2*foot_clearance;

insert_drain_border_width = 0.3 * cm_scale;
insert_drain_border_clearance = foot_clearance;
insert_drain_border_height = max(
    0,
    foot_height - foot_snap_head_height - foot_rib_height - insert_drain_border_clearance
);
insert_drain_ridge_width = 0.3 * cm_scale;
insert_drain_ridge_count = 5;
insert_drain_ridge_ramp_height = 0.3 * cm_scale;
insert_drain_ridge_ramp_length = 0.3 * cm_scale;

foot_cap_thickness = foot_wall;
foot_cap_ledge_height = 0.4 * cm_scale;
foot_cap_clearance = 0.05 * cm_scale;
foot_cap_hole_diameter = 0.4 * cm_scale;
foot_cap_hole_spacing = 1.2 * cm_scale;

module hex_cut_x(hole_id, depth) {
    yrot(90)
        linear_extrude(height=depth, center=true)
            hexagon(id=hole_id);
}

module hex_cut_y(hole_id, depth) {
    xrot(-90)
        linear_extrude(height=depth, center=true)
            hexagon(id=hole_id);
}
