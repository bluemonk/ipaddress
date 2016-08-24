
// use num::bigint::BigUint;
// use ip_bits::IpBits;
use ipaddress::IPAddress;
use core::result::Result;
use num::bigint::BigUint;
use core::str::FromStr;
use num_traits::One;
use num_traits::Num;
use prefix128;
// use core::fmt::Display;
//use core::fmt::Display::fmt;
// use core::fmt::Debug;
// use ::prefix::Prefix;
//use core::fmt::Display::fmt;
//  =Name
//
//  IPAddress::IPv6 - IP version 6 address manipulation library
//
//  =Synopsis
//
//     require 'ipaddress'
//
//  =Description
//
//  Class IPAddress::IPv6 is used to handle IPv6 type addresses.
//
//  == IPv6 addresses
//
//  IPv6 addresses are 128 bits long, in contrast with IPv4 addresses
//  which are only 32 bits long. An IPv6 address is generally written as
//  eight groups of four hexadecimal digits, each group representing 16
//  bits or two octect. For example, the following is a valid IPv6
//  address:
//
//    2001:0db8:0000:0000:0008:0800:200c:417a
//
//  Letters in an IPv6 address are usually written downcase, as per
//  RFC. You can create a new IPv6 object using uppercase letters, but
//  they will be converted.
//
//  === Compression
//
//  Since IPv6 addresses are very long to write, there are some
//  semplifications and compressions that you can use to shorten them.
//
//  * Leading zeroes: all the leading zeroes within a group can be
//    omitted: "0008" would become "8"
//
//  * A string of consecutive zeroes can be replaced by the string
//    "::". This can be only applied once.
//
//  Using compression, the IPv6 address written above can be shorten into
//  the following, equivalent, address
//
//    2001:db8::8:800:200c:417a
//
//  This short version is often used in human representation.
//
//  === Network Mask
//
//  As we used to do with IPv4 addresses, an IPv6 address can be written
//  using the prefix notation to specify the subnet mask:
//
//    2001:db8::8:800:200c:417a/64
//
//  The /64 part means that the first 64 bits of the address are
//  representing the network portion, and the last 64 bits are the host
//  portion.
//
//

pub fn from_str<S: Into<String>>(_str: S, radix: u32, prefix: usize) -> Result<IPAddress, String> {
    let str = _str.into();
    let num = BigUint::from_str_radix(&str.clone(), radix);
    if num.is_err() {
        return Err(format!("unparsable {}", str));
    }
    return from_int(num.unwrap(), prefix);
}

pub fn from_int(adr: BigUint, prefix: usize) -> Result<IPAddress, String> {
    let prefix = prefix128::new(prefix);
    if prefix.is_err() {
        return Err(prefix.unwrap_err());
    }
    return Ok(IPAddress {
        ip_bits: ::ip_bits::v6(),
        host_address: adr.clone(),
        prefix: prefix.unwrap(),
        mapped: None,
        vt_is_private: ipv6_is_private,
        vt_is_loopback: ipv6_is_loopback,
        vt_to_ipv6: to_ipv6,
    });
}


//  Creates a new IPv6 address object.
//
//  An IPv6 address can be expressed in any of the following forms:
//
//  * "2001:0db8:0000:0000:0008:0800:200C:417A": IPv6 address with no compression
//  * "2001:db8:0:0:8:800:200C:417A": IPv6 address with leading zeros compression
//  * "2001:db8::8:800:200C:417A": IPv6 address with full compression
//
//  In all these 3 cases, a new IPv6 address object will be created, using the default
//  subnet mask /128
//
//  You can also specify the subnet mask as with IPv4 addresses:
//
//    ip6 = IPAddress "2001:db8::8:800:200c:417a/64"
//
pub fn new<S: Into<String>>(_str: S) -> Result<IPAddress, String> {
    let str = _str.into();
    let (ip, o_netmask) = IPAddress::split_at_slash(&str);
    if IPAddress::is_valid_ipv6(ip.clone()) {
        let o_num = IPAddress::split_to_num(&ip);
        if o_num.is_err() {
            return Err(o_num.unwrap_err());
        }
        let mut netmask = 128;
        if o_netmask.is_some() {
            let network = o_netmask.unwrap();
            let num_mask = u8::from_str(&network);
            if num_mask.is_err() {
                return Err(format!("Invalid Netmask {}", str));
            }
            netmask = network.parse::<usize>().unwrap();
        }
        let prefix = ::prefix128::new(netmask);
        if prefix.is_err() {
            return Err(prefix.unwrap_err());
        }
        return Ok(IPAddress {
            ip_bits: ::ip_bits::v6(),
            host_address: o_num.unwrap(),
            prefix: prefix.unwrap(),
            mapped: None,
            vt_is_private: ipv6_is_private,
            vt_is_loopback: ipv6_is_loopback,
            vt_to_ipv6: to_ipv6
        });
    } else {
        return Err(format!("Invalid IP {}", str));
    }
} //  pub fn initialize

pub fn to_ipv6(ia: &IPAddress) -> IPAddress {
    return ia.clone();
}

pub fn ipv6_is_loopback(my: &IPAddress) -> bool {
    return my.host_address == BigUint::one();
}


pub fn ipv6_is_private(my: &IPAddress) -> bool {
    return IPAddress::parse("fd00::/8").unwrap().includes(my);
}

// //
// //  Returns the IPv6 address in uncompressed form:
// //
// //    ip6 = IPAddress "2001:db8::8:800:200c:417a/64"
// //
// //    ip6.address
// //      // => "2001:0db8:0000:0000:0008:0800:200c:417a"
// //
// pub fn address(&self)
//   @address
// end

// //
// //  Returns an array with the 16 bits groups in decimal
// //  format:
// //
// //    ip6 = IPAddress "2001:db8::8:800:200c:417a/64"
// //
// //    ip6.groups
// //      // => [8193, 3512, 0, 0, 8, 2048, 8204, 16762]
// //
// pub fn groups
//   @groups
// end

// //
// //  Returns an instance of the prefix object
// //
// //    ip6 = IPAddress "2001:db8::8:800:200c:417a/64"
// //
// //    ip6.prefix
// //      // => 64
// //
// pub fn prefix
//   @prefix
// end




//  Set a new prefix number for the object
//
//  This is useful if you want to change the prefix
//  to an object created with IPv6::parse_u128 or
//  if the object was created using the default prefix
//  of 128 bits.
//
//    ip6 = IPAddress("2001:db8::8:800:200c:417a")
//
//    puts ip6.to_string
//      // => "2001:db8::8:800:200c:417a/128"
//
//    ip6.prefix = 64
//    puts ip6.to_string
//      // => "2001:db8::8:800:200c:417a/64"
//
// pub fn set_prefix(&self, num: u8) {
//   self.prefix = ::prefix128::new(num)
// }

// pub fn to_ip_str(addr: &BigUint) -> String {
//     // let mut ret = String::new();
//     // let part_mod = 1<<16;
//     // for (i = 128-16; i >= 0; i -= 16) {
//     //     ret.push_str((addr>>i).mod_floor(&part_mod).to_u16(
//     // }
//     // return ret.reserve().join()
//     return String::new();
// }

//  Unlike its counterpart IPv6// to_string method, IPv6// to_string_uncompressed
//  returns the whole IPv6 address and prefix in an uncompressed form
//
//    ip6 = IPAddress "2001:db8::8:800:200c:417a/64"
//
//    ip6.to_string_uncompressed
//      // => "2001:0db8:0000:0000:0008:0800:200c:417a/64"
//
// pub fn to_string_uncompressed(addr: &BigUint) -> String {
//     // return format!("{}/{}", self.address, self.prefix)
//     return String::new();
// }