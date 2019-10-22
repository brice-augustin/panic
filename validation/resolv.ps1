Resolve-DnsName -QuickTimeout www.google.com

if ($?)
{
  exit 0
}
else
{
  exit 1
}
