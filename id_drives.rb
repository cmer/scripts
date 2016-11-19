#!/usr/bin/env ruby

# This script identifies local drives and to which interface they're attached.
# This was tested on Linux (Slackware) only.

require 'yaml'
lspci = {}
drives = {}

`lspci`.each_line do |l|
  m = l.match(/(\S*)\s(.*)/)
  lspci[m[1]] = m[2]
end

('a'..'z').each do |letter|
  drive = "/dev/sd#{letter}"
  next unless File.exist?(drive)
  regexp = /[^=]*\=(.*)/
  drives[drive] = {}
  drives[drive][:devpath]  = `udevadm info -q all -n #{drive} | grep DEVPATH`.match(regexp)[1] rescue nil
  drives[drive][:vendor]   = `udevadm info -q all -n #{drive} | grep ID_VENDOR`.match(regexp)[1] rescue nil
  drives[drive][:model]    = `udevadm info -q all -n #{drive} | grep ID_MODEL`.match(regexp)[1] rescue nil
  drives[drive][:serial]   = `udevadm info -q all -n #{drive} | grep ID_SERIAL_SHORT`.match(regexp)[1] rescue nil
  drives[drive][:pci_addr] = drives[drive][:devpath].match(/\/devices\/pci\d{4}:\d{2}\/([^\/]*)/)[1].sub(/^0000\:/, '') rescue nil
end

drives_by_pci_address = {}

drives.each_key do |drive|
  pci_addr = drives[drive][:pci_addr]
  drives_by_pci_address[pci_addr] = {} if drives_by_pci_address[pci_addr].nil?
  if drives_by_pci_address[pci_addr][:drives].nil?
    drives_by_pci_address[pci_addr][:id] = lspci[pci_addr] || "not found"
    drives_by_pci_address[pci_addr][:drives] = []
  end
  drives_by_pci_address[pci_addr][:drives] << drive
end

puts drives.to_yaml
puts "------------------------------"
puts drives_by_pci_address.to_yaml

