<#
.SYNOPSIS
  This script provides an overview of email-related DNS records for a list of domains.
.DESCRIPTION
  This script looks up the MX, SPF, DMARC, and SOA records for the provided array of domains using the specified DNS server.
  It then exports the results to a CSV file.
.PARAMETER Domains
  An array of one or more domain names (e.g. "griff.systems") to check.
.PARAMETER Domains
  An string containing the fully-qualified domain name or IP address of the DNS server to use for the checks.
.INPUTS
  None
.OUTPUTS
  None
.NOTES
  Updated by      : Griff Barker (github@griff.systems)
  Change Date     : 2025-05-07
  Purpose/Change  : Initial development
.EXAMPLE
  # Check records for a single domain, specifying DNS server by FQDN
 .\Invoke-EmailSecurityAudit.ps1 -Domains "griff.systems" -DnsServer "dns.google"
.EXAMPLE
  # Check records for a single domain, specifying DNS server by IP address
  .\Invoke-EmailSecurityAudit.ps1 -Domains "griff.systems" -DnsServer "8.8.8.8"
.EXAMPLE
  # Check records for multiple domains, specifying DNS server by FQDN
  .\Invoke-EmailSecurityAudit.ps1 -Domains @("griff.systems","domain.tld") -DnsServer "dns.google"
.EXAMPLE
  # Check records for multiple domains, specifying DNS server by IP address
  .\Invoke-EmailSecurityAudit.ps1 -Domains @("griff.systems","domain.tld") -DnsServer "8.8.8.8"
#>

[CmdletBinding()]
param (

  [Parameter(Position = 0, Mandatory = $True)]
  [ValidateNotNullorEmpty()]
  [array]$Domains,

  [Parameter(Position = 1, Mandatory = $False)]
  [string]$DnsServer = 'one.one.one.one'

)

begin {

  $reportingTable = New-Object System.Data.DataTable
  [void]$reportingTable.Columns.Add('domain')
  [void]$reportingTable.Columns.Add('mxRecordStatus')
  [void]$reportingTable.Columns.Add('spfRecordStatus')
  [void]$reportingTable.Columns.Add('dmarcRecordStatus')
  [void]$reportingTable.Columns.Add('mxRecord')
  [void]$reportingTable.Columns.Add('spfRecord')
  [void]$reportingTable.Columns.Add('dmarcRecord')
  [void]$reportingTable.Columns.Add('stateOfAuthority')

}

process {

  $totalDomains = $Domains.Count
  $currentDomain = 0

  foreach ($domain in $domains) {

    $currentDomain++
    Write-Progress -Activity 'Auditing email-rlated DNS records' -Status "Checking $domain" -PercentComplete (($currentDomain / $totalDomains) * 100)

    $mxRecord = ((Resolve-DnsName -Name "$domain" -Type MX -Server "$DnsServer").NameExchange) -join ','
    $spfRecord = ((Resolve-DnsName -Name "$domain" -Type TXT -Server "$DnsServer" | Where-Object { $_.Strings -like "*spf*" }).Strings) -join ','
    $dmarcRecord = ((Resolve-DnsName -Name ('_dmarc.' + "$domain") -Type TXT -Server "$DnsServer" | Where-Object { $_.Strings -like "*dmarc*" }).Strings) -join ','
    $nameServer = ((Resolve-DnsName -Name "$domain" -Type SOA -Server "$DnsServer").PrimaryServer) -join ','

    if ($null -eq $mxRecord) {
      $mxRecordStatus = 'NOT PRESENT'
    }
    else {
      $mxRecordStatus = 'PRESENT'
    }

    if ($null -eq $spfRecord) {
      $spfRecordStatus = 'NOT PRESENT'
    }
    if ($spfRecord -like "*-all") {
      $spfRecordStatus = 'HARD FAIL'
    }
    if ($spfRecord -like "*~all") {
      $spfRecordStatus = 'SOFT FAIL'
    }

    if ($null -eq $dmarcRecord) {
      $dmarcRecordStatus = 'NOT PRESENT'
    }
    if ($dmarcRecord -like "*none*") {
      $dmarcRecordStatus = 'NONE'
    }
    if ($dmarcRecord -like "*quarantine*") {
      $dmarcRecordStatus = 'QUARANTINE'
    }
    if ($dmarcRecord -like "*reject*") {
      $dmarcRecordStatus = 'REJECT'
    }

    [void]$reportingTable.Rows.Add($domain, $mxRecordStatus, $spfRecordStatus, $dmarcRecordStatus, $mxRecord, $spfRecord, $dmarcRecord, $nameServer)

  }

}

end {

  $reportingTable | Export-Csv -Path ("$($MyInvocation.MyCommand.Name.Replace('.ps1','_'))" + "$(Get-Date -Format 'yyyyMMdd_hhmmss').csv") -NoTypeInformation -Force

}