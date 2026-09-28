include <../Shared Libraries/common_params_and_modules.scad>;

$fn = 36;

// show_only_material = "stainless_steel";
// show_only_material = "brass";
// show_only_material = "plastic_black";
// show_only_material = "3dprint";

// include <../Shared Libraries/filament_colors_595C.scad>;
include <../Shared Libraries/materials.scad>;

include <../Shared Libraries/component_shared_modules.scad>;

include <../Shared Libraries/components/misc_components.scad>;
include <../Shared Libraries/components/castellated_modules.scad>;
include <../Shared Libraries/components/threads.scad>;
include <../Shared Libraries/components/screws.scad>;
include <../Shared Libraries/components/magnets.scad>;

include <../Shared Libraries//components/esp32_boards.scad>;
include <../Shared Libraries/components/displays.scad>;

case_crn_r = 5;
case_dim = [98,90,0];
case_crn_vertices = case_crn_vertices(case_dim,case_crn_r);
case_wall_thk = w6;

base_hgt = 29;
top_hgt = 3;
top_display_recess_hgt = 1;

tray_hgt = 6;
tray_z = base_hgt+top_hgt-top_display_recess_hgt-max7219_display_hgt-tray_hgt;

tray_screw_wall_dist = (case_wall_thk+clr_loose+max(3,1.5+clr_close+w4));
tray_screw_trans = concat(
    // xyz_to_trans(case_dim/2-[1,1,0]*tray_screw_wall_dist),
    vec_to_array((case_dim/2-[1,1,0]*tray_screw_wall_dist-[0,40,0])*ident_xyz(0,1,0),2)+list_x_to_vec([-1,1]*(case_dim.x/2-tray_screw_wall_dist)),
);
tray_support_trans = concat(
    vec_to_array((case_dim/2-[1,1,0]*tray_screw_wall_dist-[0,0,0])*ident_xyz(0,1,0),2)+list_x_to_vec([-1,1]*(case_dim.x/2-tray_screw_wall_dist-20)),
    [(case_dim/2-[1,1,0]*tray_screw_wall_dist-[20,0,0])*ident_xyz(1,-1,0)],
);

part_base = 1;
part_tray = 2;
part_top = 3;
// part_esp32s3_devkitc_1_alt_clamp = 3;
part_bom = 99;

include <../Shared Libraries/Modular Project Assembly/Modular Project Assembly Library.scad>;


// template_part_base(part_base,0,base_hgt,base_bottom_type_open_with_trigrid);

let(part_name=part_tray) difference() {
    union() {
        translate([0,0,tray_z]) cylinder_bev(case_crn_r-case_wall_thk-clr_loose,tray_hgt,bev_m,bev_m,case_crn_vertices);

        intersection() {
            features(part_name,operation_union);
            translate([0,0,tray_z]) cylinder_bev(case_crn_r-case_wall_thk-clr_loose,tray_hgt,bev_m,bev_m,case_crn_vertices);
        }
        features(part_name,operation_union_nonintersect);
    }

    features(part_name,operation_difference);
}

*difference() {
    union() {
        difference() {
            translate([0,0,base_hgt]) cylinder_bev(case_crn_r,top_hgt,bev_m,1,case_crn_vertices);

            // cylinder_bev_co_through(case_crn_r-w6,base_hgt,bev_m,bev_m,0,case_crn_vertices);
        }
        features(part_top,operation_union);
        features(part_top,operation_union_nonintersect);
    }
    // intersection() {
        features(part_top,operation_difference);
        // translate([0,0,base_hgt+0.2]-[1,1,0]*200) cube([2,2,1]*200); 
    // }
}

// for(i_part=[0:99]) features(i_part,operation_placeholder);

// let(boss_hgt=8) feature_align_to_case(esp32c3_supermini_pcb_dim,feature_align_to_case_bottomleft,clr_pcb,[0,14,0],90) {
//     for(it=esp32c3_supermini_boot_loc) translate(it) mirror([0,0,1]) paperclip_placeholder();

//     translate(esp32c3_supermini_pcb_dim/2*ident_xyz(0,1,-2)+[0,3,boss_hgt-3.2/2]) rotate([90,0,0]) translate([0,0,-20]) usbc_plug_placeholder(50,"plastic_black","red");
// }

module features(part,operation) {
    feature_screws(part,operation);
    feature_tray_screws(part,operation);
    // feature_magnets(part,operation);
    // template_feature_feet(part,operation);


    // feature_base_nodemcu(part,operation,10,feature_align_to_case_bottomleft,clr_pcb,[0,14,0],90);
    feature_base_esp32c3_supermini(part,operation,8,feature_align_to_case_bottomleft,clr_pcb,[0,14,0],90);

    feature_buzzer(part,operation,6,feature_align_to_case_bottomright,2,[0,10,0],180);

    // max7219_boss_hgt = base_hgt+top_hgt-(max7219_display_hgt+top_display_recess_hgt);
    // feature_base_max7219(part,operation,max7219_boss_hgt,feature_align_to_case_top,4,[0,0,0],0);
    // feature_base_max7219(part,operation,max7219_boss_hgt,feature_align_to_case_top,4,-[0,13/2+clr_component+4/2,0]*2,0);


    feature_tray_max7219(part,operation,tray_hgt,feature_align_to_case_top,4,[0,0,0],0);
    feature_tray_max7219(part,operation,tray_hgt,feature_align_to_case_top,4,-[0,13/2+clr_component+4/2,0]*2,0);

    // feature_neopixels(part,operation,base_hgt,feature_align_to_case_center,0,[0,0,0],0);
}

module feature_screws(part,operation) {
    screw_inset = let(inset_tmp=max(3,1.5+clr_close+case_wall_thk,1.25+case_wall_thk)) inset_tmp+max(0,case_crn_r-case_crn_r-inset_tmp);

    screw_trans = xyz_to_trans(case_dim/2)-outset_to_trans(screw_inset);

    screw_len = 8;

    for(it=screw_trans) {
        // bom_item(part,operation,str("M3 x ",screw_len,"mm self-tapping flat-end plastic screw"));

        boss_crn_trans = vec_to_array(it,4)+xyz_to_trans([1,1,0]*10,ident_xyz(sign(it.x),sign(it.y),0));

        if(part == part_base) {
            // if(operation == operation_union) translate([0,0,base_floor_skin_thk]) cylinder_bev_stud(1.25+w6,-base_floor_skin_thk+base_hgt,bev_m,bev_m,boss_crn_trans);

            if(operation == operation_union) intersection() {
                cylinder_bev(1.25+w6,base_hgt,0,bev_m,boss_crn_trans);

                translate(it+[0,0,base_hgt-(screw_len-2)]) rotate([0,0,atan2(sign(it.y),sign(it.x))]) translate(-[1.25+w6,0,0]) rotate([0,52.5,0]) translate(-[1,1,0]*50) cube([2,2,2]*50);
            }

            if(operation == operation_difference) translate([0,0,base_hgt]) {
                cylinder_bev_co_blind_downwards(1.25,screw_len-2,0.5,bev_m,0,[it]);
            }
        }

        if(part == part_tray) {
            if(operation == operation_difference) translate([0,0,tray_z]) cylinder_bev_co_through(1.25+w6,tray_hgt,bev_m,bev_m,clr_loose,boss_crn_trans);
        }

        if(part == part_top) translate([0,0,base_hgt]) {
            if(operation == operation_difference) {
                cylinder_bev_co_through(1.5,2,bev_m,bev_s,clr_close,[it]);
                translate([0,0,top_hgt]) cylinder_bev_co_blind_downwards(3,top_hgt-2,bev_s,bev_m,clr_close,[it]);
            }

            if(operation == operation_placeholder) translate(it+[0,0,2]) material_stainless_steel() screw_m3_torx_placeholder(screw_len);
        }
    }
}

function tray_screw_boss_direction(it) = let(
    it_abs=[abs(it.x),abs(it.y),abs(it.z)],
    wall_dist=case_dim/2-it_abs,
    attach_to_wall=[wall_dist.x<=tray_screw_wall_dist?sign(it.x):0,wall_dist.y<=tray_screw_wall_dist?sign(it.y):0,0],
) attach_to_wall;

function tray_screw_boss_crn_vertices(it) = let(
    attach_to_wall=tray_screw_boss_direction(it),
) vec_to_array(it,4)+xyz_to_trans([abs(attach_to_wall.x),abs(attach_to_wall.y),0]*10,ident_xyz(sign(it.x),sign(it.y),0));

module feature_tray_screws(part,operation) {
    for(it=concat(tray_screw_trans,(!is_undef(tray_support_trans)?tray_support_trans:[]))) {
        boss_crn_trans = tray_screw_boss_crn_vertices(it);

        if(part == part_base) {
            if(operation == operation_union) {
                intersection() {
                    cylinder_bev(1.25+w6,tray_z,bev_m,bev_m,boss_crn_trans);

                    translate(it-tray_screw_boss_direction(it)*(1.25+w6)+[0,0,tray_z-6]) let(tray_screw_boss_direction=tray_screw_boss_direction(it),boss_overhang_rotate=[-tray_screw_boss_direction.y,tray_screw_boss_direction.x,0]*45) rotate(boss_overhang_rotate) translate(-[1,1,0]*10) cube([2,2,2]*10);
                }
            }
        }
        
        if(part == part_tray) translate([0,0,tray_z]) {
            if(operation == operation_union) {
                cylinder_bev(3+clr_close+w6,tray_hgt,bev_m,bev_m,boss_crn_trans);
            }
        }
    }

    for(it=concat(tray_screw_trans)) {
        boss_crn_trans = tray_screw_boss_crn_vertices(it);

        if(part == part_base && operation == operation_difference) translate([0,0,tray_z]) {
            cylinder_bev_co_blind_downwards(1.25,8-2,0.5,bev_m,0,[it]);
        }
        if(part == part_tray) translate([0,0,tray_z]) {
            if(operation == operation_difference) {
                cylinder_bev_co_through(1.5,2,bev_m,bev_s,clr_close,[it]);
                translate([0,0,tray_hgt]) cylinder_bev_co_blind_downwards(3,tray_hgt-2,bev_s,bev_m,clr_close,boss_crn_trans);
            }
            if(operation == operation_placeholder) translate(it+[0,0,2]) material_stainless_steel() screw_m3_torx_placeholder(8);
        }
    }
}

module feature_magnets(part,operation) {
    // magnet_trans = xyz_to_trans(case_dim/2)-outset_to_trans(case_wall_thk+1+magnet_80r30_r+clr_close)-outset_xxyy_to_trans(1,1,0,0)*22;

    magnet_trans = xyz_to_trans([w6/2,case_dim.y/2-case_wall_thk-1,0]+[1,-1,0]*(magnet_80r30_r+clr_close));

    boss_hgt = 0.4+2*magnet_80r30_h;

    for(it=magnet_trans) {
        // bom_item(part,operation,str(magnet_80r30_r*2,"mm x ",magnet_80r30_h,"mm neodymium magnet"));

        if(part == part_base) {
            boss_crn_trans = let(
                it_abs=[abs(it.x),abs(it.y),abs(it.z)],
                wall_dist=case_dim/2-it_abs,
                tray_screw_wall_dist = magnet_80r30_r+clr_close+1+w6+1,
                attach_to_wall=[wall_dist.x<=tray_screw_wall_dist?sign(it.x):0,wall_dist.y<=tray_screw_wall_dist?sign(it.y):0,0],
                attach_to_axis=[it_abs.x<=tray_screw_wall_dist?sign(it.x):0,it_abs.y<=tray_screw_wall_dist?sign(it.y):0,0],
            )  vec_to_array(it,4)+xyz_to_trans([abs(attach_to_wall.x),abs(attach_to_wall.y),0]*10,ident_xyz(sign(it.x),sign(it.y),0))+xyz_to_trans([abs(attach_to_axis.x),abs(attach_to_axis.y),0]*5,-ident_xyz(sign(it.x),sign(it.y),0));
            
            if(operation == operation_union) {
                cylinder_bev(magnet_80r30_r+clr_close+w6,boss_hgt,bev_m,bev_m,boss_crn_trans);
            }
            if(operation == operation_difference) translate([0,0,boss_hgt]) {
                translate(it) magnet_80r30_pocket_co_downwards(boss_hgt-0.4);
                cylinder_bev_co_blind_downwards(magnet_80r30_r,boss_hgt-0.4-magnet_80r30_h+1,1,bev_m,clr_close,[it]);
            }

            if(operation == operation_placeholder) translate(it+[0,0,boss_hgt]) {
                translate([0,0,-1]*magnet_80r30_h) magnet_80r30_placeholder();
                translate([0,0,-2]*magnet_80r30_h) magnet_80r30_placeholder();
            }
        }
    }
}

module template_feature_feet(part,operation) {
    base_feet_trans = xyz_to_trans(case_dim/2)-outset_to_trans(case_wall_thk+2+3.8/2)-outset_xxyy_to_trans(1,1,0,0)*12;

    for(it=base_feet_trans) {
        // bom_item(part,operation,str("FC-040 Rubber foot"));

        if(part == part_base) {
            // boss_crn_trans = vec_to_array(it,2)+list_y_to_vec([0,10]*sign(it.y));
            // boss_crn_trans = vec_to_array(it,4)+xyz_to_trans([1,1,0]*10,ident_xyz(sign(it.x),sign(it.y),0));
            boss_crn_trans = let(
                it_abs=[abs(it.x),abs(it.y),abs(it.z)],
                wall_dist=case_dim/2-it_abs,
                tray_screw_wall_dist = case_wall_thk+2+3.8/2+clr_tight,
                attach_to_wall=[wall_dist.x<=tray_screw_wall_dist?sign(it.x):0,wall_dist.y<=tray_screw_wall_dist?sign(it.y):0,0],
                attach_to_axis=[it_abs.x<=tray_screw_wall_dist?sign(it.x):0,it_abs.y<=tray_screw_wall_dist?sign(it.y):0,0],
            )  vec_to_array(it,4)+xyz_to_trans([abs(attach_to_wall.x),abs(attach_to_wall.y),0]*10,ident_xyz(sign(it.x),sign(it.y),0))+xyz_to_trans([abs(attach_to_axis.x),abs(attach_to_axis.y),0]*5,-ident_xyz(sign(it.x),sign(it.y),0));
            
            if(operation == operation_union) cylinder_bev(3.8/2+clr_tight+4,2,bev_m,bev_m,boss_crn_trans);
            if(operation == operation_difference) cylinder_bev_co_through(3.8/2,2,bev_m,bev_m,clr_tight,[it]);

            if(operation == operation_placeholder) translate(it) fc040_foot_placeholder();
        }
    }
}



module feature_base_esp32c3_supermini(part,operation,boss_hgt=6,feature_align_to_case=feature_align_to_case_center,position_inset=clr_pcb,position_adjust=[0,0,0],feature_rotate=0) {
    pcb_dim = esp32c3_supermini_pcb_dim;
    // pcb_crn_r = esp32c3_supermini_pcb_crn_r;
    // pin_loc = nodemcu_v1_pin_loc;
    // screw_trans = nodemcu_v1_screw_trans;
    // top_component_trans = nodemcu_v1_top_component_trans;
    // top_component_z = nodemcu_v1_top_component_z;


    template_feature_base_esp32c3_supermini(part,operation,boss_hgt,feature_align_to_case,position_inset,position_adjust,feature_rotate);
}


module feature_base_nodemcu(part,operation,boss_hgt=6,feature_align_to_case=feature_align_to_case_center,position_inset=clr_pcb,position_adjust=[0,0,0],feature_rotate=0) {
    pcb_dim = nodemcu_v1_pcb_dim;
    pcb_crn_r = nodemcu_v1_pcb_crn_r;
    pin_loc = nodemcu_v1_pin_loc;
    screw_trans = nodemcu_v1_screw_trans;
    top_component_trans = nodemcu_v1_top_component_trans;
    top_component_z = nodemcu_v1_top_component_z;


    feature_align_to_case(pcb_dim*ident_xyz(1,0,0),feature_align_to_case,0,position_adjust,feature_rotate) {
        if(part == part_base) {
            if(operation == operation_union) {
                let(tab_widh=12+case_wall_thk,step_h0=10,step_h1=step_h0+4,round_r0=1,round_r1=1+case_wall_thk,hgt=base_hgt) translate([0,0,0]) rotate([0,0,0]) {
                    round_step_tab_3d(tab_widh,step_h0,step_h1,round_r0,round_r1,hgt,bev_m,bev_m);
                }
            }
        }
        if(operation == operation_difference) translate([0,0,base_hgt]) {
            let(tab_widh=12,step_h0=10,step_h1=step_h0+4,round_r0=1,round_r1=1,hgt=base_hgt-4) translate([0,case_wall_thk,0]) rotate([0,0,0]) {
                if(part == part_base) round_step_tab_3d_co_blind_downwards(tab_widh,step_h0,step_h1,round_r0,round_r1,hgt,bev_m,bev_m);
                if(part == part_top) round_step_tab_3d_co_through(tab_widh,step_h0,step_h1,round_r0,round_r1,top_hgt,bev_m,1);
            }

            if(part == part_base) {
                let(tab_widh=12,step_h0=10,step_h1=step_h0+4,round_r0=1,round_r1=1,hgt=base_hgt-4) translate([0,step_h0+case_wall_thk,0]) let(step_l_in=round_r0+round_r1) rotate([90,0,0]) round_step_area(step_h0,step_h1,0,step_l_in,round_r0,round_r1,xyz_to_trans([tab_widh-round_r0,hgt/2,0],attach_bottom));
            }
        }
    }

    template_feature_base_nodemcu_v1(part,operation,boss_hgt,feature_align_to_case,position_inset,position_adjust+[0,4,0]*rotation_matrix(feature_rotate),feature_rotate);

    *feature_align_to_case(pcb_dim,feature_align_to_case,position_inset,position_adjust,feature_rotate) translate([0,-4,0]) {
        if(part == part_base) {
            if(operation == operation_union) {
                cylinder_bev(pcb_crn_r+4,boss_hgt,bev_m,bev_m,xyz_to_trans(pcb_dim/2)-outset_to_trans(pcb_crn_r)+outset_xxyy_to_trans(0,0,0,10));
            }
            if(operation == operation_difference) translate([0,0,boss_hgt]) {
                usbc_module_intersect(pcb_dim,position_inset) {
                    component_pcb_co(pcb_dim,pcb_crn_r);
                    for(it=pin_loc) component_co_downwards(2+pcb_dim.z,boss_hgt,pin_dupont_header_co_crn_trans(it));

                    for(it=screw_trans) if(it.y < 0) cylinder_bev_co_through(1.25,boss_hgt,bev_m,bev_m+pcb_dim.z,0,[it+[0,0,-boss_hgt]]);
                    

                    component_btm_component_co([for(i=[0:len(top_component_trans)-1]) top_component_trans[i]*ident_xyz(-1,1,0)],[for(i=[0:len(top_component_z)-1]) top_component_z[i]+pcb_dim.z],boss_hgt);
                }
                usbc_module_flipped_port_intersect(pcb_dim,clr_pcb) {
                    translate([0,0,-pcb_dim.z]) mirror([0,0,1]) usbc_wall_co(pcb_dim,clr_pcb,w6,0);
                }

                translate(-[0,0,boss_hgt]) cylinder_bev_co_through(2,boss_hgt,bev_m,bev_m+pcb_dim.z,0,xyz_to_trans(pcb_dim/2)-outset_to_trans(2)-outset_xxyy_to_trans(2,2,6,12));
            }
            if(operation == operation_placeholder) translate([0,0,boss_hgt]) {
                translate([0,0,-pcb_dim.z]) rotate([0,180,0]) {
                    nodemcu_v1_placeholder();

                    let(pins_connected_i=[12,15,16,21,23,24]) for(pin_i=[0:len(pin_loc)-1]) let(it=pin_loc[pin_i]) translate(it+[0,0,-pcb_dim.z]) pin_header_placeholder_downwards() let(pin_connected_search=search(pin_i,pins_connected_i,1)) if(len(pin_connected_search) > 0 && pin_connected_search[0] != undef) rotate([0,0,(pin_i<len(pin_loc)/2?90:-90)]) dupont_header_placeholder();
                }

                for(it=screw_trans) if(it.y < 0) translate(it) material_stainless_steel() screw_m3_torx_placeholder(6);
            }
        }


        if(part == part_base && operation == operation_difference) {
            for(it=nodemcu_v1_reset_loc) cylinder_bev_co_through(1.25,boss_hgt,bev_m,bev_m+pcb_dim.z,0,[it]);
            for(it=nodemcu_v1_boot_loc) cylinder_bev_co_through(0.5,boss_hgt,bev_m,bev_m+pcb_dim.z,0,vec_to_array(it,4)+xyz_to_trans([1,1,0]*1.25)-outset_to_trans(0.5));

            // for(it=esp32c3_supermini_led_loc) translate([0,0,boss_hgt]) cylinder_bev_co_blind_downwards(1,boss_hgt-0.2,bev_m,bev_m+pcb_dim.z,0,[it]);
        }
    }
}


module feature_tray_max7219(part,operation,boss_hgt=6,feature_align_to_case=feature_align_to_case_center,position_inset=clr_pcb,position_adjust=[0,0,0],feature_rotate=0) {
    pcb_dim = max7219_display_pcb_dim;
    pcb_crn_r = max7219_display_pcb_crn_r;
    pin_loc = max7219_display_pin_loc;
    screw_trans = max7219_display_screw_trans;
    btm_component_trans = max7219_btm_component_trans;
    btm_component_z = max7219_btm_component_z;

    feature_align_to_case(pcb_dim,feature_align_to_case,position_inset,position_adjust,feature_rotate) {
        if(part == part_tray) translate([0,0,tray_z]) {
            if(operation == operation_difference) translate([0,0,boss_hgt]) {
                component_pcb_co(pcb_dim,pcb_crn_r);
                    
                component_btm_component_co(btm_component_trans,btm_component_z,boss_hgt);

                for(it=pin_loc) component_co_downwards(2+pcb_dim.z,boss_hgt,pin_dupont_header_co_crn_trans(it));
            }

            for(it=screw_trans) {
                if(operation == operation_difference) cylinder_bev_co_through(1.25,boss_hgt,bev_m,bev_m+pcb_dim.z,0,[it]);
                if(operation == operation_placeholder) {
                }
            }
            if(operation == operation_placeholder) translate([0,0,boss_hgt]) {
                max7219_display_placeholder();

                let(pins_connected_i=[0,1,2,3,4,5,6]) for(pin_i=[0:len(pin_loc)-1]) let(it=pin_loc[pin_i]) translate(it+[0,0,-pcb_dim.z]) rotate([0,0,(pin_i<len(pin_loc)/2?90:-90)]) pin_header_right_angle_placeholder_downwards() let(pin_connected_search=search(pin_i,pins_connected_i,1)) if(len(pin_connected_search) > 0 && pin_connected_search[0] != undef) rotate([0,0,-90]) dupont_header_placeholder();

                for(it=screw_trans) translate(it) material_stainless_steel() screw_m3_torx_placeholder(6);
            }
        }

        if(part == part_top && operation == operation_difference) translate([0,0,base_hgt]) {
            cylinder_bev_co_through(max7219_display_crn_r,top_hgt-1,bev_m,bev_m,clr_close,max7219_display_crn_trans);

            translate([0,0,top_hgt]) cylinder_bev_co_blind_downwards(max7219_display_crn_r+2,1,0,1,clr_close,max7219_display_crn_trans-outset_to_trans(2)+outset_xxyy_to_trans(6,6,12,2));

            // for(it=list_partial(pin_loc,5,10-1)) component_co_upwards(top_hgt,top_hgt,pin_jstxh_header_co_crn_trans(it,0));
        }
    }
}

module feature_base_max7219(part,operation,boss_hgt=6,feature_align_to_case=feature_align_to_case_center,position_inset=clr_pcb,position_adjust=[0,0,0],feature_rotate=0) {
    pcb_dim = max7219_display_pcb_dim;
    pcb_crn_r = max7219_display_pcb_crn_r;
    pin_loc = max7219_display_pin_loc;
    screw_trans = max7219_display_screw_trans;

    feature_align_to_case(pcb_dim,feature_align_to_case,position_inset,position_adjust,feature_rotate) {
        if(part == part_base) {
            if(operation == operation_difference) translate([0,0,boss_hgt]) {
                for(it=pin_loc) component_co_downwards(2+pcb_dim.z,boss_hgt,pin_dupont_header_co_crn_trans(it));
            }

            for(it=screw_trans) {
                if(operation == operation_union) {
                    cylinder_bev(4+2,base_bottom_skin_thk,bev_m,bev_s,[it,it*ident_xyz(1,0,0)]);
                    translate([0,0,base_bottom_skin_thk]) cylinder_bev_stud(4,-base_bottom_skin_thk+boss_hgt-pcb_dim.z-2,bev_m,4-(1.25+w6),[it,it*ident_xyz(1,0,0)]);
                    cylinder_bev(1.25+w6,boss_hgt-pcb_dim.z,bev_m,bev_m,[it,it*ident_xyz(1,0,0)]);
                }
                if(operation == operation_difference) translate([0,0,boss_hgt-pcb_dim.z]) {
                    cylinder_bev_co_blind_downwards(1.25,8-pcb_dim.z,0.5,bev_m,0,[it]);
                }
                if(operation == operation_placeholder) {

                }
            }
            if(operation == operation_placeholder) translate([0,0,boss_hgt]) {
                max7219_display_placeholder();

                let(pins_connected_i=[0,1,2,3,4,5,6]) for(pin_i=[0:len(pin_loc)-1]) let(it=pin_loc[pin_i]) translate(it+[0,0,-pcb_dim.z]) rotate([0,0,(pin_i<len(pin_loc)/2?90:-90)]) pin_header_right_angle_placeholder_downwards() let(pin_connected_search=search(pin_i,pins_connected_i,1)) if(len(pin_connected_search) > 0 && pin_connected_search[0] != undef) rotate([0,0,-90]) dupont_header_placeholder();

                for(it=screw_trans) translate(it) material_stainless_steel() screw_m3_torx_placeholder(6);
            }
        }

        if(part == part_top && operation == operation_difference) translate([0,0,base_hgt]) {
            cylinder_bev_co_through(max7219_display_crn_r,top_hgt-1,bev_m,bev_m,clr_close,max7219_display_crn_trans);

            translate([0,0,top_hgt]) cylinder_bev_co_blind_downwards(max7219_display_crn_r+2,1,0,1,clr_close,max7219_display_crn_trans-outset_to_trans(2)+outset_xxyy_to_trans(6,6,12,2));

            // for(it=list_partial(pin_loc,5,10-1)) component_co_upwards(top_hgt,top_hgt,pin_jstxh_header_co_crn_trans(it,0));
        }
    }
}


module feature_neopixels(part,operation,boss_hgt=6,feature_align_to_case=feature_align_to_case_center,position_inset=clr_pcb,position_adjust=[0,0,0],feature_rotate=0) {
    neopixel_dim = [1000/60,10,0.6];

    neopixel_n = 5;

    pcb_dim = neopixel_dim*ident_xyz(neopixel_n,1,1);
    pcb_crn_r = 0;

    lens_crn_r = 2;
    lens_dim = pcb_dim+[1,1,0]*1.5;
    lens_crn_vertices = xyz_to_trans(lens_dim/2)-outset_to_trans(lens_crn_r);

    lens_flange_hgt = 1.2;
    lens_flange_clr = clr_free;
    lens_flange_crn_r = lens_crn_r+lens_flange_clr+1;
    lens_flange_dim = lens_dim+[1,1,0]*lens_flange_crn_r;

    feature_align_to_case(lens_flange_dim,feature_align_to_case,position_inset,position_adjust,feature_rotate) {
        // if(part == part_tray) translate([0,0,tray_z]) {
        //     if(operation == operation_union) {
        //         cylinder_bev(lens_flange_crn_r+4,boss_hgt,bev_m,bev_m,lens_crn_vertices);
        //     }
        //     if(operation == operation_difference) translate([0,0,boss_hgt]) {
        //         translate([0,0,-lens_flange_hgt]) component_pcb_co(pcb_dim,pcb_crn_r);

        //         component_co_downwards(boss_hgt,boss_hgt,xyz_to_trans(pcb_dim/2)-outset_xxyy_to_trans(0,pcb_dim.x-4,0,0));
        //     }
            
        if(part == part_base) {
            if(operation == operation_placeholder) translate([0,0,boss_hgt]) {
                for(i=[-(neopixel_n-1)/2:(neopixel_n-1)/2]) translate(neopixel_dim*ident_xyz(i,0,0)) led_strip_ws2812_placeholder();
            }
        }

        if(operation == operation_difference) translate([0,0,base_hgt]) {
            // if(part == part_tray) cylinder_bev_co_blind_downwards(lens_flange_crn_r,lens_flange_hgt,0,bev_m,lens_flange_clr,lens_crn_vertices);
            if(part == part_top) cylinder_bev_co_through(lens_crn_r,top_hgt,bev_m,bev_m,clr_loose,lens_crn_vertices);
        }

        // if(part == part_neopixel_lens) translate([0,0,base_hgt]) {
        //     if(operation == operation_union) {
        //         translate([0,0,-lens_flange_hgt]) cylinder_bev(lens_flange_crn_r,lens_flange_hgt,bev_m,bev_s,lens_crn_vertices);
        //         cylinder_bev_stud(lens_crn_r,top_hgt,bev_m,bev_m,lens_crn_vertices);
        //     }
        //     // if(part == part_top) cylinder_bev_co_through(lens_crn_r,top_hgt,bev_m,bev_m,clr_loose,lens_crn_vertices);
        // }
    }
}


module feature_buzzer(part,operation,boss_hgt=6,feature_align_to_case=feature_align_to_case_center,position_inset=clr_pcb,position_adjust=[0,0,0],feature_rotate=0) {
    pcb_dim = buzzer_mhfmd_pcb_dim;
    pcb_crn_r = buzzer_mhfmd_pcb_crn_r;
    pin_loc = buzzer_mhfmd_pin_loc;
    screw_trans = buzzer_mhfmd_screw_trans;
    top_component_trans = buzzer_mhfmd_top_component_trans;
    top_component_z = buzzer_mhfmd_top_component_z;

    feature_align_to_case(pcb_dim,feature_align_to_case,position_inset,position_adjust,feature_rotate) {
        if(part == part_base) {
            if(operation == operation_union) {
                cylinder_bev(4,boss_hgt,bev_m,bev_m,xyz_to_trans(pcb_dim/2));
            }

            if(operation == operation_difference) translate([0,0,boss_hgt]) {
                component_pcb_co(pcb_dim,pcb_crn_r);
                for(it=pin_loc) component_co_downwards(2+pcb_dim.z,boss_hgt,pin_dupont_header_co_crn_trans(it));
                for(it=screw_trans) translate(-[0,0,boss_hgt]) cylinder_bev_co_through(1.25,boss_hgt,bev_m,bev_m+pcb_dim.z,0,[it]);
            }

            if(operation == operation_placeholder) {
                translate([0,0,boss_hgt]) {
                    buzzer_mhfmd_placeholder();

                    for(pin_i=[0:2]) let(it=pin_loc[pin_i]) translate(it) rotate([0,0,180]) pin_header_placeholder_upwards() dupont_header_placeholder();

                    for(it=screw_trans) translate(it) material_stainless_steel() screw_m3_torx_placeholder(6);
                }
            }
        }

        if(part == part_top && operation == operation_difference) translate([0,0,base_hgt]) {
            for(it=list_partial(pin_loc,0,2)) component_co_upwards(top_hgt-1,top_hgt,vec_to_array(it,4)+(pin_jstxh_header_co_crn_trans()+outset_xxyy_to_trans(4,4,0,0))*rotation_matrix(90));
        }
    }
}