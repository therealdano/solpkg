#!/usr/local/bin/perl
#
# solpkg
#

=pod

=head1 NAME

solpkg.pl - generate tree of installed files

=head1 SYNOPSIS

solpkg.pl make install

=head1 DESCRIPTION

Generate tree of installed files. This script is a wrapper around the install command and uses the installwatch package to intercept low level commands to record all the file installation fuctions actually executed. Then it creates a temporary archive of the files, extracting them to a temporary directory named for the directory from which the install command is run. The files will still be installed in the original target directories, it's just that you will have a copy of all the files so that you could package them separately.

Before using, check your Makefile. If you have one that prefixes all the installation with something like
$(DESTDIR), then you don't need to use solpkg.pl, you can just define DESTDIR when running make, e.g.

  $ make DESTDIR=/tmp/solpkg install

=head1 ARGUMENTS

=over 4

=item B<installargs>

installargs is the command used to do the actual install. For example I<make install>. The install command is actually run.

=back

=head1 AUTHOR

Dano Carroll <dano@xernolan.org>

=cut

use Cwd;
use Archive::Tar;
$pkgdir = cwd;
@path = split('/',$pkgdir);
$pkgdir = "/tmp/" . pop(@path);
mkdir($pkgdir,0775);
# do an install and get the installwatch output
$iwtmpfile = "/tmp/iw${$}";
$command[0] = "/usr/local/bin/installwatch";
$command[1] = "-o";
$command[2] = $iwtmpfile;
push(@command,@ARGV);
$result = system(@command);
$result = $result >> 8;
if ( $result == 0 ) {
    # get the regular files
    filesFromIw(*newfiles,$iwtmpfile);
    # unlink $iwtmpfile;
    # copy the regular files to a separate directory
    copyFiles(*newfiles,$pkgdir);
}
else {
    printf STDERR "installwatch failed: %d\n",$result;
}
exit(0);

sub filesFromIw {
    local(*newfiles,$list) = @_;
    open(LIST,$list);
    while ( ! eof(LIST) ) {
	$line = <LIST>;
	chomp($line);
	($result,$command,$file,$restofline) = split(/[ \t]+/,$line,4);
	# get link files
	if ( ($command eq "symlink") || ($command eq "rename") ) {
	    ($file,$restofline) = split(/[ \t]+/,$restofline,2);
	}
	# ignore the /dev files
	if ( $file !~ /^\/dev/ ) {
	  # does it exist
	  if ( -f "${file}" ) {
	    # strip the leading /
	    $file = substr($file,1);
	    # not in the list already
	    if ( ( $found=grep(/$file$/,@newfiles) ) == 0 ) {
	      push(@newfiles,($file));
	    }
	  }
	}
    }
    close(LIST);
}

sub copyFiles {
    local(*newfiles,$destination) = @_;
    local($curdir) = getcwd;
    local($tmptar) = "/tmp/sol${$}.tar";
    chdir "/";
    # make tar in memory
    local($tar) = Archive::Tar->new();
    $tar->add_files(@newfiles);
    # extract tar
    $tar->write($tmptar);
    chdir $destination;
    $tar = Archive::Tar->new($tmptar);
    $tar->extract(@newfiles);
    unlink $tmptar;
    chdir $curdir;
}
