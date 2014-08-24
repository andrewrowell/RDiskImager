#!/usr/bin/env ruby

# RDiskImager.rb
#
# Requires: Linux, ruby, dd, pv
#
# A nice, neat, command line interface that combines the dd and pv
# commands so that pv automatically knows the size of the device
# being imaged, and dd automatically runs through pv so the user
# can see the progress of the backup
#
# For now, this script has to be run as root to work

class RDiskImager
  def initialize()
    testArgs()
    testCompatibility()
    while true
      getChoice()
    end
  end
  
  # See what command line arguments the user has set
  def testArgs()
    ARGV.each do |arg|
      if (arg == "--simulate" or arg == "-s")
        @simulate = true
        puts "Running in simulation mode!"
      else
        @simulate = false
      end
    end
  end
  
  # make sure programs and files RDiskImager needs are present
  #    and that the script is being run by the root user
  def testCompatibility()
    # check that pv is installed
    if (`pv --help`.split("\n")[0] != "Usage: pv [OPTION] [FILE]...")
      puts "You need to install pv to use RDiskImager"
      exit
    end
    # check that dd is installed
    if(`dd --help`.split("\n")[0] != "Usage: dd [OPERAND]...")
      puts "You need to install dd to use RDiskImager"
      exit
    end
    # see if the /proc/partitions file exists
    if(File.exist?("/proc/partitions") == false)
      puts "/proc/partitions not found!"
      exit
    end
    # check for root priveleges
    if(`id -u`.split("\n")[0] != "0")
      puts "Script must be run as root!"
      exit
    end
  end
  
  # find out if user wants to write a device
  #   to an image or an image to a device
  def getChoice()
    puts "Device to Image [1]\nImage to Device [2]\nExit            [3]\n"
    choice = $stdin.gets.chomp
    if choice == "1"
      deviceToImageDialog()
    elsif choice == "2"
      imageToDeviceDialog()
    elsif choice == "3"
      puts "Exiting RDiskImager!"
      exit
    else
      puts "Uknown command!"
    end
  end
  
  # Prompts user for the device and image names
  def deviceToImageDialog()
    puts "Device name? (sda, hdb, sdc, etc...)"
    device_name = $stdin.gets.chomp
        
    # read the device's size from /proc/partitions
    devtable = `cat /proc/partitions | grep "#{device_name}"`
    # split("\n")[0] to get the first line (information
    #   for the entire device) and then split(" ")[2] to
    #   get the right number from that line
    size = devtable.split("\n")[0].split(" ")[2]
        
    puts "Image name?"
    image_name = $stdin.gets.chomp
    puts "Are you sure you want to save an image of #{device_name} to #{image_name}? y/[n]"
    if $stdin.gets.chomp == "y"
      deviceToImage(device_name, size, image_name)
    else
      puts "Cancelling operation!"
    end
  end
  
  # Prompts user for image and device names
  def imageToDeviceDialog()
    puts "Image name?"
    image_name = $stdin.gets.chomp
    size = File.size(image_name)/1024
    puts size
    puts "Device name? (sda, hdb, sdc, etc...)"
    device_name = $stdin.gets.chomp
    puts "Are you sure you want to write #{image_name} to #{device_name}? y/[n]"
    if $stdin.gets.chomp == "y"
      imageToDevice(image_name, size, device_name)
    else
      puts "Cancelling operation!"
    end
  end
  
  # Write a device to an image
  def deviceToImage(device_name, size, image_name)
    if @simulate
      puts "This would run:"
      puts "dd if=\"/dev/#{device_name}\"| pv -s #{size}k | dd of=\"#{image_name}\""
    else
      system "dd if=\"/dev/#{device_name}\"| pv -s #{size}k | dd of=\"#{image_name}\""
    end
  end
  
  # Write an image to a device
  def imageToDevice(image_name, size, device_name)
    if @simulate
      puts "This would run:"
      puts "dd if=\"#{image_name}\"| pv -s #{size}k | dd of=\"/dev/#{device_name}\""
    else
      system "dd if=\"#{image_name}\"| pv -s #{size}k | dd of=\"/dev/#{device_name}\""
    end
  end
  
end

def main()
  RDiskImager.new()
end

main
