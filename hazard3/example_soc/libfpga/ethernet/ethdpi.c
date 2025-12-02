
// modified by laurentiu cristian duca 20251128
// Artem Voropaev author 20251106

#include <stdio.h>          // printf, perror, ..
#include <arpa/inet.h>      // sockaddr, inet_aton, ..
#include <linux/if.h>       // ifreq, IFF_TAP, IFF_NO_PI, ..
#include <linux/if_tun.h>   // TUNSETIFF, ..
#include <string.h>         // memset, strncpy, ..
#include <sys/types.h>      // ssize_t, ..
#include <sys/stat.h>       // stat, ..
#include <fcntl.h>          // open, fcntl, ..
#include <sys/ioctl.h>      // ioctl, ..
#include <errno.h>          // errno, ..
#include <stdlib.h>         // system, ..
#include <svdpi.h>          // DPI-C
#include <verilated.h>

#include <assert.h>
#include <unistd.h>  // For close().
#include <poll.h>

//#include "obj_dir/Vtop__Dpi.h"

#define MTU_SIZE (1500) // MTU
// 
uint8_t buffer[MTU_SIZE], rxbuf[MTU_SIZE];
int tap_fd=-1;

/**
 * @brief Reads data from a file descriptor
 * @param fd File descriptor to read from
 * @param buf Buffer to read data into
 * @param n Number of bytes to read
 * @return Number of bytes read
 */
int fd_read(int fd, char *buf, int n){
  
  int nread;

  if((nread=read(fd, buf, n))<0){
    perror("Reading data");
    exit(1);
  }
  return nread;
}

/**
 * @brief Writes data to a file descriptor
 * @param fd File descriptor to write to
 * @param buf Buffer to write data from
 * @param n Number of bytes to write
 * @return Number of bytes written
 */
int fd_write(int fd, char *buf, int n){
  
  int nwrite;

  if((nwrite=write(fd, buf, n))<0){
    perror("Writing data");
    exit(1);
  }
  return nwrite;
}

/**
 * @brief Prints bytes in wireshark style
 * @param data Pointer to the data to print
 * @param len Length of the data
 */
void print_bytes(uint8_t *data, uint32_t len) {
    for (int i = 0; i < len; i++) {
        if (i > 0 && (i % 16) == 0) {
            printf("\n");
        }
        printf("%02x ", data[i]);
    }
    printf("\n");
}

extern "C" void host_delay(int n);
extern "C" void rxgotnew(int nbytes); 
extern "C" void rxoctet(unsigned char octet);

int pktlen=0;
extern "C" int addbytetotxframe(unsigned char b)
{
   	buffer[pktlen++] = b;
        return 0;
}

extern "C" int sendtxframe()
{
	fd_write(tap_fd, (char*)&buffer[0], pktlen);
    	printf("packet sent\n");
    	//close(tap_fd);
	return 0;
}

extern "C" int checkrx()
{
        int ret;
        fd_set rd_set;
        struct timeval timeout;
                
        timeout.tv_sec=0; // no-wait, just check
        timeout.tv_usec=0; 
        FD_ZERO(&rd_set);
        FD_SET(tap_fd, &rd_set);
                
        // wait for data from TAP device - no timeout
        ret = select(tap_fd + 1, &rd_set, NULL, NULL, &timeout); 
        if ( ret < 0 ) {
            int errsv = errno;
            if (errsv == EINTR) {
                return 0;
            } 
            if (errsv == EAGAIN) {
                return 0;
            } else { 
                printf("HOST: ERROR: failed to read from TAP device: fd=%x, errsv=%x :  %s\n", tap_fd, errsv, strerror(errsv));
                close(tap_fd);
                return -5;
            }
        }

        // check if data is available from TAP device
        if(FD_ISSET(tap_fd, &rd_set)) {
            int nbytes = fd_read(tap_fd, (char*)&rxbuf[0], MTU_SIZE);
            if (nbytes) {
                printf("HOST: TAP-RD: nbytes=%03d\n", nbytes);
                // print bytes in wireshark style
                //print_bytes(rxbuf, nbytes);
                //printf("HOST: rxgotnew\n");
                rxgotnew(nbytes);
                // put bytes to TX queue
                for (int i = 0; i < nbytes; i++) {
                    //printf("HOST: rxoctet i=%d\n", i);
                    rxoctet(rxbuf[i]);
                }
            } else {
                printf("HOST: !!! Bad packet !!!: nbytes=%x\n", nbytes);
            }
        }

	return 0;
}


/**
 * @return 0 on success, -1 on failure
 */
extern "C" int ethdpiinit()
{
    Verilated::scopesDump();
    svSetScope(svGetScopeFromName("TOP.m_topsim.es.eth0"));

    struct ifreq ifr;
    int err = -1;
    char tap_name[IFNAMSIZ] = "tap0";
    
    memset(&ifr, 0, sizeof(ifr));
    // open TAP device
    tap_fd = open("/dev/net/tun", O_RDWR);
    if( tap_fd < 0 ) {
        printf("HOST: ERROR: failed to open TAP device: fd=%x\n", tap_fd);
        return -1;
    }
    // 
    ifr.ifr_flags = IFF_TAP | IFF_NO_PI; // IFF_TAP: TAP interface, IFF_NO_PI: no protocol information
    strncpy(ifr.ifr_name, tap_name, IFNAMSIZ);
    
    err = ioctl(tap_fd, TUNSETIFF, (void *)&ifr); 
    if( err < 0 ) { 
        int errsv = errno;
        printf("HOST: ERROR: failed to set TAP device name: fd=%x, errsv=%x :  %s\n", tap_fd, errsv, strerror(errsv));
        close(tap_fd);
        return -2;
    }

    int flags = fcntl(tap_fd, F_GETFL, 0);
    fcntl(tap_fd, F_SETFL, flags | O_NONBLOCK);

    printf("HOST: TAP device %s is ready\n", ifr.ifr_name);

#if 0
    // MAIN LOOP
    while (1) {
        int ret;
        fd_set rd_set;
        struct timeval timeout;
        
        timeout.tv_sec=0; // no-wait, just check
        timeout.tv_usec=0;
        FD_ZERO(&rd_set);
        FD_SET(tap_fd, &rd_set);
        
        // wait for data from TAP device - no timeout
        ret = select(tap_fd + 1, &rd_set, NULL, NULL, &timeout); 
        if ( ret < 0 ) {
            int errsv = errno;
            if (errsv == EINTR) { 
                continue;
            } 
            if (errsv == EAGAIN) { 
                continue;
            } else { 
                printf("HOST: ERROR: failed to read from TAP device: fd=%x, errsv=%x :  %s\n", tap_fd, errsv, strerror(errsv));
                close(tap_fd);
                return -5;
            }
        }
	
        // check if data is available from TAP device
        if(FD_ISSET(tap_fd, &rd_set)) {
            int nbytes = fd_read(tap_fd, (char*)&rxbuf[0], MTU_SIZE);
            if (nbytes) {
                printf("HOST: TAP-RD: nbytes=%03d\n", nbytes);
                // print bytes in wireshark style
                //print_bytes(rxbuf, nbytes);
		//printf("HOST: rxgotnew\n");
		rxgotnew(nbytes);
                // put bytes to TX queue
                for (int i = 0; i < nbytes; i++) {
		    //printf("HOST: rxoctet i=%d\n", i);
                    rxoctet(rxbuf[i]); 
                }
            } else {
                printf("HOST: !!! Bad packet !!!: nbytes=%x\n", nbytes);
            }
        }

        // check if there are any packets from DUT - thread safe mailbox
        int npkt;
        int pkt_len;
        // check if there are any packets from DUT
        host_rx_pkt_valid(&npkt); 

        if (npkt > 0) { // got packet
            // pull packet from thread safe mailbox to the read queue
            host_rx_pkt_pull(&pkt_len); 
            printf("HOST: send packet - sz=%d\n", pkt_len);
            // get bytes from packet
            for (int i = 0; i < pkt_len; i++) {
                host_rx_pkt_get_data(&buffer[i], i); 
            }
            fd_write(tap_fd, &buffer[0], pkt_len);
        }

	// HDL-dly
        //host_delay(1000);
    }

    printf("HOST exiting...\n");
    close(tap_fd);
#endif
    
    return 0;
}
