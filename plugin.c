#include <stdint.h>
#include <nfp/me.h>
#include <nfp/mem_atomic.h>
#include <pif_common.h>
#include "pif_plugin.h"
#include "pif_registers.h"
#include <stdlib.h>
#include <stdint.h>
#include <pif_headers.h>

#include <pif_plugin_ipv4.h>
#include <nfp.h>

#include <pif_plugin_metadata.h>

static uint8_t first = 1;
//volatile __export __emem uint32_t lock1;
//latile __export __emem uint32_t lock;
volatile __declspec(atomic emem export  scope(global)) uint32_t lock;
volatile __declspec(atomic emem export scope(global)) uint32_t num = 0;
volatile __export __emem uint64_t pif_counter_DROP_NFD_NO_CREDITS;

__declspec(imem export scope(global) aligned(64)) int ext_semaphore[4] = {1,1,1,1};
__declspec(imem export scope(global) aligned(64)) int int_semaphore[4] = {1,1,1,1};
__declspec(imem export scope(global) aligned(64)) int ext_reg[4] = {0,0,0,0};
__declspec(imem export scope(global) aligned(64)) int int_reg[4] = {0,0,0,0};
void semaphore_down(volatile __declspec(mem addr40) void * addr) {
	/* semaphore "DOWN" = claim = wait */
    
	unsigned int addr_hi, addr_lo;
	__declspec(read_write_reg) int xfer;
	SIGNAL_PAIR my_signal_pair;
	addr_hi = ((unsigned long long int)addr >> 8) & 0xff000000;
	addr_lo = (unsigned long long int)addr & 0xffffffff;
	do {
		xfer = 1;
		__asm {
            mem[test_subsat, xfer, addr_hi, <<8, addr_lo, 1],\
                sig_done[my_signal_pair];
            ctx_arb[my_signal_pair]
        }
	} while (xfer == 0);
}

void semaphore_up(volatile __declspec(mem addr40) void * addr) {
	/* semaphore "UP" = release = signal */
    
	unsigned int addr_hi, addr_lo;
	__declspec(read_write_reg) int xfer;
	addr_hi = ((unsigned long long int)addr >> 8) & 0xff000000;
	addr_lo = (unsigned long long int)addr & 0xffffffff;

    __asm {
        mem[incr, --, addr_hi, <<8, addr_lo, 1];
    }

}
/*
int pif_plugin_set_reg(EXTRACTED_HEADERS_T *headers, MATCH_DATA_T *match_data) {
    semaphore_down(&reg_semaphore);

    /*my critical code*/
    /*
    ext_reg++;
    if(ext_reg == 3) {
        ext_reg = 0;
        int_reg++;
        if (int_reg == 3) {
            int_reg = 0;
        }
    }
    semaphore_up(&my_semaphore);
}
*/
int pif_plugin_set_int_reg(EXTRACTED_HEADERS_T *headers, MATCH_DATA_T *match_data) {
    __declspec(local_mem) int idx;
    idx = (int)pif_plugin_meta_get__int_index__index(headers);
    semaphore_down(&int_semaphore[idx]);

    /*my critical code*/
    int_reg[idx] = int_reg[idx] + 1;;
    pif_plugin_meta_set__int_packet_count_meta__int_packet_count(headers,int_reg[idx]);
    if(int_reg[idx] == 2) {
        int_reg[idx] = 0;
        //int_reg++;
        //pif_plugin_meta_set__int_packet_count_meta__int_packet_count(headers,int_reg);
        //if (int_reg == 3) {
        //    int_reg = 0;
        //}
    }
    semaphore_up(&int_semaphore[idx]);
    return PIF_PLUGIN_RETURN_FORWARD;
}

int pif_plugin_gen_random_num(EXTRACTED_HEADERS_T *headers, MATCH_DATA_T *match_data) {
    __xrw uint32_t randval ;
    __xrw uint32_t randval_2;
    __xrw uint64_t time;
    time = me_tsc_read();
    if (first) {
        first = 0;
        //local_csr_write(local_csr_pseudo_random_number,(local_csr_read(local_csr_timestamp_low) & 0xffff) + 1); 
        srand(time & 0x7fffffff);     
    }
    
    randval = rand() % 3; 
    //randval_2 = (rand()+1) % 3;  
    //randval = local_csr_read(local_csr_pseudo_random_number) & 0x7fffffff ;

    pif_plugin_meta_set__rand_meta__random_num(headers,randval);
    return PIF_PLUGIN_RETURN_FORWARD;

}
int pif_plugin_do_read_drop_counter(EXTRACTED_HEADERS_T *headers, MATCH_DATA_T *match_data) {
#ifdef CNT

    volatile __xrw uint32_t ingress_counter[2];
    volatile __xrw uint32_t egress_counter[2];
    volatile __xrw uint32_t clone_counter[2];
    uint32_t tmp;
    __xrw uint32_t xfer = 1;
    
    lock1 = 0;
    //mem_read_atomic(&xfer,&m,sizeof(uint32_t)); 
    /*              
    while(xfer == 1) {
        mem_test_set((void*)&xfer, (void*)&lock1, sizeof(uint32_t)); 
        
    }
    */
    //mem_read_atomic(ingress_counter,((__emem uint64_t*)pif_register_ingress_counter),sizeof(ingress_counter));

    
    //mem_read_atomic(egress_counter,((__emem uint64_t*)pif_register_egress_counter),sizeof(egress_counter));
#ifdef SINK
    //mem_read_atomic(clone_counter,((__emem uint64_t*)pif_register_clone_counter),sizeof(clone_counter));
    
    //tmp = ( ingress_counter[0] + clone_counter[0] - egress_counter[0]); 
#else
    //tmp = ( ingress_counter[0] - egress_counter[0]);
#endif 
    //xfer = 0;
    //pif_plugin_meta_set__int_drop_metadata__drop_counter(headers,tmp);
    //mem_write_atomic(&xfer, &lock1, sizeof(xfer));
    //+ ((ingress_counter[1] - ingress_counter[1]) << 32);
    //tmp = egress_counter[0] - ingress_counter[0];


    //volatile __xrw uint32_t drop_counter[2];
    //mem_read_atomic(drop_counter,((__emem uint64_t*)pif_counter_DROP_NFD_NO_CREDITS),sizeof(drop_counter));
    //pif_plugin_meta_set__int_drop_metadata__drop_counter(headers,drop_counter[0]&0x7FFFFFFF); 
#endif
    
    return PIF_PLUGIN_RETURN_FORWARD;                                                                                 
}

int pif_plugin_do_set_tx_utilization(EXTRACTED_HEADERS_T *headers, MATCH_DATA_T *match_data) {
#ifdef TX
     __xrw volatile uint32_t pkt_counter[2];
    __xrw uint64_t t = 0;
    __xrw uint32_t retval;
    __xrw uint32_t last[2];
    __xrw uint32_t now[2];
    __xrw uint32_t tx_utilization;
    uint32_t m = 1;
    PIF_PLUGIN_ipv4_T *_hdr_p;
    __xrw uint32_t xfer = 1;
    
    lock = 0;
    //mem_read_atomic(&xfer,&m,sizeof(uint32_t));               
    while(xfer == 1) {
        mem_test_set((void*)&xfer, (void*)&lock, sizeof(uint32_t)); 
        
    }

    //_hdr_p =  pif_plugin_hdr_get_ipv4(headers);
    //num = num + PIF_HEADER_GET_ipv4___totalLen(_hdr_p) + 14;
    mem_read_atomic(&pkt_counter,((__emem uint64_t*)(pif_register_pkt_counter)),sizeof(pkt_counter));
    pif_plugin_meta_set__int_tx_utilization_metadata__tx_utilization(headers,pkt_counter[0]);
    mem_write_atomic(&t,((__emem uint64_t*)pif_register_pkt_counter), sizeof(pkt_counter));
    lock = 0;
    //xfer = 0;
    //m_write_atomic(&xfer, &lock, sizeof(xfer));
#endif
    return PIF_PLUGIN_RETURN_FORWARD;
    
}

int pif_plugin_do_count(EXTRACTED_HEADERS_T *headers, MATCH_DATA_T *match_data) {

//    PIF_PLUGIN_ipv4_T *_hdr_p;
//    _hdr_p =  pif_plugin_hdr_get_ipv4(headers);
//    num = num + PIF_HEADER_GET_ipv4___totalLen(_hdr_p) + 14;
    return PIF_PLUGIN_RETURN_FORWARD;
    
}




