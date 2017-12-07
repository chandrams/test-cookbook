require 'json'
require 'open-uri'
require 'fileutils'
require 'digest'
require 'net/https'
require 'net/http'


module TravisJava
  module OpenJDKOpenJ9 
    def install_openjdk_openj9(version)
      attribute_key = "openjdk" + version.to_s + "-openj9";  
      p "attribute key = #{attribute_key}"
      java_home = ::File.join(node['travis_java']['jvm_base_dir'], node['travis_java'][attribute_key]['jvm_name'])
      pinned_release = node['travis_java'][attribute_key]['pinned_release']
      arch = node['travis_java']['arch']
      arch = "x64_Linux" if arch == "amd64"
      arch = "ppc64le_Linux" if arch == "ppc64el"
      url = ::File.join("https://api.adoptopenjdk.net", attribute_key, "releases", arch, "latest")


      # Obtain the uri of the latest IBM Java build for the specified version from index.yml
	puts "********** pinned release #{pinned_release}"
      if pinned_release
        url = ::File.join("https://api.adoptopenjdk.net", attribute_key, "releases", arch)
        entry = find_version_entry(url, pinned_release)
      else
        entry = find_version_entry(url, version)
      end

      # Download and install the IBM Java build
      install_build(entry, java_home, version)

      # Delete IBM Java installable and installer properties file
      delete_files(version)

      link_cacerts(java_home, version)
    end

    # This method downloads and installs the java build
    # @param [Hash] entry - latest entry from the index.yml for the specified ibm java version containing uri
    # @param [String] java_home - directory path where IBM Java will be installed
    # @param [String] version - java version
    # @return - None

    def install_build(entry, java_home, version)
      binary = File.join(Dir.tmpdir, "openjdk" + version.to_s + "_openj9" + ".tgz")
      expected_checksum = entry['sha256sum']
      puts "*** expected_checksum = #{expected_checksum}"
      puts "*** entry uri = #{entry['uri']}"
      # Download the Openjdk build from source url to the local machine
      remote_file binary do
        src_url = entry['uri']
	src_url="https://github.com/AdoptOpenJDK/openjdk8-openj9-releases/releases/download/jdk8u152-b16/OpenJDK8-OPENJ9_x64_Linux_jdk8u152-b16.tar.gz"
        source src_url.to_s
        mode '0755'
        checksum entry['sha256sum']
        action :create
        notifies :run, "ruby_block[Verify Checksum of #{binary} file]", :immediately
      end

      # Verify Checksum of the downloaded IBM Java build
      ruby_block "Verify Checksum of #{binary} file" do
        block do
          checksum = Digest::SHA256.hexdigest(File.read(binary))
          if checksum != expected_checksum
            raise "Checksum of the downloaded IBM Java build #{checksum} does not match the expected checksum #{expected_checksum}"
          end
        end
        action :nothing
      end

      execute "Extract OpenJDK#{version} build" do
        command "rm -rf #{java_home}"
        action :run
      end

      # Extract the OpenJDK build
      execute "Extract OpenJDK#{version} build" do
        command "tar -zxf #{binary}"
        action :run
      end

      execute "Extract OpenJDK#{version} build" do
        command "mv ./#{entry['release']} #{java_home}"
        action :run
      end

    end

    def link_cacerts(java_home, version)
      link "#{java_home}/jre/lib/security/cacerts" do
        to '/etc/ssl/certs/java/cacerts'
        not_if { version > 8 }
      end

      link "#{java_home}/lib/security/cacerts" do
        to '/etc/ssl/certs/java/cacerts'
        not_if { version <= 8 }
      end
    end

    # This method deletes the IBM Java installable and installer properties files
    # @param [String] version - java version
    # @return - None

    def delete_files(version)
      binary = File.join(Dir.tmpdir, "openjdk" + version.to_s + "_openj9" + ".tgz")

      file binary do
        action :delete
      end
    end

    def find_version_entry(url, version)
      entry = Hash.new
      puts "URL = #{url} version = #{version}"
      json = open(url.to_s, &:read)

      puts "JSON = #{json}"  
      parsed = JSON.parse(json)

      if version.to_s == "8"
	puts "version = 8"
	release = parsed["release_name"]
	entry["release"]=release
      else
	puts "version != 8"
	release=version
	entry["release"]=version
      end
   
      if parsed["binaries"] 
	puts "&&&&&&&& inside parsed"
        parsed["binaries"].each do |binary| 
		puts "&&&&&&&& parsed #{parsed["release_name"]} #{release}"
          if parsed["release_name"].to_s == release.to_s
            entry["uri"]=binary["binary_link"]
            checksumfile = binary["checksum_link"]
            content = open(checksumfile.to_s, &:read)
            array = content.split(" ")
            entry["sha256sum"]=array[0]
          end
        end
      end
      puts "****** returning #{entry['sha256sum']}"
      puts "****** returning #{entry['release']}"
      puts "****** returning #{entry['uri']}"
      return entry
    end
  end
end


