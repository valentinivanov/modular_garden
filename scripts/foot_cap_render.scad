include <common.scad>;
include <foot_cap.scad>;

foot_cap(
    size=foot_size,
    wall=foot_wall,
    thickness=foot_cap_thickness,
    ledge_height=foot_cap_ledge_height,
    clearance=foot_cap_clearance
);
