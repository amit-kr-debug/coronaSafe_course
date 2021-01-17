def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

def parse_dns(dns_raw)
  # flitering out the comment lines and blank lines
  dns_filtered = dns_raw.filter { |line| line.length > 1 and line[0] != "#" }

  dns_dict = {}
  dns_data = []

  # storing data of lines in a array by splitting
  dns_filtered.map do |line|
    dns_data.push(line.split(",").map { |word| word.strip() })
  end

  # storing the data in a map with key as domanin name and values is an array
  # that contains record type at its 0th index and destination address at 1st index
  dns_data.map { |line| dns_dict[line[1]] = [line[0], line[2]] }

  return dns_dict
end

def resolve(dns_records, lookup_chain, domain)
  # checking if the domain exists in the map or not
  if dns_records[domain] != nil
    rec_type = dns_records[domain][0]
    dest = dns_records[domain][1]

    lookup_chain.push(dest)

    # termination condition of the recursion is if we find rec_type to be A
    if rec_type == "A"
      return lookup_chain

      # else we need to recursively keep checking untill we reach to an IP_address
    elsif rec_type == "CNAME"
      return resolve(dns_records, lookup_chain, dest)
    end
  else
    lookup_chain = []
    lookup_chain.push("Error: record not found for #{domain}" )
    return lookup_chain
  end
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

dns_raw = File.readlines("zone")

dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
