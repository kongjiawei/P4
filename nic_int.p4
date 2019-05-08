//for 202


#include "includes/headers.p4"
#include "includes/parser.p4"
#include "includes/rand.p4"
#include "includes/global_config.p4"

//primitive_action do_read_drop_counter();
primitive_action set_tdelta();
//primitive_action do_set_tx_utilization();
//primitive_action do_count();
primitive_action gen_random_instruction();

action act_set_random_instruction() {
    gen_random_instruction();
    modify_field(int_header.instruction_mask_0001,instruction_meta.instruction);
}
table tbl_set_random_instruction {
    actions {
        act_set_random_instruction;  
    }
}

/*
 * not INT case, we just drop and count
 */

//action set_drop_counter() {
//    do_read_drop_counter();
//}



counter drop_counter {
    type : packets;
    instance_count : 1;
}

action do_drop() {
    count(drop_counter, 0);
    drop();
}

counter pkt_counter {
    type : bytes;
    instance_count : 1;
    //saturating;
}
action pktlen_count() {

    count(pkt_counter,0);
    //do_count();

}
table tbl_pktlen_count {
    actions {
        pktlen_count;
    }
}
//action set_tx_utilization() {
//    do_set_tx_utilization();
//}
//table tbl_set_tx_utilization {
//    actions {
//        set_tx_utilization;
//    }
//}
/*
@pragma netro reglocked register
register arrival_time_register {
    width : 64;
    instance_count : 1;
    
}

action read_arrival_time_register() {
    register_read(int_arrival_time_metadata.arrival_time,arrival_time_register,0);
    
}
action write_arrival_time_register() {
    register_write(arrival_time_register,0,intrinsic_metadata.current_global_timestamp);
}

table tbl_read_arrival_time_register {
    actions {
        read_arrival_time_register;
    }
}
table tbl_write_arrival_time_register {
    actions {
        write_arrival_time_register;
    }
}
*/
#ifdef SRC
@pragma netro no_lookup_caching
#endif
action do_forward(espec,int_idx) {
    modify_field(standard_metadata.egress_spec, espec);
    modify_field(int_index.index,int_idx);
    
}



table tbl_forward {
    reads {
        //standard_metadata.ingress_port : exact;
        ipv4.dstAddr                   : ternary;
    }
    actions {
        do_forward;
        do_drop;
    }
}


//table tbl_read_drop_counter {
//    actions {
//        set_drop_counter;
//    }
//}


action int_set_header_drop_counter() {
    add_header(int_drop_counter_header);
    add_to_field(ipv4.totalLen,4);
    add_to_field(int_header.ins_cnt,1);

}

action int_set_header_switch_id() { 
    add_header(int_switch_id_header);
    modify_field(int_switch_id_header.switch_id, SWITCH_ID);
    add_to_field(ipv4.totalLen,4);
    add_to_field(int_header.ins_cnt,1);
}

action int_set_header_port_id() {
    add_header(int_port_id_header);
    modify_field(int_port_id_header.ingress_port_id, 
                    standard_metadata.ingress_port);
    modify_field(int_port_id_header.egress_port_id,
                    standard_metadata.egress_port);
    add_to_field(ipv4.totalLen,4);
    add_to_field(int_header.ins_cnt,1);
   
}
action int_set_header_switch_id_and_latency() {

    #ifdef SRC
        modify_field(int_header.instruction_mask_0001,1);
    #endif
    #ifdef INTERMEDIATE
        modify_field(int_header.instruction_mask_0002,1);
    #endif
    add_header(int_switch_id_header);
    add_header(int_hop_latency_header);

    //set_tdelta();

     modify_field(int_switch_id_header.switch_id, SWITCH_ID);

    add_to_field(ipv4.totalLen,4);
    add_to_field(int_header.ins_cnt,1);

    modify_field(int_hop_latency_header.hop_latency,
    intrinsic_metadata.current_global_timestamp - intrinsic_metadata.ingress_global_timestamp);
    add_to_field(ipv4.totalLen,4);
    add_to_field(int_header.ins_cnt,1);
   

    modify_field(int_hop_latency_header.bos,1);
}
/*
action int_set_header_switch_id_and_latency_2() {
    modify_field(int_header.instruction_mask_0001, 1);
    modify_field(int_header.instruction_mask_0001, 3);
    add_header(int_switch_id_header);
    add_header(int_hop_latency_header);

    //set_tdelta();

     modify_field(int_switch_id_header.switch_id, SWITCH_ID);

    add_to_field(ipv4.totalLen,4);
    add_to_field(int_header.ins_cnt,1);

    modify_field(int_hop_latency_header.hop_latency,
    intrinsic_metadata.current_global_timestamp - intrinsic_metadata.ingress_global_timestamp);
    add_to_field(ipv4.totalLen,4);
    add_to_field(int_header.ins_cnt,1);
   

    modify_field(int_hop_latency_header.bos,1);
}
*/
action int_set_header_switch_id_and_port_id() {

    #ifdef SRC
        modify_field(int_header.instruction_mask_0001,0);
    #endif
    #ifdef INTERMEDIATE
        modify_field(int_header.instruction_mask_0002,0);
    #endif

    add_header(int_switch_id_header);


    add_header(int_port_id_header);
    //set_tdelta();

    //modify_field(int_hop_latency_header.hop_latency,
    //intrinsic_metadata.current_global_timestamp - intrinsic_metadata.ingress_global_timestamp);

    modify_field(int_switch_id_header.switch_id, SWITCH_ID);

    add_to_field(ipv4.totalLen,4);
    add_to_field(int_header.ins_cnt,1); 

    modify_field(int_port_id_header.ingress_port_id, 
                    standard_metadata.ingress_port);
    modify_field(int_port_id_header.egress_port_id,
                    standard_metadata.egress_port);
    add_to_field(ipv4.totalLen,4);
    add_to_field(int_header.ins_cnt,1);
    


    modify_field(int_port_id_header.bos,1);

}

action int_set_header_switch_id_and_port_id_2() {
    modify_field(int_header.instruction_mask_0001, 0);
    modify_field(int_header.instruction_mask_0002, 2);
    add_header(int_switch_id_header);


    add_header(int_port_id_header);
    //set_tdelta();

    //modify_field(int_hop_latency_header.hop_latency,
    //intrinsic_metadata.current_global_timestamp - intrinsic_metadata.ingress_global_timestamp);

    modify_field(int_switch_id_header.switch_id, SWITCH_ID);

    add_to_field(ipv4.totalLen,4);
    add_to_field(int_header.ins_cnt,1); 

    modify_field(int_port_id_header.ingress_port_id, 
                    standard_metadata.ingress_port);
    modify_field(int_port_id_header.egress_port_id,
                    0);
    add_to_field(ipv4.totalLen,4);
    add_to_field(int_header.ins_cnt,1);
    


    modify_field(int_port_id_header.bos,1);

}

action int_set_header_switch_id_and_power(power,flag) {


    #ifdef SRC
        modify_field(int_header.instruction_mask_0001,2);
    #endif
    #ifdef INTERMEDIATE
        modify_field(int_header.instruction_mask_0002,2);
    #endif


    add_header(int_switch_id_header);
    modify_field(int_switch_id_header.switch_id, SWITCH_ID);

    add_to_field(ipv4.totalLen,4);
    add_to_field(int_header.ins_cnt,1);

    add_header(int_optical_power_header);
    modify_field(int_optical_power_header.flag,flag);
    modify_field(int_optical_power_header.optical_power, power);
    //modify_field(int_switch_id_header.op,1);
    add_to_field(ipv4.totalLen,4);
    add_to_field(int_header.ins_cnt,1);
    modify_field(int_optical_power_header.bos,1);
}

action int_set_header_switch_id_and_osnr(osnr,flag) {


    #ifdef SRC
        modify_field(int_header.instruction_mask_0001,3);
    #endif
    #ifdef INTERMEDIATE
        modify_field(int_header.instruction_mask_0002,3);
    #endif

    add_header(int_switch_id_header);
    modify_field(int_switch_id_header.switch_id, SWITCH_ID);

    add_to_field(ipv4.totalLen,4);
    add_to_field(int_header.ins_cnt,1);

    add_header(int_optical_osnr_header);
    modify_field(int_optical_osnr_header.flag,flag);
    modify_field(int_optical_osnr_header.optical_osnr, osnr);
    //modify_field(int_switch_id_header.op,1);
    add_to_field(ipv4.totalLen,4);
    add_to_field(int_header.ins_cnt,1);
    modify_field(int_optical_osnr_header.bos,1);

}
table tbl_int_instance_set_switch_id_and_port_id {
    actions {
        int_set_header_switch_id_and_port_id;    
    }

}

table tbl_int_instance_set_switch_id_and_port_id_2 {
    actions {
        int_set_header_switch_id_and_port_id_2;
    }
}

table tbl_int_instance_set_switch_id_and_latency {
    actions {
        int_set_header_switch_id_and_latency;
    }
}
/*
table tbl_int_instance_set_switch_id_and_latency_2 {
    actions {
        int_set_header_switch_id_and_latency_2;
    }
}
*/
table tbl_int_instance_set_switch_id_and_power {
    actions {
        int_set_header_switch_id_and_power;
    }

}

table tbl_int_instance_set_switch_id_and_osnr {
    actions {
        int_set_header_switch_id_and_osnr;    
    }
}
/*
table int_instance_set_port_id_and_latency{
    actions {
        int_set_header_port_id_and_latency;
    }
}
*/
action int_set_header_optical_power(power,flag) {
    add_header(int_optical_power_header);
    modify_field(int_optical_power_header.flag,flag);
    modify_field(int_optical_power_header.optical_power, power);
    modify_field(int_switch_id_header.op,1);
    add_to_field(ipv4.totalLen,4);
    add_to_field(int_header.ins_cnt,1);
    
}
action int_set_header_hop_latency() {
    add_header(int_hop_latency_header);
    //set_tdelta();

    //modify_field(int_hop_latency_header.hop_latency,
    //intrinsic_metadata.current_global_timestamp - intrinsic_metadata.ingress_global_timestamp);
    add_to_field(ipv4.totalLen,4);
    add_to_field(int_header.ins_cnt,1);
}
/*
action int_set_header_tx_utilization() {
    add_header(int_tx_utilization_header);
    
    modify_field(int_tx_utilization_header.tx_utilization,int_tx_utilization_metadata.tx_utilization);
    add_to_field(ipv4.totalLen,4);
    add_to_field(int_header.ins_cnt,1);

}
*/
/*
action int_set_header_arrival_retval() {
    add_header(int_arrival_retval_header);
    modify_field(int_arrival_retval_header.arrival_retval,
    (intrinsic_metadata.current_global_timestamp - int_arrival_time_metadata.arrival_time) & 0xFFFFFFFF);
    add_to_field(ipv4.totalLen,4);
    add_to_field(int_header.ins_cnt,1);
}
*/
/*
action int_set_header_pktlen() {
    add_header(int_pktlen_header);
    modify_field(int_pktlen_header.pktlen,int_tx_utilization_metadata.tx_utilization);
    add_to_field(ipv4.totalLen,4);
    add_to_field(int_header.ins_cnt,1);
}
*/
action int_update_header_hop_latency() {
    subtract(int_hop_latency_header.hop_latency,
    intrinsic_metadata.current_global_timestamp,
    intrinsic_metadata.ingress_global_timestamp);

}
action int_set_bos_switch_id() {
    modify_field(int_switch_id_header.bos, 1);
}

action int_set_bos_optical_power() {
    modify_field(int_optical_power_header.bos,1);
}
action int_set_header_no_optical_power() {
    modify_field(int_switch_id_header.op,0);
}

action int_set_bos_hop_latency() {
    modify_field(int_hop_latency_header.bos,1);
}
table int_instance_set_drop_counter {
    actions {
        int_set_header_drop_counter;
    }
}
/*
table int_instance_set_arrival_retval {
    actions {
        int_set_header_arrival_retval;
    }
}
*/
/*
table int_instance_set_pktlen {
    actions {
        int_set_header_pktlen;
    }
}
*/
/*
table int_instance_set_tx_utilization {
    actions {
        int_set_header_tx_utilization;
    }
}
*/
table int_instance_set_optical_power {
    reads {
        standard_metadata.egress_port : exact;

    }
    actions {
        int_set_header_optical_power;
        int_set_header_no_optical_power;
    }
}
table int_instance_set_switch_id {
    actions {
        int_set_header_switch_id;
    }
}
table int_instance_set_port_id {
    actions {
        int_set_header_port_id;
    }
}

table int_instance_set_hop_latency {
    actions {
        int_set_header_hop_latency;
    }
}
table int_instance_set_bos_switch_id {
    actions {
        int_set_bos_switch_id;
    }
}

table int_instance_set_bos_optical_power {
    actions {
        int_set_bos_optical_power;
    } 
}

table int_instance_set_bos_hop_latency {
    actions {
        int_set_bos_hop_latency;
    }
}
table int_instance_update_hop_latency {
    actions {
        int_update_header_hop_latency;
    }

}

control insert_int_metadata_stack {
/*
#ifdef CNT
    apply(int_instance_drop_counter);
#endif
#ifdef TX
    //apply(int_instance_set_tx_utilization);
    apply(int_instance_set_arrival_retval);
    apply(int_instance_set_pktlen);
#endif
    apply(int_instance_set_switch_id);
    if (instruction_meta.instruction  == 0) {
        //apply(int_instance_set_port_id);
         apply(int_instance_set_port_id);
       
    }
    if (instruction_meta.instruction == 1) {
        
        apply(int_instance_set_hop_latency);
        
    }
    if (instruction_meta.instruction == 2) {
        
        apply(int_instance_set_port_id_and_latency);
    } 
    apply(int_instance_update_hop_latency);
  
#ifdef OP
    apply(int_instance_set_optical_power);
#endif 
    
*/    
}


action int_set_header() {
    
    modify_field(ipv4.dscp,PROTOCOLS_INT);
    //for experiment test
    //modify_field(tcp.dstPort,8888);
    add_header(int_header);
    add_header(int_shim_header);
    add_to_field(ipv4.totalLen,12);
      
}
action int_update_header_source() {
    modify_field(int_shim_header.int_type,1);
    modify_field(int_shim_header.len,8);
    modify_field(int_header.ver,1);
    modify_field(int_header.rep,0);
    modify_field(int_header.c,0);
    modify_field(int_header.m,0);
    modify_field(int_header.ins_cnt,0);
    modify_field(int_header.total_hop_cnt,1);
    modify_field(int_header.max_hop_cnt,8);

}
action int_update_header_intermediate() {
    
    add_to_field(int_header.total_hop_cnt,1);
}
action int_update_header_sink() {
    add_to_field(int_header.total_hop_cnt,1);
}

action int_insert_err_e() {

    modify_field(int_header.e,1);
}
action int_insert_err_m() {
    modify_field(int_header.m,1);
}
table int_instance_insert_err_e {
    actions {
       int_insert_err_e; 
    }
}

table int_instance_insert_err_m {
    actions {
       int_insert_err_m; 
    }
}
table int_instance_insert_header_source {
    actions {
        int_set_header;
    }
}
table int_instance_update_header_source {
    actions {
        int_update_header_source;  
    }
}
table int_instance_update_header_intermediate {
    actions {
        int_update_header_intermediate;    
    }
}
table int_instance_update_header_sink {
    actions {
        int_update_header_sink;
    }
}

field_list copy_to_cpu_fields {
    standard_metadata.egress_spec;

}

action mirror(mirror_port) {
    modify_field(standard_metadata.egress_spec,mirror_port);
    clone_egress_pkt_to_egress(mirror_port, copy_to_cpu_fields);
    
}
table tbl_mirror {
    actions {
        mirror;
    }
}
action remove_int_header() {
    remove_header(int_header);
    remove_header(int_shim_header);
    modify_field(ipv4.dscp, 0x06);
    pop(int_value, 16);

}
table tbl_remove_int_header {
    actions {
        remove_int_header;
    }
}
control ingress { 
#ifdef CNT
    apply(tbl_ingress_count);
#endif
#ifdef SRC   
    //apply(tbl_ext_pool_reg_count);
    //apply(tbl_set_random_instruction);
#endif
    
    apply(tbl_forward); 
       
}
control source_node {
#ifdef TX
    apply(tbl_pktlen_count);
#endif
    apply(tbl_flow_count);
    //apply(tbl_ext_pool_reg_count);
    apply(tbl_ext_poll);
    if (packet_count_meta.packet_count == 1) { 
        
        if (ipv4.totalLen  < 1500) {
#ifdef TX
                apply(tbl_read_arrival_time_register);
                apply(tbl_write_arrival_time_register);
                apply(tbl_set_tx_utilization);
                
#endif
#ifdef CNT
                //apply(dummy_table_ext_poll_reg);
                //apply( tbl_read_drop_counter);
#endif           
                
                //apply(tbl_int_poll_reg_count);
                
                apply(int_instance_insert_header_source);
                apply(int_instance_update_header_source); 
                //apply(tbl_int_instance_set_switch_id_and_latency);
                apply(tbl_int_poll);
                if (int_packet_count_meta.int_packet_count == 1) {
                    apply(tbl_int_instance_set_switch_id_and_port_id);
                }
                if (int_packet_count_meta.int_packet_count == 2) {
                    apply(tbl_int_instance_set_switch_id_and_latency);
                    //apply(tbl_int_poll_reg_reset);
                }
                if (int_packet_count_meta.int_packet_count == 3) {
                
                apply(tbl_int_instance_set_switch_id_and_power);
                }

                if (int_packet_count_meta.int_packet_count == 4) {
                    apply(tbl_int_instance_set_switch_id_and_osnr);
                }
               

                
                
                /*
                if (int_packet_count_meta.int_packet_count == 2) {
                    //apply(tbl_int_instance_set_switch_id_and_power);
                    apply(tbl_int_instance_set_switch_id_and_port_id_2);
                    apply(tbl_int_poll_reg_reset);
                
                }
                */
                /*
                if(int_packet_count_meta.int_packet_count == 3) {
                 //   apply(tbl_int_instance_set_switch_id_and_port_id);
                    apply(tbl_int_instance_set_switch_id_and_osnr);
                //    apply(tbl_int_instance_set_switch_id_and_latency_2);
                    apply(tbl_int_poll_reg_reset);
                }  
                */
                //if(int_packet_count_meta.int_packet_count == 4) {
                    
                //}        
                //insert_int_metadata_stack(); 
                //apply(int_instance_set_bos_hop_latency);
                
                //apply(int_instance_update_hop_latency);
                
            
            } 
            else {
                apply(int_instance_insert_err_m);       
            }
                
    }
    /*
    if (packet_count_meta.packet_count == 1) {
        apply(tbl_ext_pool_reg_reset);    
    }
    */
}
control intermediate_node {
    if (valid (int_header)) {
        if (int_header.e != 1 and int_header.max_hop_cnt != int_header.total_hop_cnt) {
            if (int_header.m != 1 and ipv4.totalLen + int_header.ins_cnt << 2 < 1500) {
                apply(int_instance_update_header_intermediate); 
#ifdef CNT
                //apply(tbl_read_drop_counter);
#endif
                insert_int_metadata_stack(); 
                apply(int_instance_set_bos_hop_latency);
                apply(int_instance_update_hop_latency);
            } else {
                apply(int_instance_insert_err_m);
            }
        } else {
            apply(int_instance_insert_err_e);
        }
 
                        
    }

}
control sink_node {
    
    if(standard_metadata.instance_type == 0 and valid(int_header) ) {
        apply(tbl_mirror); 
        if (int_header.e != 1 and int_header.max_hop_cnt != int_header.total_hop_cnt) {
            if (int_header.m != 1 and ipv4.totalLen + int_header.ins_cnt << 2 < 1500) {
                apply(int_instance_update_header_sink);
#ifdef CNT
                //apply(tbl_read_drop_counter);
#endif
                insert_int_metadata_stack();
                apply(int_instance_set_bos_hop_latency);
                apply(int_instance_update_hop_latency); 
        
            } else {
                apply(int_instance_insert_err_m);
            } 
        } else {
            apply(int_instance_insert_err_e);
        }
                         
        
    }

}
control egress  {
#ifdef SRC  
    source_node();                  
#endif

#ifdef INTERMEDIATE
    intermediate_node();
#endif 

#ifdef SINK
    sink_node();
#endif   



}
