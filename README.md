# Invoke-EmailDnsRecordAudit
A simple script for checking email-related DNS records for your domains.

## Use Case
A quick and easy way to check if your domains have MX, SPF, and DMARC records configured as expected, along with identifying the authoritative name server for the domain.

## Prerequisites
You'll need the following for this to work:  
  - Network connectivity between the client where you run the script and the DNS server that you will be querying.

## Getting Started
### Get the script
#### Option 1: Clone the repository
Clone this repo onto the server where the script will run:  
```
git clone https://github.com/griffeth-barker/Invoke-EmailDnsRecordAudit.git
```

#### Option 2: Download the script directly
Use PowerShell to download the script file directly:
```PowerShell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/griffeth-barker/Invoke-EmailDnsRecordAudit/main/Invoke-EmailDnsRecordAudit.ps1" -OutFile "$($env:USERPROFILE)\Downloads\Invoke-EmailDnsRecordAudit.ps1"
```  
  
### Run the script
Here are some examples of how to run the script:  
```
.EXAMPLE
  # Check records for a single domain, specifying DNS server by FQDN
 .\Invoke-EmailSecurityAudit.ps1 -Domains "griff.systems" -DnsServer "one.one.one.one"

.EXAMPLE
  # Check records for a single domain, specifying DNS server by IP address
  .\Invoke-EmailSecurityAudit.ps1 -Domains "griff.systems" -DnsServer "1.1.1.1"

.EXAMPLE
  # Check records for multiple domains, specifying DNS server by FQDN
  .\Invoke-EmailSecurityAudit.ps1 -Domains @("griff.systems","domain.tld") -DnsServer "one.one.one.one"

.EXAMPLE
  # Check records for multiple domains, specifying DNS server by IP address
  .\Invoke-EmailSecurityAudit.ps1 -Domains @("griff.systems","domain.tld") -DnsServer "1.1.1.1"
```