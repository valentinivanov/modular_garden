module foot_cap(size=3, wall=0.16, thickness=0.16, ledge_height=0.4, clearance=0.05) {
    inner_size = size - 2*wall;
    ledge_outer_size = max(0, inner_size - 2*clearance);
    ledge_inner_size = max(0, ledge_outer_size - 2*wall);

    difference() {
        union() {
            cuboid([size, size, thickness], anchor=BOT);

            up(thickness)
                difference() {
                    cuboid([ledge_outer_size, ledge_outer_size, ledge_height], anchor=BOT);
                    down(0.01)
                        cuboid([ledge_inner_size, ledge_inner_size, ledge_height + 0.02], anchor=BOT);
                }
        }

        for (x = [-foot_cap_hole_spacing, 0, foot_cap_hole_spacing], y = [-foot_cap_hole_spacing, 0, foot_cap_hole_spacing]) {
            translate([x, y, -0.01])
                cyl(d=foot_cap_hole_diameter, h=thickness + 0.02, anchor=BOT, $fn=64);
        }
    }
}
