package HTML2XHTML;

use strict;
use warnings;

our $VERSION = '0.03.08b';

sub new 
{
	my ($self, %OPTS) = @_; 

	$self = {};
    bless ($self);

    #check to make sure required fields have input
    if (exists($OPTS{encoding})) { die('You must enter an encoding!!') if ($OPTS{'encoding'} && $OPTS{'encoding'} eq ''); }	
	die('You must specify an encoding!') if (!exists($OPTS{encoding})); 	
	
	if (exists($OPTS{file}) || exists($OPTS{file_name})) { die('An HTML and/or CSS file(s) was not specified, you must include at least 1 file!') 
	if (($OPTS{'file'} && $OPTS{'file'} eq '') || ($OPTS{'file_name'} && $OPTS{'file_name'} eq '')); }	
		
	if (exists($OPTS{dir})) { die('A directory was not specified, you must include at least 1!') if ($OPTS{'dir'} eq ''); }		
	
	if (exists($OPTS{dir}) && (exists($OPTS{file}) || exists($OPTS{file_name}))) { die('You cannot specify both a directory
	and file, you must choose one or the other!'); }
			
	if (!exists($OPTS{dir}) && !exists($OPTS{file}) && !exists($OPTS{file_name})) { die('You must specify either a directory or file.'); }	
	
	my $encoding = $OPTS{encoding}; 		
	my @file = $OPTS{file} || $OPTS{file_name} if ($OPTS{file_name} || $OPTS{file});		
	my @directory = 'dir '.$OPTS{dir} if ($OPTS{dir});		

    eval { system("perl lib/HTML2XHTML/convert_xhtml2.pl $encoding @file @directory"); }; 
    
    if (!$@) { warn 'There was a problem with the path to the Perl script, trying another location.'; system("perl convert_xhtml2.pl $encoding @file @directory");  }
    
    return $self;
}

1;

__END__