require 'yaml'
require 'open-uri'
require 'fileutils'
require 'digest'

module TravisJava
  module IBMJava
    def install_ibmjava(version)
      attribute_key = "ibmjava" + version.to_s
      java_home = ::File.join(node['travis_java']['jvm_base_dir'], node['travis_java'][attribute_key]['jvm_name'])
      arch = node['travis_java']['arch']
      if arch == "amd64" then
        arch = "x86_64"
      end
      index_yml = ::File.join("https://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/meta/sdk",
                              node['travis_java']['ibmjava']['platform'], arch, "index.yml")

      # Obtain the uri of the latest IBM Java build for the specified version from index.yml
      entry = find_version_entry(index_yml, version)
      
      installer = File.join(Dir.tmpdir, "ibmjava" + version.to_s + "-installer")
      properties = File.join(Dir.tmpdir, "installer.properties")
        
      # Download and install the IBM Java build
      download_build(entry, installer, properties)
      # Verify checksum
      check_sha(installer, entry['sha256sum'])
      # Install build
      install_build(entry, java_home, properties, installer)        
    end

    # This method downloads and installs the java build
    # @param [Hash] entry - latest entry from the index.yml for the specified ibm java version containing uri
    # @param [String] java_home - directory path where IBM Java will be installed
    # @param [String] version - java version
    # @return - None

    def download_build(entry, installer, properties)  

      # Download the IBM Java installer from source url to the local machine
      remote_file installer do
        src_url = entry['uri']
        source src_url.to_s
        mode '0755'
        checksum entry['sha256sum']
        action :create
        not_if "test -f #{installer}"
        notifies :create, 'file[#{properties}]', :immediately
      end    
    end
      
    def install_build(entry, java_home, properties, installer)
      
      # Create installer properties for silent installation
      file properties do
        content "INSTALLER_UI=silent\nUSER_INSTALL_DIR=#{java_home}\nLICENSE_ACCEPTED=TRUE\n"
        action :nothing
        notifies :run, 'execute[install java]', :immediately
      end
      
      # Install IBM Java build
      execute 'install java' do
        command "#{installer} -i silent -f #{properties}"
        action :nothing
        notifies :delete, 'file[#{properties}]', :immediately
        notifies :delete, 'file[#{installer}]', :immediately
      end
      
      execute "#{java_home}/bin/java -version"

      file properties do
        action :nothing
      end
      
      file installer do
        action :nothing
      end
    end

    # This method returns a hash containing the uri and checksum of the latest release by parsing the index.yml file
    # @param [String] url - url of index.yml file
    # @param [String] version - java version
    # @return [Hash] finalversion - latest entry from the index.yml for the specified IBM Java version containing uri
    #                               and sha256sum
    def find_version_entry(url, version)
      finalversion = nil
      version = '1.'.concat(version.to_s) unless version.to_s.include?('.')
      yaml_content = open(url.to_s, &:read)
      entries = YAML.safe_load(yaml_content)
      entries.each do |entry|
        finalversion = entry[1] if entry[0].to_s.start_with?(version.to_s)
      end
      finalversion
    end
    
    def check_sha(file, checksum)
      sha256 = Digest::SHA256.hexdigest(File.read(file))
      raise 'sha256 checksum does not match' unless sha256 == checksum
    end    
  end
end  
