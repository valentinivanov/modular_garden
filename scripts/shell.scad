module shell_dovetail_profile(bottom_width, depth) {
    polygon([
        [-0.3 * bottom_width, 0],
        [ 0.3 * bottom_width, 0],
        [ 0.5 * bottom_width, depth],
        [-0.5 * bottom_width, depth]
    ]);
}

module shell_dovetail(bottom_width=shell_dovetail_bottom_width, top_width=shell_dovetail_top_width, depth=shell_dovetail_depth) {
    top_scale = bottom_width / top_width;

    linear_extrude(height=shell_dovetail_length, scale=[top_scale, 1])
        shell_dovetail_profile(top_width, depth);
}

module shell_dovetail_backer(top_width=shell_dovetail_top_width, bottom_width=shell_dovetail_top_width * 2, depth=shell_wall, top_corner_radius=shell_rounding, corner_steps=8) {
    backer_height = shell_dovetail_length - shell_height;
    corner_radius = min(top_corner_radius, min(top_width / 2, backer_height));

    if (backer_height > 0) {
        translate([0, 0, shell_height])
            xrot(90)
                linear_extrude(height=depth)
                    polygon(concat(
                        [
                            [-bottom_width/2, 0],
                            [ bottom_width/2, 0],
                            [ top_width/2, backer_height - corner_radius]
                        ],
                        [
                            for (angle = [0:90/corner_steps:90])
                                [
                                    (top_width/2 - corner_radius) + corner_radius * cos(angle),
                                    (backer_height - corner_radius) + corner_radius * sin(angle)
                                ]
                        ],
                        [
                            [-top_width/2 + corner_radius, backer_height]
                        ],
                        [
                            for (angle = [90:90/corner_steps:180])
                                [
                                    (-top_width/2 + corner_radius) + corner_radius * cos(angle),
                                    (backer_height - corner_radius) + corner_radius * sin(angle)
                                ]
                        ]
                    ));
    }
}

module shell_perforation_strip(span, rows, hole_id, spacing_x, spacing_y, depth, center_keepout=0, cut_axis="y") {
    half_span = span / 2;
    edge_margin = hole_id / 2;
    columns = max(1, floor((span - hole_id) / spacing_x) + 1);
    x_origin = -((columns - 1) * spacing_x) / 2;

    for (row = [0:rows-1]) {
        z = shell_height - shell_wall - hole_id/2 - row * spacing_y;
        row_shift = (row % 2 == 0) ? 0 : spacing_x / 2;

        if (z >= shell_wall + hole_id/2) {
            for (col = [0:columns-1]) {
                x = x_origin + col * spacing_x + row_shift;

                if (
                    abs(x) <= half_span - edge_margin &&
                    abs(x) >= center_keepout/2 + edge_margin
                ) {
                    if (cut_axis == "x") {
                        translate([0, x, z])
                            hex_cut_x(hole_id, depth);
                    } else {
                        translate([x, 0, z])
                            hex_cut_y(hole_id, depth);
                    }
                }
            }
        }
    }
}

module shell_perforations(rows=shell_perforation_rows, hole_id=shell_perforation_hex_id, spacing_x=shell_perforation_spacing_x, spacing_y=shell_perforation_spacing_y) {
    face_depth = shell_wall * 4;
    front_back_span = max(shell_width - 2*shell_rounding, 0);
    side_span = max(shell_length - 2*shell_rounding, 0);

    if (rows > 0 && hole_id > 0 && spacing_x > 0 && spacing_y > 0) {
        for (y_sign = [-1, 1]) {
            translate([0, y_sign * (shell_length/2 - shell_wall/2), 0])
                shell_perforation_strip(front_back_span, rows, hole_id, spacing_x, spacing_y, face_depth, shell_perforation_keepout, "y");
        }

        for (x_sign = [-1, 1]) {
            translate([x_sign * (shell_width/2 - shell_wall/2), 0, 0])
                shell_perforation_strip(side_span, rows, hole_id, spacing_x, spacing_y, face_depth, shell_perforation_keepout, "x");
        }
    }
}

module shell() {
    union() {
        difference() {
            cuboid([shell_width, shell_length, shell_height], rounding=shell_rounding, edges="Z", anchor=BOT, $fn=64);
            union() {
                up(shell_wall)
                    cuboid(
                        [shell_width - 2*shell_wall, shell_length - 2*shell_wall, shell_height],
                        rounding=shell_rounding,
                        edges="Z",
                        anchor=BOT,
                        $fn=64
                    );

                shell_perforations();
            }
        }

        translate([0, shell_length/2, 0]) shell_dovetail_backer();
        translate([0, -shell_length/2, 0]) mirror([0, 1, 0]) shell_dovetail_backer();
        translate([shell_width/2, 0, 0]) zrot(-90) shell_dovetail_backer();
        translate([-shell_width/2, 0, 0]) zrot(90) shell_dovetail_backer();

        translate([0, shell_length/2, 0]) shell_dovetail();
        translate([0, -shell_length/2, 0]) mirror([0, 1, 0]) shell_dovetail();
        translate([shell_width/2, 0, 0]) zrot(-90) shell_dovetail();
        translate([-shell_width/2, 0, 0]) zrot(90) shell_dovetail();
    }
}
