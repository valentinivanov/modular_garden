include <common.scad>;
include <shell.scad>;
include <insert.scad>;
include <foot.scad>;
include <foot_cap.scad>;

top_row_y = insert_length/2 + preview_gap/2;
bottom_row_y = -foot_size/2 - preview_gap/2;
left_col_x = -shell_width/2 - preview_gap/2;
right_col_x = insert_width/2 + preview_gap/2;

translate([left_col_x, top_row_y, 0]) shell();
translate([right_col_x, top_row_y, 0]) insert();
translate([left_col_x, bottom_row_y, 0]) foot();
translate([right_col_x, bottom_row_y, 0]) foot_cap(
    size=foot_size,
    wall=foot_wall,
    thickness=foot_cap_thickness,
    ledge_height=foot_cap_ledge_height,
    clearance=foot_cap_clearance
);
