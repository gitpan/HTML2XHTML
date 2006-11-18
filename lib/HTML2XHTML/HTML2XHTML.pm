package HTML2XHTML;

use strict;
use warnings;

our $VERSION = '0.03.03';

sub new 
{
	my ($self, %OPTS) = @_; 

	$self = {};
    bless ($self);

    #check to make sure required fields hav input
	if (exists($OPTS{file}) || exists($OPTS{file_name})) { die('An HTML and/or CSS file(s) was not specified, you must include at least 1') 
	if (($OPTS{'file'} && $OPTS{'file'} eq '') || ($OPTS{'file_name'} && $OPTS{'file_name'} eq '')); }	
	if (exists($OPTS{dir})) { die('A directory was not specified, you must include at least 1!') if ($OPTS{'dir'} eq ''); }
	
	if (exists($OPTS{dir}) && (exists($OPTS{file}) || exists($OPTS{file_name}))) { die('You cannot specify both a directory
	and file, you must choose one or the other!'); }
	
	if (!exists($OPTS{dir}) && !exists($OPTS{file}) && !exists($OPTS{file_name})) { print $OPTS{file_name}; die('You must specify either a directory name or file.'); }	
		
	my @file = $OPTS{file} || $OPTS{file_name} if ($OPTS{file_name} || $OPTS{file});		
	my @directory = 'dir '.$OPTS{dir} if ($OPTS{dir});		

    eval { system("perl convert_xhtml2.pl @file @directory"); }; 
    
    if ($@) { die 'There was a problem converting from HTML to XHTML.' }
    
    return $self;
}

1;

__END__