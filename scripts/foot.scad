module perforated_square_foot(size=3, h=3, wall=0.16, hole_id=0.55, rows=3, spacing=0.6, perforation_top=3) {
    face_span = size - 2*wall;
    edge_margin = hole_id;
    columns = max(1, floor((face_span - 2*edge_margin - hole_id) / spacing) + 1);
    hole_span = (columns - 1) * spacing;
    x_start = -hole_span / 2;
    z_start = hole_id/2;
    z_end = max(z_start, min(perforation_top - hole_id/2, h - hole_id/2));
    z_span = z_end - z_start;

    difference() {
        difference() {
            cuboid([size, size, h], anchor=BOT);
            up(wall)
                cuboid([size - 2*wall, size - 2*wall, h - wall + 0.01], anchor=BOT);
        }

        for (row = [0:rows-1]) {
            z = rows > 1 ? z_start + row * z_span / (rows - 1) : z_start;
            x_offset = (row % 2 == 0 || columns == 1) ? 0 : spacing / 2;
            for (col = [0:columns-1]) {
                x = x_start + col * spacing + x_offset;
                if (abs(x) <= face_span/2 - edge_margin) {
                    translate([x, size/2 - wall/2, z])
                        hex_cut_y(hole_id, wall * 4);
                    translate([x, -size/2 + wall/2, z])
                        hex_cut_y(hole_id, wall * 4);
                    translate([size/2 - wall/2, x, z])
                        hex_cut_x(hole_id, wall * 4);
                    translate([-size/2 + wall/2, x, z])
                        hex_cut_x(hole_id, wall * 4);
                }
            }
        }
    }
}

module foot_ribs(size=3, h=3, count=4, length=1.5, thickness=0.3, rib_height=2.7, wall=0.16) {
    rib_height_clamped = max(0, min(rib_height, h));

    if (count > 0 && rib_height_clamped > 0) {
        step = size / (count + 1);
        for (i = [1:count]) {
            pos = -size/2 + i * step;

            translate([pos, size/2 + length/2 - wall, 0])
                cuboid([thickness, length, rib_height_clamped], anchor=BOT);
            translate([pos, -size/2 - length/2 + wall, 0])
                cuboid([thickness, length, rib_height_clamped], anchor=BOT);
            translate([size/2 + length/2 - wall, pos, 0])
                cuboid([length, thickness, rib_height_clamped], anchor=BOT);
            translate([-size/2 - length/2 + wall, pos, 0])
                cuboid([length, thickness, rib_height_clamped], anchor=BOT);
        }
    }
}

module foot_snap_head_y(width=0.3, length=0.2, height=0.3, slope_end=0.2, side=1) {
    slope_z = max(0, min(slope_end, height));
    y0 = 0;
    y1 = side * length;

    polyhedron(
        points=[
            [-width/2, y0, 0],
            [ width/2, y0, 0],
            [ width/2, y1, 0],
            [-width/2, y1, 0],
            [-width/2, y0, height],
            [ width/2, y0, height],
            [ width/2, y1, slope_z],
            [-width/2, y1, slope_z]
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

module foot_snap_head_x(width=0.3, length=0.2, height=0.3, slope_end=0.2, side=1) {
    zrot(90)
        foot_snap_head_y(width=width, length=length, height=height, slope_end=slope_end, side=side);
}

module foot_snap_heads(size=3, h=3, count=4, thickness=0.3, rib_height=2.7, head_height=0.3, head_length=0.2, slope_end=0.2) {
    head_height_clamped = max(0, head_height);
    head_z = h - head_height_clamped;

    if (count > 0 && head_height_clamped > 0 && head_length > 0) {
        step = size / (count + 1);
        for (i = [1:count]) {
            pos = -size/2 + i * step;

            translate([pos, size/2, head_z])
                foot_snap_head_y(width=thickness, length=head_length, height=head_height_clamped, slope_end=slope_end, side=1);
            translate([pos, -size/2, head_z])
                foot_snap_head_y(width=thickness, length=head_length, height=head_height_clamped, slope_end=slope_end, side=-1);
            translate([size/2, pos, head_z])
                foot_snap_head_x(width=thickness, length=head_length, height=head_height_clamped, slope_end=slope_end, side=-1);
            translate([-size/2, pos, head_z])
                foot_snap_head_x(width=thickness, length=head_length, height=head_height_clamped, slope_end=slope_end, side=1);
        }
    }
}

module foot_relief_slices(size=3, h=3, count=4, rib_length=1.5, rib_height=2.7, wall=0.16, slice_width=0.1, snap_head_length=0.2) {
    if (count > 0 && slice_width > 0) {
        step = size / (count + 1);
        slice_overlap = 0.02;
        slice_outer_depth = rib_length + snap_head_length;
        slice_depth = wall + slice_outer_depth + 2*slice_overlap;
        slice_center_offset = size/2 - wall/2 + slice_outer_depth/2;
        slice_z = max(0, min(rib_height, h));
        slice_height = h - slice_z + 0.02;

        for (side = [-1, 1], gap = [0:count]) {
            slice_pos = -size/2 + (gap + 0.5) * step;

            translate([slice_pos, side * slice_center_offset, slice_z - 0.01])
                cuboid([slice_width, slice_depth, slice_height], anchor=BOT);
            translate([side * slice_center_offset, slice_pos, slice_z - 0.01])
                cuboid([slice_depth, slice_width, slice_height], anchor=BOT);
        }
    }
}

module foot() {
    difference() {
        union() {
            perforated_square_foot(
                size=foot_size,
                h=foot_height,
                wall=foot_wall,
                hole_id=foot_hole_id,
                rows=foot_rows,
                spacing=foot_hole_spacing,
                perforation_top=foot_rib_height
            );

            foot_ribs(
                size=foot_size,
                h=foot_height,
                count=foot_rib_count,
                length=foot_rib_length,
                thickness=foot_rib_thickness,
                rib_height=foot_rib_height,
                wall=foot_wall
            );

            foot_snap_heads(
                size=foot_size,
                h=foot_height,
                count=foot_rib_count,
                thickness=foot_rib_thickness,
                rib_height=foot_rib_height,
                head_height=foot_snap_head_height,
                head_length=foot_snap_head_length,
                slope_end=foot_snap_head_slope_end
            );
        }

        foot_relief_slices(
            size=foot_size,
            h=foot_height,
            count=foot_rib_count,
            rib_length=foot_rib_length,
            rib_height=foot_rib_height,
            wall=foot_wall,
            slice_width=foot_slice_width,
            snap_head_length=foot_snap_head_length
        );
    }
}
