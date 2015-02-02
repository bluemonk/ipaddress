require 'test_helper'

require 'benchmark'

class IPAddressTest < Test::Unit::TestCase

  def setup
    @valid_ipv4   = "172.16.10.1/24"
    @valid_ipv6   = "2001:db8::8:800:200c:417a/64"
    @valid_mapped = "::13.1.68.3"

    @invalid_ipv4   = "10.0.0.256"
    @invalid_ipv6   = ":1:2:3:4:5:6:7"
    @invalid_mapped = "::1:2.3.4"

    @valid_ipv4_uint32 = [4294967295, # 255.255.255.255
                          167772160,  # 10.0.0.0
                          3232235520, # 192.168.0.0
                          0]

    @invalid_ipv4_uint32 = [4294967296, # 256.0.0.0
                          "A294967295", # Invalid uINT
                          -1]           # Invalid 


    @ipv4class   = IPAddress::IPv4
    @ipv6class   = IPAddress::IPv6
    @mappedclass = IPAddress::IPv6::Mapped
    
    @invalid_ipv4 = ["10.0.0.256",
                     "10.0.0.0.0",
                     "10.0.0",
                     "10.0"]

    @valid_ipv4_range = ["10.0.0.1-254",
                         "10.0.1-254.0",
                         "10.1-254.0.0"]

    @method = Module.method("IPAddress")
  end

  def test_method_IPAddress
    assert_nothing_raised {@method.call(@valid_ipv4)}
    assert_nothing_raised {@method.call(@valid_ipv6)}
    assert_nothing_raised {@method.call(@valid_mapped)}

    assert_instance_of @ipv4class, @method.call(@valid_ipv4)
    assert_instance_of @ipv6class, @method.call(@valid_ipv6)
    assert_instance_of @mappedclass, @method.call(@valid_mapped)

    assert_raise(ArgumentError) {@method.call(@invalid_ipv4)}
    assert_raise(ArgumentError) {@method.call(@invalid_ipv6)}
    assert_raise(ArgumentError) {@method.call(@invalid_mapped)}

    assert_instance_of @ipv4class, @method.call(@valid_ipv4_uint32[0]) 
    assert_instance_of @ipv4class, @method.call(@valid_ipv4_uint32[1]) 
    assert_instance_of @ipv4class, @method.call(@valid_ipv4_uint32[2]) 
    assert_instance_of @ipv4class, @method.call(@valid_ipv4_uint32[3]) 

    assert_raise(ArgumentError) {@method.call(@invalid_ipv4_uint32[0])}
    assert_raise(ArgumentError) {@method.call(@invalid_ipv4_uint32[1])}
    assert_raise(ArgumentError) {@method.call(@invalid_ipv4_uint32[2])}

  end

  def test_module_method_valid?
    assert_equal true, IPAddress::valid?("10.0.0.1")
    assert_equal true, IPAddress::valid?("10.0.0.0")
    assert_equal true, IPAddress::valid?("2002::1")
    assert_equal true, IPAddress::valid?("dead:beef:cafe:babe::f0ad")
    assert_equal false, IPAddress::valid?("10.0.0.256")
    assert_equal false, IPAddress::valid?("10.0.0.0.0")
    assert_equal false, IPAddress::valid?("10.0.0")
    assert_equal false, IPAddress::valid?("10.0")
    assert_equal false, IPAddress::valid?("2002:::1")
    assert_equal false, IPAddress::valid?("2002:516:2:200")

  end

  def test_module_method_valid_ipv4_netmark?
    assert_equal true, IPAddress::valid_ipv4_netmask?("255.255.255.0")
    assert_equal false, IPAddress::valid_ipv4_netmask?("10.0.0.1")
  end

  def test_summarize
    nets = [(1..9),(11..126),(128..168),(170..171),(173..191),(193..223)].map do |range|
      range.to_a.map{|i| "#{i}.0.0.0/8"}
    end.flatten
    nets += (0..255).to_a.select{|i| i!=254}.map{|i| "169.#{i}.0.0/16" }
    nets += (0..255).to_a.select{|i| !(16<=i&&i<31)}.map{|i| "172.#{i}.0.0/16" }
    nets += (0..255).to_a.select{|i| i!=168}.map{|i| "192.#{i}.0.0/16" }

    nets = nets.map{|i| IPAddress::IPv4.new(i) }

    assert_equal [], IPAddress::summarize([]), []
    assert_equal ["10.1.0.0/24"], IPAddress::summarize(["10.1.0.4/24"]).map{|i| i.to_string}
    assert_equal ["2000:1::/32"], IPAddress::summarize(["2000:1::4711/32"]).map{|i| i.to_string}

    assert_equal ["0.0.0.0/0"], IPAddress::summarize(["10.1.0.4/24","7.0.0.0/0", "1.2.3.4/4"]).map{|i| i.to_string}

    networks = ["2000:1::/32", "3000:1::/32", "2000:2::/32", "2000:3::/32", "2000:4::/32", "2000:5::/32", "2000:6::/32", "2000:7::/32", "2000:8::/32"]
    assert_equal ["2000:1::/32", "2000:2::/31", "2000:4::/30", "2000:8::/32", "3000:1::/32"], IPAddress::summarize(networks).map{|i| i.to_string}


    networks = ["10.0.1.1/24", "30.0.1.0/16", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24", "10.0.7.0/24", "10.0.8.0/24"]
    assert_equal ["10.0.1.0/24", "10.0.2.0/23", "10.0.4.0/22", "10.0.8.0/24", "30.0.0.0/16"], IPAddress::summarize(networks).map{|i| i.to_string}

    networks = ["10.0.0.0/23", "10.0.2.0/24"]
    assert_equal ["10.0.0.0/23", "10.0.2.0/24"], IPAddress::summarize(networks).map{|i| i.to_string}
    networks = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/23"]
    assert_equal ["10.0.0.0/22"], IPAddress::summarize(networks).map{|i| i.to_string}


    assert_equal ["10.0.0.0/16"], IPAddress::summarize(["10.0.0.0/16", "10.0.2.0/24"]).map{|i| i.to_string}

    puts ""
    #require 'ruby-prof'
    #result = RubyProf.profile do
      Benchmark.bm do |x|
        x.report do
          25.times do
            assert_equal ["1.0.0.0/8", "2.0.0.0/7", "4.0.0.0/6", "8.0.0.0/7", "11.0.0.0/8", "12.0.0.0/6",
             "16.0.0.0/4", "32.0.0.0/3", "64.0.0.0/3", "96.0.0.0/4", "112.0.0.0/5", "120.0.0.0/6",
             "124.0.0.0/7", "126.0.0.0/8", "128.0.0.0/3", "160.0.0.0/5", "168.0.0.0/8", "169.0.0.0/9",
             "169.128.0.0/10", "169.192.0.0/11", "169.224.0.0/12", "169.240.0.0/13", "169.248.0.0/14",
             "169.252.0.0/15", "169.255.0.0/16", "170.0.0.0/7", "172.0.0.0/12", "172.31.0.0/16",
             "172.32.0.0/11", "172.64.0.0/10", "172.128.0.0/9", "173.0.0.0/8", "174.0.0.0/7", "176.0.0.0/4",
             "192.0.0.0/9", "192.128.0.0/11", "192.160.0.0/13", "192.169.0.0/16", "192.170.0.0/15",
             "192.172.0.0/14", "192.176.0.0/12", "192.192.0.0/10", "193.0.0.0/8", "194.0.0.0/7",
             "196.0.0.0/6", "200.0.0.0/5", "208.0.0.0/4"], IPAddress::summarize(nets).map{|i| i.to_string}
          end
        end
      end
    #end
    #printer = RubyProf::GraphPrinter.new(result)
    #printer.print(STDOUT, {})
    # test imutable input parameters
    a1 = IPAddress.parse("10.0.0.1/24")
    a2 = IPAddress.parse("10.0.1.1/24")
    assert_equal ["10.0.0.0/23"], IPAddress::summarize([a1,a2]).map{|i| i.to_string}
    assert_equal "10.0.0.1/24", a1.to_string
    assert_equal "10.0.1.1/24", a2.to_string
  end

end


