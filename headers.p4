

header_type ethernet_t {
    fields {
        dstAddr : 48;
        srcAddr : 48;
        etherType : 16;
    }
}

header_type ipv4_t {
    fields {
        version : 4;
        ihl : 4;
        //diffserv : 8;
        dscp : 6;
        ecn : 2;
        totalLen : 16;
        identification : 16;
        flags : 3;
        fragOffset : 13;
        ttl : 8;
        protocol : 8;
        hdrChecksum : 16;
        srcAddr : 32;
        dstAddr: 32;
    }
}

header_type udp_t {
    fields {
        srcPort : 16;
        dstPort : 16;
        length_ : 16;
        checksum : 16;
    }
}

header_type int_shim_header_t {
    fields {
        int_type : 8;
        rsvd1    : 8;
        len      : 8;
        dscp     : 6;
        rsvd2    : 2;

    }

}
header_type int_header_t {
    fields {

        ver : 2;
        rep : 2;
        c   : 1;
        e   : 1;
        m   : 1;
        rsvd1 : 4;
        ins_cnt     : 5;
        max_hop_cnt : 8;
        total_hop_cnt :8;
        instruction_mask_0001 : 4;
        instruction_mask_0002 : 4;
        instruction_mask_0003 : 4;
        instruction_mask_0004 : 4;
        rsvd3 : 16;
    
    }
}

// INT meta-value headers - different header for each value type
// bos is index of parser to parse int_value or protocol_value 
header_type int_switch_id_header_t {
    fields {
        bos : 1;
        op  : 1;
        switch_id : 30;
    }
}


header_type int_port_id_header_t {
    fields {
        bos : 1;
        ingress_port_id : 15;
        egress_port_id  : 16;
    }
}



header_type int_hop_latency_header_t {
    fields {
        bos : 1;
        hop_latency : 31;
    }
}

header_type int_q_occupancy_header_t {
    fields {
        bos                 : 1;
        rsvd                : 2;
        qid                 : 5;
        q_occupancy         : 24;
    }
}
header_type int_ingress_tstamp_header_t {
    fields {
        bos                 : 1;
        ingress_tstamp      : 31;
    }
}
header_type int_egress_tstamp_header_t {
    fields {
        bos                 : 1;
        egress_tstamp       : 31;
    }
}
/*
header_type int_optical_power_header_t {
    fields {
        bos : 1;
        flag : 1;
        optical_power : 30;
    }

}
*/
header_type int_drop_counter_header_t {
    fields {
        bos : 1;
        drop_counter :31;
        
    }
}

header_type int_tx_utilization_header_t {
    fields {
        bos : 1;
        tx_utilization : 31;

    }
}

header_type int_arrival_retval_header_t {
    fields {
        bos : 1;
        arrival_retval : 31;
    }
}

header_type int_pktlen_header_t {
    fields {
        bos : 1;
        pktlen : 31;
    }
}
/*
header_type int_postcard_header_t {
    fields {
        switch_id : 32;
        ingress_port_id : 16;
        egress_port_id : 16;
        latency : 32;   
    
    }

}
header int_psotcard_header_t int_postcard_header;
*/
//generic int value (info) header for extraction
header_type int_value_t {
    fields {
        bos : 1;
        value : 31;
    }
}
header_type tcp_t {
    fields {
        srcPort : 16;
        dstPort : 16;
        seqNo : 32;
        ackNo : 32;
        dataOffset :4;
        res : 3;
        ecn : 3;
        ctrl : 6;
        window : 16;
        checksum : 16;
        urgentPtr : 16; 
              
    }
    
} 

header_type pkt_payload_t {
    fields {
        pktPayload : 64;
    }
} 
//rand 
/*
header_type rand_header_t {
    

}*/

header_type tcp_length_meta_t {
    fields {
        tcpLength : 16;        

    }

}
metadata tcp_length_meta_t tcp_length_meta;

header_type rand_meta_t {
    fields {
        sampling_ratio : 32;
        random_num : 32;
        sampling_random_num : 32;
    }
}
metadata rand_meta_t rand_meta;

header_type intrinsic_metadata_t {
    fields {
        ingress_global_timestamp : 64;
        current_global_timestamp : 64;
    }
}

metadata intrinsic_metadata_t intrinsic_metadata;

header_type meta_t {
    fields {
        tdelta : 32;
    }
}
metadata meta_t meta;


header_type int_metadata_t {
    fields {
        remaining_hop_cnt : 16;
        int_inst_cnt : 16; 
    }
}

metadata int_metadata_t int_metadata;

header_type int_drop_metadata_t {
    fields {
        drop_counter : 32;
    }
} 
metadata int_drop_metadata_t int_drop_metadata;

header_type int_arrival_time_metadata_t {
    fields {
        arrival_time : 64;
    }
}
metadata int_arrival_time_metadata_t int_arrival_time_metadata;
/*
header_type int_tx_utilization_metadata_t {
    fields {
        
        tx_utilization : 32;
    }
}
metadata int_tx_utilization_metadata_t int_tx_utilization_metadata;

header_type int_pktlen_sum_in_retval_t {
    fields {
        pktlen_sum_in_retval :32;
    }
}
metadata int_pktlen_sum_in_retval_t int_pktlen_sum_in_retval;
*/
header_type mirror_session_t {
    fields {
        session_id : 32;
    }
}
metadata mirror_session_t mirror_session;

header_type int_optical_power_header_t {
    fields {
        bos : 1;
        flag : 1;
        optical_power : 30;
    }

}
header_type int_optical_osnr_header_t {
    fields {
        bos : 1;
        flag : 1;
        optical_osnr : 30;
    }

}
header_type int_index_t {

    fields {
        index : 8;
    }
}
metadata int_index_t int_index;