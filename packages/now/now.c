#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <sys/socket.h>
#include <sys/time.h> // FIX: Explicitly required for struct timeval definition

#define BUFFER_SIZE 4096

static int query_public_dns(const char *hostname, struct in_addr *out_addr) {
    int dns_fd = socket(AF_INET, SOCK_DGRAM, 0);
    if (dns_fd < 0) return 0;

    struct timeval tv = {2, 0};
    setsockopt(dns_fd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));

    struct sockaddr_in dns_server;
    memset(&dns_server, 0, sizeof(dns_server));
    dns_server.sin_family = AF_INET;
    dns_server.sin_port = htons(53);
    dns_server.sin_addr.s_addr = inet_addr("1.1.1.1");

    unsigned char packet[512];
    memset(packet, 0, sizeof(packet));

    packet[0] = 0xAB; packet[1] = 0xCD;
    packet[2] = 0x01; packet[3] = 0x00;
    packet[5] = 0x01;

    int p = 12;
    const char *start = hostname;
    const char *end;
    while ((end = strchr(start, '.')) != NULL) {
        int len = end - start;
        packet[p++] = len;
        memcpy(&packet[p], start, len);
        p += len;
        start = end + 1;
    }
    int len = strlen(start);
    packet[p++] = len;
    memcpy(&packet[p], start, len);
    p += len;
    packet[p++] = 0x00;

    packet[p++] = 0x00; packet[p++] = 0x01;
    packet[p++] = 0x00; packet[p++] = 0x01;

    if (sendto(dns_fd, packet, p, 0, (struct sockaddr *)&dns_server, sizeof(dns_server)) < 0) {
        close(dns_fd);
        return 0;
    }

    int res = recv(dns_fd, packet, sizeof(packet), 0);
    close(dns_fd);
    if (res < 30) return 0;

    memcpy(&(out_addr->s_addr), &packet[res - 4], 4);
    return 1;
}

int main(int argc, char *argv[]) {
    if (argc < 5) return 1;

    const char *hostname = argv[1];
    int port = atoi(argv[2]);
    const char *path = argv[3];
    const char *output_filename = argv[4];

    struct in_addr target_ip;
    
    struct addrinfo hints, *dns_res;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;

    if (getaddrinfo(hostname, NULL, &hints, &dns_res) == 0) {
        target_ip = ((struct sockaddr_in *)dns_res->ai_addr)->sin_addr;
        freeaddrinfo(dns_res);
    } else {
        if (!query_public_dns(hostname, &target_ip)) {
            return 1; 
        }
    }

    int sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) return 2;

    struct sockaddr_in serv_addr;
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(port);
    serv_addr.sin_addr = target_ip;

    if (connect(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
        close(sockfd);
        return 3;
    }

    char request[2048];
    strcpy(request, "GET ");
    strcat(request, path);
    strcat(request, " HTTP/1.1\r\nHost: ");
    strcat(request, hostname);
    strcat(request, "\r\nUser-Agent: Wget/1.20\r\nConnection: close\r\n\r\n");
    
    send(sockfd, request, strlen(request), 0);

    int out_fd = open(output_filename, O_WRONLY | O_CREAT | O_TRUNC, 0666);
    if (out_fd < 0) { close(sockfd); return 4; }

    char buffer[BUFFER_SIZE];
    ssize_t bytes_received;
    int header_stripped = 0;
    size_t header_buf_len = 0;
    char header_buffer[BUFFER_SIZE * 2];

    while ((bytes_received = recv(sockfd, buffer, BUFFER_SIZE, 0)) > 0) {
        if (!header_stripped) {
            if (header_buf_len + bytes_received < sizeof(header_buffer)) {
                memcpy(header_buffer + header_buf_len, buffer, bytes_received);
                header_buf_len += bytes_received;
            } else {
                write(out_fd, buffer, bytes_received);
                continue;
            }
            char *header_end = strstr(header_buffer, "\r\n\r\n");
            if (header_end) {
                size_t header_len = (header_end - header_buffer) + 4;
                size_t payload_len = header_buf_len - header_len;
                if (payload_len > 0) {
                    write(out_fd, header_buffer + header_len, payload_len);
                }
                header_stripped = 1;
            }
        } else {
            write(out_fd, buffer, bytes_received);
        }
    }
    close(sockfd);
    close(out_fd);
    return 0;
}
