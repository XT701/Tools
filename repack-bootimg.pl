#!/usr/bin/perl -W

use strict;
use Cwd;

my $dir = getcwd;

my $usage = "repack-bootimg.pl <compress mode: gzip/xz/lzma> <kernel> <ramdisk-directory> <outfile>\n";

die $usage unless $ARGV[0] && $ARGV[1] && $ARGV[2] && $ARGV[3];

chdir $ARGV[2] or die "$ARGV[2] $!";

system ("find . | cpio -o -H newc | $ARGV[0] > $dir/ramdisk-repack.cpio.gz");

chdir $dir or die "$ARGV[2] $!";;

system ("./mkbootimg --kernel $ARGV[1] --ramdisk ramdisk-repack.cpio.gz -o $ARGV[3]");

unlink("ramdisk-repack.cpio.gz") or die $!;

print "\nrepacked boot image written at $ARGV[2]-repack.img\n";
