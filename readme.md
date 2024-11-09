# Bypass-403 Tool

Bypass-403 is a powerful tool designed to test 403 Forbidden bypass methods on web domains and subdomains. It utilizes various headers and path-based techniques to attempt access to restricted endpoints. This tool is intended for security researchers, ethical hackers, and bug bounty hunters to assist in responsible vulnerability disclosure and security assessments.

## Features

- Bypass 403 Forbidden responses using header and path manipulation techniques.
- Supports single domains, multiple subdomains, and custom wordlists.
- Flexible usage: specify a single domain or load domains from a file.
- Optional wordlist support to test specific paths for each domain.

## Installation

Clone the repository:
   ```
   git clone https://github.com/neasher1/403-Forbidden-Bypass.git
   cd bypass-403
   chmod +x bypass-403.sh
   ```


## Usage
### Basic Usage Examples
- For a single domain without a path or wordlist:
```
./bypass-403.sh https://example.com

This checks for 403 bypassing on the root path / of https://example.com.
```


- For a single domain with a specific path:
```
./bypass-403.sh https://example.com admin

This checks for 403 bypassing on https://example.com/admin
```


- For a single domain with a wordlist:
```
./bypass-403.sh https://example.com -w wordlist.txt

This checks for 403 bypassing on each path in wordlist.txt for https://example.com.
```

- For multiple subdomains from a file:
```
./bypass-403.sh subdomains.txt

This checks for 403 bypassing on the root path / for each domain in subdomains.txt.

```


- For multiple subdomains with a wordlist:
```
./bypass-403.sh subdomains.txt -w wordlist.txt

This checks for 403 bypassing on each path in wordlist.txt for each domain in subdomains.txt.

```

- Specify an Output File for 200 Status Results:
```
./bypass-403.sh live-subs.txt -w wordlist.txt -o output.txt

If user didn't save output, it will automatically saved 200 status output in 200-status-outputs.txt file. Appends any URLs with a 200 status code to output.txt, preserving previous results across multiple runs.

```


## Wordlist Format
```
admin
secret
dashboard
```


## How It Works
- The Bypass-403 tool performs the following steps for each domain and path:

- Header Manipulation: It adds various headers like X-Forwarded-For, X-Originating-IP, and others to see if any of these headers bypass the 403 restriction.

- Path Encoding & Manipulation: It attempts different encoded paths and appends characters like ?, %20, /..;/ to the URLs to test access.

- Wordlist Testing (Optional): If a wordlist is provided, the script will apply all bypass techniques to each path in the wordlist, testing one path at a time.

- 200 Status Logging: Any request that returns a 200 status code is printed in green and saved to 200-outputs.txt (or your specified output file) to retain results for easy review. 

- Output: The tool outputs HTTP response codes and sizes for each request, which can be reviewed to see if access was granted to previously forbidden paths.


## Disclaimer
This tool is intended for authorized security testing and research purposes only. Ensure you have permission to test the target domains before using this tool. Unauthorized usage is prohibited and may violate terms of service or legal regulations.