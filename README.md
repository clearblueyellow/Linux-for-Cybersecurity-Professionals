# Linux for Cybersecurity Professionals

## Basic Commands

### Network Reconnaissance

Network reconnaissance is the initial phase of many security assessments, focusing on gathering information about target networks and systems. Linux offers a suite of commands for this purpose.

ifconfig: Traditionally used to view and configure network interfaces. Example: ifconfig eth0 displays the IP address, MAC address, and other configuration details for the eth0 interface. While still prevalent, it's gradually being superseded.  

ip: The modern replacement for ifconfig, offering more advanced capabilities for network interface management, routing, and monitoring. Example: ip addr show lists IP addresses and network interfaces.  

ping: Tests network connectivity to a host by sending ICMP Echo Request packets. Example: ping google.com.  

netstat: Displays network connections, routing tables, interface statistics, masquerade connections, and multicast memberships. Example: netstat -an shows all active connections with IP addresses and port numbers. netstat -l shows listening ports, while netstat -t and netstat -u show TCP and UDP connections respectively.  

ss: A utility to investigate sockets, offering a faster alternative to netstat. Example: ss -tulnp shows listening TCP and UDP ports along with the processes using them.  

traceroute: Traces the path packets take to a network host, displaying each hop (router) along the way and the latency to each. Example: traceroute google.com.  

nslookup: Queries Internet domain name servers (DNS) to resolve hostnames to IP addresses and vice versa. Example: nslookup example.com.  

dig (Domain Information Groper): A more flexible and powerful tool for DNS lookups, providing detailed information about various DNS record types (A, MX, CNAME, etc.). Example: dig example.com. It is often preferred for DNS reconnaissance in penetration testing.  

whois: Retrieves registration information for domain names, including owner details, registration dates, and contact information. Example: whois example.com.  

nmap (Network Mapper): A powerful open-source tool for network exploration and security auditing. It can discover hosts, services, operating systems, and potential vulnerabilities.  

 arp: Displays and modifies the system's Address Resolution Protocol (ARP) cache. Example: arp -a shows the current ARP entries.

curl: A command-line tool for transferring data with URLs, supporting various protocols. Example: curl -I https://example.com fetches HTTP headers. Useful for web security analysis and API testing.

wget: A non-interactive network downloader. Example: wget https://example.com/file.zip downloads a file. Useful for automating downloads and web content scraping.

### Vulnerability Analysis

Vulnerability analysis involves identifying weaknesses in systems and applications. Kali Linux, a distribution tailored for penetration testing, includes many tools for this, often accessible via the command line.

nikto: A web server scanner that performs comprehensive tests against web servers for multiple items, including over 6700 potentially dangerous files/CGIs, checks for outdated versions of over 1250 servers, and version specific problems on over 270 servers. Example: nikto -h <target_URL>.

nmap (with NSE): Nmap Scripting Engine (NSE) allows users to write (and share) simple scripts to automate a wide variety of networking tasks. Many scripts are available for vulnerability detection.

OpenVAS: A framework of several services and tools offering a comprehensive and powerful vulnerability scanning and vulnerability management solution. While often managed via a web interface, its components can be interacted with or automated via CLI tools.

sqlmap: An open-source penetration testing tool that automates the process of detecting and exploiting SQL injection flaws and taking over database servers. Example: sqlmap -u "http://example.com/vuln.php?id=1".

Static Analysis (AppScan CLI - appscan.sh): For software vulnerability analysis, tools like HCL AppScan provide CLI interfaces for initiating static and dynamic analyses. The appscan.sh queue_analysis command can submit code (e.g., an IRX file) for scanning.

### Log Inspection

Log files are critical for understanding system behavior, troubleshooting issues, and investigating security incidents. Linux provides several commands for effective log inspection. Common log locations include /var/log/syslog (or /var/log/messages), /var/log/auth.log (or /var/log/secure for authentication events), /var/log/kern.log (kernel messages), and application-specific logs like /var/log/apache2/access.log.

cat: Concatenates and displays the content of files. Example: cat /var/log/syslog. Best for small files.

less: Allows backward and forward movement within a file, making it suitable for viewing large log files. Example: less /var/log/auth.log. Press q to quit, / to search.

tail: Displays the last part of a file.

head: Displays the first part of a file. Example: head -n 15 /var/log/auth.log.

grep: Searches for patterns in text. Extremely useful for filtering log entries.

journalctl: For systems using systemd, journalctl queries and displays messages from the systemd journal.
