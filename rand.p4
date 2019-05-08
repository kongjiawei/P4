
counter dummy_counter {
    type : packets;
    
    instance_count : 1;
}


/*********************************************
    Generating random number
**********************************************/
#define RANDOM_NUM_BIT_WIDTH 32
field_list l3_rand_hash_fields {
    rand_meta.random_num;
    //intrinsic_metadata.current_global_timestamp;
}

field_list_calculation rand_hash {
    input {
        
        l3_rand_hash_fields;
    }
    algorithm : crc32;
    output_width : RANDOM_NUM_BIT_WIDTH;
}
//count for droped packet
action _drop() {
    count(dummy_counter,0);
    drop();
}
//generate randon num
primitive_action gen_random_num();
action set_rand_select(base, cnt, ratio) {
//
    gen_random_num();
    //
    //sampling_random_num = base + rand_hash % cnt
    modify_field_with_hash_based_offset(rand_meta.sampling_random_num, base,
                                        rand_hash, cnt);
    //modify_field(rand_meta.sampling_ratio, ratio);
   
   
}

table set_rand_select {
    actions {
        set_rand_select;
    
    }

}


header_type int_packet_count_meta_t {
    fields {
        int_packet_count : 32;
    }

}
metadata int_packet_count_meta_t int_packet_count_meta;
@pragma netro reglock register
register int_poll_reg {
    width : 32;
    instance_count : 1;

}

action int_poll_reg_count(){
    register_read(int_packet_count_meta.int_packet_count, int_poll_reg, 0);
    register_write(int_poll_reg, 0, int_packet_count_meta.int_packet_count + 1);
}

action int_poll_reg_reset() {
    
    register_write(int_poll_reg, 0, 0);
}

table tbl_int_poll_reg_count {

    actions{
        int_poll_reg_count;
    }
}

table tbl_int_poll_reg_reset {
    actions {
        int_poll_reg_reset;
    }
}

primitive_action set_ext_reg();
primitive_action set_int_reg();
action ext_poll() {
    set_ext_reg();
}
action int_poll() {
    set_int_reg();
}
table tbl_ext_poll {
    actions {
        ext_poll;
    }
}
table tbl_int_poll {
    actions {
        int_poll;
    }
}

counter flow_counter {
    type : packets;
    instance_count : 64;
}
action flow_count() {

    count(flow_counter,int_index.index);


}

table tbl_flow_count {
    actions {
        flow_count;
    }

}




