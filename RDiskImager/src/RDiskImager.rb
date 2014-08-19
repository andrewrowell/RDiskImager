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
     testCompatibility()
     getChoice()
  end
  
  # make sure pv is available to use
  def testCompatibility()
     if (`pv --help`.split("\n")[0] != "Usage: pv [OPTION] [FILE]...")
       puts "You need to install pv"
       exit
     end
  end
  
  # find out if user wants to write a device
  #   to an image or an image to a device
  def getChoice()
    puts "Device to Image [1]\nImage to Device [2]\n"
    choice = gets().chomp
    if choice == "1"
      deviceToImage()
    end
    if choice == "2"
      imageToDevice()
    end
  end
  
  # Write a device to an image
  def deviceToImage()
    puts "Device name? (sda, hdb, sdc, etc...)"
    device_name = gets.chomp
    
    # read the device's size from /proc/partitions
    devtable = `cat /proc/partitions | grep "#{device_name}"`
    # split("\n")[0] to get the first line (information
    #   for the entire device) and then split(" ")[2] to
    #   get the right number from that line
    size = devtable.split("\n")[0].split(" ")[2]
    
    puts "Image name?"
    image_name = gets.chomp
    system "dd if=\"/dev/#{device_name}\"| pv -s #{size}k | dd of=\"#{image_name}\""
  end
  
  # Write an image to a device
  def imageToDevice()
    puts "Image name?"
    image_name = gets.chomp
    size = File.size(image_name)/1024
    puts size
    puts "Device name? (sda, hdb, sdc, etc...)"
    device_name = gets.chomp
    system "dd if=\"#{image_name}\"| pv -s #{size}k | dd of=\"/dev/#{device_name}\""
  end
  
end

def main()
  RDiskImager.new()
end

main