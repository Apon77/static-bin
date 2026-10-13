#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <sys/socket.h>

#define BUFFER_SIZE 4096

int main(int argc, char *argv[]) {
    if (argc < 5) return 1;

    const char *hostname = argv[1];
    int port = atoi(argv[2]);
    const char *path = argv[3];
    const char *output_filename = argv[4];

    struct hostent *he = gethostbyname(hostname);
    if (!he) return 1;

    int sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) return 2;

    struct sockaddr_in serv_addr;
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(port);
    memcpy(&serv_addr.sin_addr, he->h_addr_list[0], he->h_length);

    if (connect(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
        close(sockfd);
        return 3;
    }

    // FIX: Allocated a valid stack buffer instead of a single character slot
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
