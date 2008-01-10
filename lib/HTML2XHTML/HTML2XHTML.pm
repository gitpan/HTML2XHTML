package HTML2XHTML;

use strict;
use warnings;

our $VERSION = '0.04b';

sub new 
{
	my ($class, %OPTS) = @_;
		
    my $self = (bless {}, $class);
    
    #check to make sure required fields have input
    if (exists($OPTS{encoding})) { die('You must enter an encoding (i.e., UTF-8, UTF-16, ISO-ISO-8859-1)!') if ($OPTS{'encoding'} && $OPTS{'encoding'} eq ''); }	
	die('You must specify an encoding  (i.e., UTF-8, UTF-16, ISO-ISO-8859-1)!') if ( !exists($OPTS{encoding}) ); 	
	
	if (exists($OPTS{doctype})) { die('You must enter a doctype, either "Strict" or "Transitional."') if ($OPTS{'doctype'} && $OPTS{'doctype'} eq ''); }	
	die('You must specify a doctype, either "Strict" or "Transitional."') if ( !exists($OPTS{doctype}) ); 	
	
	if (exists($OPTS{direction})) { die('You must enter a direction for the language present in the document.') if ($OPTS{'direction'} && $OPTS{'direction'} eq ''); }	
	die('You must specify a direction for the language present in the document.') if ( !exists($OPTS{direction}) ); 
	$OPTS{direction} =~ tr/A-Z/a-z/;	
	
	if (exists($OPTS{lang})) { die('You must enter a language for the document.') if ($OPTS{'lang'} && $OPTS{'lang'} eq ''); }	
	die('You must enter a language for the document.') if ( !exists($OPTS{lang}) ); 
	
	if (exists($OPTS{file}) || exists($OPTS{file_name})) { die('Neither an HTML or CSS file was specified, you must include at least 1!') 
	if ( ($OPTS{'file'} && $OPTS{'file'} eq '') || ($OPTS{'file_name'} && $OPTS{'file_name'} eq '') ); }	
		
	if (exists($OPTS{dir})) { die('A directory was not specified, you must include one!') if ( $OPTS{'dir'} eq '' ); }		
	
	if (exists($OPTS{dir}) && (exists($OPTS{file}) || exists($OPTS{file_name}))) { die('You cannot specify both a directory and file, you must choose one or the other!'); }
			
	if (!exists($OPTS{dir}) && !exists($OPTS{file}) && !exists($OPTS{file_name})) { die('You must specify either a directory or a file.'); }	

$self->{encoding} = $OPTS{encoding}; 
$self->{doctype} = $OPTS{doctype};
$self->{language} = $OPTS{lang};	
$self->{direction} = $OPTS{direction};		

my @file = $OPTS{file} || $OPTS{file_name} if ( $OPTS{file_name} || $OPTS{file} );		
$self->{file} = \@file if ( @file );

my @dir = 'dir '.$OPTS{dir} if ( $OPTS{dir} );		
$self->{directory} = \@dir if ( @dir );		

$self->convert();
	
return $self;

}	

sub convert
{
my ($self) = @_;
	
my $command = ( $self->{file} && !$self->{directory} ? "$self->{encoding} $self->{doctype} $self->{language} $self->{direction} @{$self->{file}}" : "$self->{encoding} $self->{doctype} $self->{language} $self->{direction} @{$self->{directory}}" );

my $script = ( !-e 'lib/HTML2XHTML/convert_xhtml.pl' ? 'convert_xhtml.pl' : 'lib/HTML2XHTML/convert_xhtml.pl' );

eval { system("$script $command "); }; 
      
}

1;

__END__