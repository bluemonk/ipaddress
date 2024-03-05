# Changelog

## unreleased

### Added
- Add `bin/*` scripts for better development tasks

### Changed
- **Breaking** Change `Ipaddress::VERSION` to `IPAddress::VERSION` to match the gem main module
- Use `Gemfile` for development dependencies and add `Gemfile.lock` under control version
- Cleanup and improvement of the gemspec
- Cleanup of `Rakefile`
- Changes in `README.md` and `CONTRIBUTING.md` files to reflect the new development process

## 0.8.3 - 2016-02-17

### Added
- Added #[]= method to IPv4/6 classes to add octet writing support (#24)
- IPV4#multicast?
- IPV4#loopback?
- IPV4#to()

### Changed
- Merged bundler branch to cleanup gemspec and Rakefiles

### Fixed
- IPAddress::IPv4.split handling (#40)


## 0.8.1 - 2011-05-17

### Changed
- ipaddress now uses minitest for testing, all tests passing


## 0.8.0 - 2011-05-17

### Added
- IPv6#network
- Prefix128#host_prefix
- IPv6#broadcast_u128
- IPv6#each
- IPv6#<=>
- IPv4#split
- IP#ntoa

### Changed
- ipaddress now uses a regexp to validate IPv6 addresses.
  Thanks to Christoph Petschnig for his regexp and to Bronislav Robenek for fixing this.
- Removed extension methods and extension directory to facilitate integration with the stdlib
- Reworked IPv4#<=>, now intuitively sorts objects based on the prefix
- IPv4#supernet now returns "0.0.0.0/0" if supernetting with a prefix less than 1
- IPv4#subnet now accept a new prefix instead of number of subnets (as per RFC3531)

## 0.7.5 - 2011-04-08

### Added
- IPAddress::IPv4#include_all?
- #ipv4? and #ipv6?

### Changed
- IPAddress::IPv4#each_host to improve speed

### Fixed
- IPAddress::IPv4::summarize bug


## 0.7.0 - 2010-09-08

### Added
- IPAddress::IPv6#include?
- IPAddress::IPv6#network_u128
- Modified IPAddress::IPv6::Mapped to accept IPv4 mapped addresses in IPv6 format
- IPAddress::IPv4#private?
- IPAddress::IPv4::parse_classful


## 0.6.0 - 2010-07-19

### Added
- IPv4#to_string and IPv6#to_string: print the address with the prefix
    portion, like the #to_s method in ipaddress 0.5.0.
- IPAddress::parse, for those who don't like the wrapper  method IPAddress()
- IPv6#to_string_uncompressed, returns a string with the uncompressed IPv6 and the prefix
- IPv6::Mapped#to_string, returns the IPv6 Mapped address with IPv4 notation and the prefix
- IPv6#reverse, returns the ip6.arpa DNS reverse lookup string
- IPv4#arpa and IPv6#arpa, alias of the respective #reverse methods
- Prefix#+, Prefix#-

### Changed
- IPv4#to_s now returns the address portion only, to retain compatibility with IPAddr.
- IPv6#to_s now returns the address portion only, to retain compatibility with IPAddr.
- IPv6::Unspecified#to_s, IPv6::Loopback and  IPv6::Mapped#to_s now return the address portion only,
  to retain compatibility with IPAddr.
- IPv4::summarize now returns an array even if the result is a single subnet,
  to keep consistency and avoid confusion
- Moved all the IPAddress module methods from  lib/ipaddress/ipbase.rb to lib/ipaddress.rb
- Removed IPBase superclass
- IPv4 and IPv6 classes no longer inherit from IPBase
- Removed lib/ipaddress/ipbase.rb
- Removed test/ipaddress/ipbase_test.rb
- Normalized README rdoc headers
- Added documentation for IPAddress::Prefix
- Added documentation for IPAddress::IPv4 and IPAddress::IPv6
- Fixed formatting
- Fixed lots of typos

### Fixed
- Replaced Ruby 1.9 deprecated Hash#index with Hash#key
- Removed require ruby-prof from tests which was causing users
  to install ruby-prof or manually remove the line
- Removed "must" method from tests, replaced by normal Test::Unit methods
- Removed duplicate Jeweler entry in Rakefile
- Made Integer#closest_power_of_2 more general by adding an optional limit parameter
- Fixed summarization algorithm (thanks to nicolas fevrier)
- Fixed bug in prefix_from_ip (thanks to jdpace)
