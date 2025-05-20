# Linux for Cybersecurity Professionals

## Bash Script

### Automated Network Host Discovery and Basic Port Scan

This script automates the initial steps of network reconnaissance: finding live hosts and performing a quick scan for common open ports. This is particularly useful when assessing a new network environment, as it quickly provides an overview of active systems and their potentially accessible services.

### Real-time Log Monitoring for Specific Keywords

This script provides a way to monitor log files in real-time for user-defined keywords, which is crucial for immediate detection of suspicious activities or critical errors. Early detection enables faster response, potentially mitigating the impact of security incidents.

### User Account Security Audit

Regularly auditing user accounts for security weaknesses is a fundamental aspect of system hardening and compliance. This script automates checks for common misconfigurations.

### Simple File Integrity Checker (fim.sh)

File Integrity Monitoring (FIM) is a critical security control that involves validating the integrity of operating system and application software files to detect unauthorized modifications. This script provides a basic FIM capability.

### Firewall Rule Lister

Firewalls are a primary defense mechanism. Regularly reviewing their rules ensures they are correctly configured and have not been tampered with or inadvertently weakened. This script helps in quickly displaying the current firewall configuration.

### Basic Incident Response Data Collector

During a security incident, rapidly collecting volatile system data is paramount before it is lost or altered by attacker actions or system reboots. This script automates the gathering of initial, critical information.

## Basic Commands

Cybersecurity is a multifaceted field, and Linux provides a rich ecosystem of command-line utilities that cater to its diverse domains. Understanding and effectively utilizing these commands is paramount for professionals seeking to conduct thorough security assessments, investigations, and defensive operations.

### Network Reconnaissance

Network reconnaissance is the initial phase of many security assessments, focusing on gathering information about target networks and systems. Linux offers a suite of commands for this purpose.

**ifconfig:** Traditionally used to view and configure network interfaces. Example: ifconfig eth0 displays the IP address, MAC address, and other configuration details for the eth0 interface. While still prevalent, it's gradually being superseded.  

**ip:** The modern replacement for ifconfig, offering more advanced capabilities for network interface management, routing, and monitoring. Example: ip addr show lists IP addresses and network interfaces.  

**ping:** Tests network connectivity to a host by sending ICMP Echo Request packets. Example: ping google.com.  

**netstat:** Displays network connections, routing tables, interface statistics, masquerade connections, and multicast memberships. Example: netstat -an shows all active connections with IP addresses and port numbers. netstat -l shows listening ports, while netstat -t and netstat -u show TCP and UDP connections respectively.  

**ss:** A utility to investigate sockets, offering a faster alternative to netstat. Example: ss -tulnp shows listening TCP and UDP ports along with the processes using them.  

**traceroute:** Traces the path packets take to a network host, displaying each hop (router) along the way and the latency to each. Example: traceroute google.com.  

**nslookup:** Queries Internet domain name servers (DNS) to resolve hostnames to IP addresses and vice versa. Example: nslookup example.com.  

**dig (Domain Information Groper):** A more flexible and powerful tool for DNS lookups, providing detailed information about various DNS record types (A, MX, CNAME, etc.). Example: dig example.com. It is often preferred for DNS reconnaissance in penetration testing.  

**whois:** Retrieves registration information for domain names, including owner details, registration dates, and contact information. Example: whois example.com.  

**nmap (Network Mapper):** A powerful open-source tool for network exploration and security auditing. It can discover hosts, services, operating systems, and potential vulnerabilities.  

**arp:** Displays and modifies the system's Address Resolution Protocol (ARP) cache. Example: arp -a shows the current ARP entries.

**curl:** A command-line tool for transferring data with URLs, supporting various protocols. Example: curl -I https://example.com fetches HTTP headers. Useful for web security analysis and API testing.

**wget:** A non-interactive network downloader. Example: wget https://example.com/file.zip downloads a file. Useful for automating downloads and web content scraping.

### Vulnerability Analysis

Vulnerability analysis involves identifying weaknesses in systems and applications. Kali Linux, a distribution tailored for penetration testing, includes many tools for this, often accessible via the command line.

**nikto:** A web server scanner that performs comprehensive tests against web servers for multiple items, including over 6700 potentially dangerous files/CGIs, checks for outdated versions of over 1250 servers, and version specific problems on over 270 servers. Example: nikto -h <target_URL>.

**nmap (with NSE):** Nmap Scripting Engine (NSE) allows users to write (and share) simple scripts to automate a wide variety of networking tasks. Many scripts are available for vulnerability detection.

**OpenVAS:** A framework of several services and tools offering a comprehensive and powerful vulnerability scanning and vulnerability management solution. While often managed via a web interface, its components can be interacted with or automated via CLI tools.

**sqlmap:** An open-source penetration testing tool that automates the process of detecting and exploiting SQL injection flaws and taking over database servers. Example: sqlmap -u "http://example.com/vuln.php?id=1".

**Static Analysis (AppScan CLI - appscan.sh):** For software vulnerability analysis, tools like HCL AppScan provide CLI interfaces for initiating static and dynamic analyses. The appscan.sh queue_analysis command can submit code (e.g., an IRX file) for scanning.

### Log Inspection

Log files are critical for understanding system behavior, troubleshooting issues, and investigating security incidents. Linux provides several commands for effective log inspection. Common log locations include /var/log/syslog (or /var/log/messages), /var/log/auth.log (or /var/log/secure for authentication events), /var/log/kern.log (kernel messages), and application-specific logs like /var/log/apache2/access.log.

**cat:** Concatenates and displays the content of files. Example: cat /var/log/syslog. Best for small files.

**less:** Allows backward and forward movement within a file, making it suitable for viewing large log files. Example: less /var/log/auth.log. Press q to quit, / to search.

**tail:** Displays the last part of a file.

**head:** Displays the first part of a file. Example: head -n 15 /var/log/auth.log.

**grep:** Searches for patterns in text. Extremely useful for filtering log entries.

**journalctl:** For systems using systemd, journalctl queries and displays messages from the systemd journal.

### Penetration Testing

**Metasploit Framework (msfconsole):** A powerful platform for developing, testing, and executing exploit code. Launched with msfconsole.

**Netcat (nc):** A versatile networking utility for reading from and writing to network connections using TCP or UDP.

**tcpdump:** A command-line packet analyzer that allows capturing and displaying TCP/IP and other packets being transmitted or received over a network.

**john:** A fast password cracker, primarily used for cracking hashed passwords. Example: john hashes.txt.

**hydra:** A parallelized login cracker which supports numerous protocols to attack. Example: hydra -l admin -P passwords.txt <target_IP> ssh attempts to brute-force SSH login.

**Aircrack-ng suite:** A suite of tools for auditing wireless networks (WEP/WPA/WPA2 cracking, packet sniffing, etc.).

### Digital Forensics

Digital forensics involves the recovery and investigation of material found in digital devices, often related to cybercrime. Linux provides several command-line tools crucial for forensic analysis. A key principle is to work on a copy (image) of the original evidence to maintain its integrity.

**dd:** Used for bit-by-bit copying of files or entire devices. Essential for creating forensic images of storage media.

**md5sum, sha256sum:** Calculate and verify cryptographic hashes (MD5, SHA256) of files. Used to ensure the integrity of evidence files and to identify known malicious files by comparing their hashes against databases.

**strings:** Extracts printable character sequences (strings) from binary files. Useful for finding human-readable content in executables, memory dumps, or unknown file formats, potentially revealing malware indicators, URLs, or hidden messages.

**grep:** Already mentioned for log inspection, grep is also vital in forensics for searching through files (including image files or extracted text) for specific keywords, patterns, or regular expressions.

**mount:** Used to attach file systems (from disk images or physical devices) to the directory tree. In forensics, it's crucial to mount evidence in read-only mode to prevent accidental modification.

**lsof (List Open Files):** Lists information about files opened by processes. Can help identify which process is using a particular file or network port.

**hexdump:** Displays file content in hexadecimal (and optionally ASCII) format. Allows for low-level analysis of file structures, data carving, or identifying hidden data.

### System Auditing

System auditing involves examining system configurations, user activities, and security settings to ensure compliance and identify potential weaknesses.

**auditd daemon and tools (auditctl, ausearch, aureport):** The Linux Audit Daemon (auditd) provides detailed logging of system calls, file access, network events, and security-relevant activities.

**auditctl:** Controls the audit system, adds or deletes rules. Rules are typically defined in /etc/audit/rules.d/audit.rules. Example: auditctl -w /etc/passwd -p war -k passwd_changes watches the passwd file for write, append, or read access and tags it with a key.

**ausearch:** Queries audit logs for specific events. Example: ausearch -k passwd_changes searches for events with the "passwd_changes" key. ausearch -m USER_LOGIN -sv no searches for failed login events.

**aureport:** Generates summary reports from audit logs. Example: aureport -l reports on logins.

**auditd:** auditd is a powerful tool for creating a comprehensive audit trail, essential for security monitoring and compliance. Its configuration file is /etc/audit/auditd.conf.

**cat /etc/passwd:** Lists local user accounts.

**cat /etc/shadow:** Contains encrypted passwords and account expiration information (requires root).

**cat /etc/group:** Lists local groups.

**cat /etc/sudoers:** Defines which users/groups can run commands as root (requires root, use visudo to edit).
 
**chage -l <username>:** Displays password aging information for a user.

### Incident Response

Incident response (IR) involves reacting to and managing cybersecurity incidents. Quick and accurate data collection is crucial during IR.

**User Activity:** who (who is logged on), w (who is logged on and what they are doing), last (recent logins), lastlog (most recent login per user).

**System Information:** date, hostname, uname -a, uptime.

**Network Information:** ifconfig -a or ip a (network interfaces), netstat -antup or ss -tulnp (active connections, listening ports), route -n (routing table), iptables -L -n -v (firewall rules).

**Process Information:** ps aux or ps -ef (running processes), pstree -p (process tree with PIDs), lsof -p <PID> (list open files for a specific process).

**Log Snippets:** tail /var/log/auth.log, tail /var/log/messages.

Many of these commands are often combined into incident response scripts like IRLinux_Script.sh or IRLinuxInvestigation.sh to automate the collection of volatile data into a single output file (e.g., /tmp/IRLinux.txt). These scripts prompt for specific inputs like usernames or PIDs to tailor the data collection.

**find / -mtime -2 -ls:** Find files modified in the last 2 days.

**find / -atime -2 -ls:** Find files accessed in the last 2 days.

**find / -nouser -print:** Find files with no owner.

