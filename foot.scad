module perforated_square_foot(size=3, h=3, wall=0.16, hole_id=0.55, rows=3, spacing=0.6) {
    face_span = size - 2*wall;
    edge_margin = hole_id;
    columns = max(1, floor((face_span - 2*edge_margin - hole_id) / spacing) + 1);
    hole_span = (columns - 1) * spacing;
    x_start = -hole_span / 2;

    difference() {
        difference() {
            cuboid([size, size, h], anchor=BOT);
            up(wall)
                cuboid([size - 2*wall, size - 2*wall, h - wall + 0.01], anchor=BOT);
        }

        for (row = [0:rows-1]) {
            z = (row + 1) * h / (rows + 1);
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

module foot() {
    union() {
        perforated_square_foot(
            size=foot_size,
            h=foot_height,
            wall=foot_wall,
            hole_id=foot_hole_id,
            rows=foot_rows,
            spacing=foot_hole_spacing
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
    }
}
