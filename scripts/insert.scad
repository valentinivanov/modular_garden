module chamfered_insert_profile(width, length, chamfer, rounding=0) {
    points = [
        [-width/2, -length/2],
        [ width/2, -length/2],
        [ width/2,  length/2 - chamfer],
        [ width/2 - chamfer, length/2],
        [-width/2,  length/2]
    ];

    if (rounding > 0)
        offset(r=rounding)
            offset(delta=-rounding)
                polygon(points);
    else
        polygon(points);
}

module insert_holes() {
    if (insert_drain_size > 0)
        translate([insert_drain_x, insert_drain_y, -0.01])
            cuboid([insert_drain_size, insert_drain_size, insert_wall + 0.02], anchor=BOT);
}

module insert_drain_border() {
    if (insert_drain_size > 0 && insert_drain_border_width > 0 && insert_drain_border_height > 0) {
        outer_size = insert_drain_size + 2*insert_drain_border_width;
        inner_size = insert_drain_size;

        translate([insert_drain_x, insert_drain_y, 0])
            difference() {
                cuboid([outer_size, outer_size, insert_drain_border_height], anchor=BOT);
                translate([0, 0, -0.01])
                    cuboid([inner_size, inner_size, insert_drain_border_height + 0.02], anchor=BOT);
            }
    }
}

module insert_drain_ridge_layout() {
    drain_half = insert_drain_size / 2;
    inner_half_width = insert_width/2 - insert_wall;
    inner_half_length = insert_length/2 - insert_wall;
    inner_profile_width = insert_width - 2*insert_wall;
    inner_profile_length = insert_length - 2*insert_wall;
    ridge_span = insert_drain_ridge_count > 1 ? insert_drain_size - insert_drain_ridge_width : 0;

    intersection() {
        chamfered_insert_profile(
            inner_profile_width,
            inner_profile_length,
            insert_inner_truncation_size,
            max(insert_rounding - insert_wall/2, 0.2)
        );

        union() {
            for (i = [0:insert_drain_ridge_count-1]) {
                offset = insert_drain_ridge_count > 1 ? -ridge_span/2 + i * ridge_span / (insert_drain_ridge_count - 1) : 0;

                translate([insert_drain_x + offset, insert_drain_y + (drain_half + inner_half_length)/2])
                    square([insert_drain_ridge_width, inner_half_length - drain_half], center=true);
                translate([insert_drain_x + offset, insert_drain_y - (drain_half + inner_half_length)/2])
                    square([insert_drain_ridge_width, inner_half_length - drain_half], center=true);
                translate([insert_drain_x + (drain_half + inner_half_width)/2, insert_drain_y + offset])
                    square([inner_half_width - drain_half, insert_drain_ridge_width], center=true);
                translate([insert_drain_x - (drain_half + inner_half_width)/2, insert_drain_y + offset])
                    square([inner_half_width - drain_half, insert_drain_ridge_width], center=true);
        }
    }
}
}

module insert_drain_ridges() {
    if (insert_drain_size > 0 && insert_drain_ridge_width > 0 && insert_drain_border_height > 0 && insert_drain_ridge_count > 0)
        linear_extrude(height=insert_drain_border_height)
            insert_drain_ridge_layout();
}

module insert_drain_ridge_ramp_y(width=0.3, length=0.3, ridge_height=0.25, wall_height=0.3, side=1) {
    y1 = -side * length;

    polyhedron(
        points=[
            [-width/2, 0, 0],
            [ width/2, 0, 0],
            [ width/2, y1, 0],
            [-width/2, y1, 0],
            [-width/2, 0, wall_height],
            [ width/2, 0, wall_height],
            [ width/2, y1, ridge_height],
            [-width/2, y1, ridge_height]
        ],
        faces=[
            [0, 1, 2, 3],
            [4, 7, 6, 5],
            [0, 4, 5, 1],
            [1, 5, 6, 2],
            [2, 6, 7, 3],
            [3, 7, 4, 0]
        ]
    );
}

module insert_drain_ridge_ramp_x(width=0.3, length=0.3, ridge_height=0.25, wall_height=0.3, side=1) {
    zrot(side == 1 ? -90 : 90)
        insert_drain_ridge_ramp_y(
            width=width,
            length=length,
            ridge_height=ridge_height,
            wall_height=wall_height,
            side=1
        );
}

module insert_drain_ridge_ramps() {
    if (
        insert_drain_size > 0 &&
        insert_drain_ridge_width > 0 &&
        insert_drain_border_height > 0 &&
        insert_drain_ridge_count > 0 &&
        insert_drain_ridge_ramp_length > 0 &&
        insert_drain_ridge_ramp_height > insert_drain_border_height
    ) {
        inner_half_width = insert_width/2 - insert_wall;
        inner_half_length = insert_length/2 - insert_wall;
        ridge_span = insert_drain_ridge_count > 1 ? insert_drain_size - insert_drain_ridge_width : 0;
        ramp_overlap = 0.02;
        ramp_length = insert_drain_ridge_ramp_length + ramp_overlap;

        for (i = [0:insert_drain_ridge_count-1]) {
            offset = insert_drain_ridge_count > 1 ? -ridge_span/2 + i * ridge_span / (insert_drain_ridge_count - 1) : 0;
            at_truncated_corner = i == insert_drain_ridge_count - 1;

            if (!at_truncated_corner)
                translate([insert_drain_x + offset, inner_half_length + ramp_overlap, 0])
                    insert_drain_ridge_ramp_y(
                        width=insert_drain_ridge_width,
                        length=ramp_length,
                        ridge_height=insert_drain_border_height,
                        wall_height=insert_drain_ridge_ramp_height,
                        side=1
                    );
            translate([insert_drain_x + offset, -inner_half_length - ramp_overlap, 0])
                insert_drain_ridge_ramp_y(
                    width=insert_drain_ridge_width,
                    length=ramp_length,
                    ridge_height=insert_drain_border_height,
                    wall_height=insert_drain_ridge_ramp_height,
                    side=-1
                );
            if (!at_truncated_corner)
                translate([inner_half_width + ramp_overlap, insert_drain_y + offset, 0])
                    insert_drain_ridge_ramp_x(
                        width=insert_drain_ridge_width,
                        length=ramp_length,
                        ridge_height=insert_drain_border_height,
                        wall_height=insert_drain_ridge_ramp_height,
                        side=1
                    );
            translate([-inner_half_width - ramp_overlap, insert_drain_y + offset, 0])
                insert_drain_ridge_ramp_x(
                    width=insert_drain_ridge_width,
                    length=ramp_length,
                    ridge_height=insert_drain_border_height,
                    wall_height=insert_drain_ridge_ramp_height,
                    side=-1
                );
        }
    }
}

module insert_body() {
    difference() {
        linear_extrude(height=insert_body_height)
            chamfered_insert_profile(insert_width, insert_length, insert_truncation_size, insert_rounding);
        up(insert_wall)
            linear_extrude(height=insert_body_height)
                chamfered_insert_profile(
                    insert_width - 2*insert_wall,
                    insert_length - 2*insert_wall,
                    insert_inner_truncation_size,
                    max(insert_rounding - insert_wall/2, 0.2)
                );

        insert_holes();
    }
}

module insert() {
    union() {
        insert_body();
        insert_drain_border();
        insert_drain_ridges();
        insert_drain_ridge_ramps();
    }
}
