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
    insert_body();
}
