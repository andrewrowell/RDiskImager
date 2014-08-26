RDiskImager

Summary:
	RDiskImager is a command line utility for creating
	images of disk from the /dev directory on linux
	computers.
	
	It uses the dd command to make the
	image of the disk, and uses the pv command to show
	the user how the image creation or image write is
	progressing.
	
	This means that the user does not have to manually
	set up the dd and pv commands when they want to 
	make a disk image or write an image to a disk, and
	RDiskImager also confirms the names of the disk and
	image before performing the operation, preventing
	accidental operations due to typos.
	
	
Command Line Arguments:
	--simulate
		Runs RDiskImager in simulation mode. Instead of
		actually performing the disk image creation or
		writing an image to a disk, RDiskImager will
		tell the user what commands would have been used
		to perform the operation.
		
License:
	RDiskImager is licensed under GPLv2, a copy of which
	is included with RDiskImager