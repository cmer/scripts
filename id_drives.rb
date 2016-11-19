require 'yaml'
lspci = []
drives = {}

`lspci`.each_line do |l|
  m = l.match(/(\S*)\s(.*)/)
  lspci << { m[1] => m[2] }
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
  drives[drive][:pci_addr] = drives[drive][:devpath].match(/\/devices\/pci\d{4}:\d{2}\/([^\/]*)/)[1] rescue nil
end

puts drives.to_yaml
nil
