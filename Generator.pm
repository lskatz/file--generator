#!/usr/bin/env perl

# Generator.pm: 
# Author: Lee Katz <lkatz@cdc.gov>

package File::Generator;
require 5.12.0;
our $VERSION=0.1;

use strict;
use warnings;

use File::Basename qw/basename fileparse dirname/;
use File::Temp qw/tempdir tempfile/;
use Data::Dumper qw/Dumper/;

use Exporter qw/import/;
our @EXPORT_OK = qw(
           );

# TODO if 'die' is imported by a script, redefine
# sig die in that script as this function.
local $SIG{'__DIE__'} = sub { my $e = $_[0]; $e =~ s/(at [^\s]+? line \d+\.$)/\nStopped $1/; die("$0: ".(caller(1))[3].": ".$e); };

=pod

=head1 NAME

File::Generator

=head1 SYNOPSIS

A module for exporting test files

  use strict;
  use warnings;
  use File::Generator
  
  my $generator = File::Generator->new({seed=>12345});
  my $fastqFile = $generator->generate("fastq");
  my $fastqFile2= $generator->generate("fastq");
  my $largeFastq= $generator->generate("fastq",{maxbytes=>10000});

=head1 DESCRIPTION

Generate random test files.

=pod

=head1 METHODS

=over

=item File::Generator->new(\%options)

Create a new instance of the file generator with the following options

  Applicable arguments:
  Argument     Default    Description
  seed         0          A seed for a random number generator

=back

=cut

sub new{
  my($class,$settings)=@_;

  # Set optional parameter defaults
  $$settings{seed}        ||=0;
  $$settings{tempdir}     ||=tempdir("Generator.pm.XXXXXX",TMPDIR=>1,CLEANUP=>1);

  # Initialize the object and then bless it
  my $self={
    seed         => $$settings{seed},
    tempdir      => $$settings{tempdir},
    _fileCounter => 0, # how many files this generator has made
  };

  bless($self);

  srand($self->{seed});

  return $self;
}


=pod

=over

=item $generator->generate($fileType)

Generate a type of file

  Arguments: $fileType (string) - a type of file to generate
                Available types: "fastq"
  Returns:   Path to a file (string)

=back

=cut

sub generate{
  my($self,$type,$settings)=@_;

  $type=uc($type);

  if($type eq "FASTQ"){
    return $self->generateFastq($settings);
  } else {
    die "ERROR: I do not understand type $type";
  }
}

sub generateFastq{
  my($self,$settings)=@_;
  $$settings{maxbytes}    ||= 1000;

  my @NT=qw(A C G T);

  $self->{_fileCounter}++;
  
  my $filename = $self->{tempdir}."/file.".$self->{_fileCounter}.".fastq";
  open(my $fh, ">", $filename) or die "ERROR: could not write to $filename: $!";
  my $readCounter=0;
  my $numBytes=0;
  while($numBytes < $$settings{maxbytes}){
    $readCounter++;
    my $entry="\@$readCounter\n";
    for(my $i=0;$i<150;$i++){
      $entry.=$NT[rand(4)];
    }
    $entry.="\n+\n";
    $entry.="I" x 150;
    $entry.="\n";

    $numBytes.=length($entry);
    if($numBytes < $$settings{maxbytes}){
      print $fh $entry;
    }
  }
  close $fh;

  return $filename;
}

=head1 COPYRIGHT AND LICENSE

MIT license.  Go nuts.

=head1 AUTHOR

Author: Lee Katz <lkatz@cdc.gov>

For additional help, go to https://github.com/lskatz/File--Generator

=cut

1;
