#!perl -w

use strict;
use Fcntl ':flock'; #import LOCK_* constants
use Cwd;
use File::Flock;
use vars qw/%elements %attributes/;
    
# Name     : HTML2XHTML
# Author   : Obiora Embry
# Date     : 09 November 2006 (Thu November 09, 2006 12:40:17, PM EST)
# Date Update #1 (Filename change, etc.)    : 11 November 2006 (Sat, November 11, 2006, 10:28:40 AM EST)
# Date Update #2 	: 04 January 2008 (Fri, January 04, 2008, 10:47:57 AM EST)
# Old Complete Date: 11 November 2006 (Sat, November 11, 2006, 12:47:45 PM EST)
# New Complete Date: 04 January 2008 (Fri, January 04, 2008, 11:11:32 PM EST)
# Description     : convert from HTML 4 to XHTML 1.0 (transitional or strict)

#######################
#    Usage (see below):
# user can specify that all HTML and CSS documents in current directory should be converted by typing 'dir' or 'directory'
#
#    example #1: 
# perl convert_xhtml.pl encoding doctype lang direction dir [relative|absolute (directory path)|'current'] 
#-------------------------------------------------------
# user can specify the names of HTML and CSS documents (with relative directory location, unless in current directory)
# separated by commas that should be converted 
#
#    example #2: 
# perl convert_xhtml.pl encoding doctype lang direction [relative|absolute (directory path)] filename,[relative|absolute (directory path)] filename  [April 26, 2007]
#######################

$ARGV[0] = $ARGV[0].' '.$ARGV[1] if ( $ARGV[0] =~ /\w*/ && $ARGV[1] =~ /^\d/ );
$ARGV[1] = $ARGV[2] if ( $ARGV[0] =~ /\w* \d{0,}/ );
$ARGV[2] = $ARGV[3] if ( $ARGV[0] =~ /\w* \d{0,}/ );
$ARGV[3] = $ARGV[4] if ( $ARGV[0] =~ /\w* \d{0,}/ );
$ARGV[4] = $ARGV[5] if ( $ARGV[0] =~ /\w* \d{0,}/ );
$ARGV[5] = $ARGV[6] if ( $ARGV[0] =~ /\w* \d{0,}/ );

error('encoding') unless ( $ARGV[0] && $ARGV[0] !~ /strict/i && $ARGV[0] !~ /transitional/i); 
error('doctype') unless ( $ARGV[1] && ( $ARGV[1] !~ /strict/i || $ARGV[1] !~ /transitional/i ) );
error('language') unless ( $ARGV[2] && $ARGV[2] ne 'dir' && $ARGV[2] ne 'directory' );
error('direction') unless ( $ARGV[3] && ( $ARGV[3] !~ /RTL/i || $ARGV[3] !~ /LTR/i ) );
error('file') unless ( $ARGV[4] );    
error('file') if ( $ARGV[4] && !$ARGV[5] && ( $ARGV[4] eq 'dir' || $ARGV[4] eq 'directory' ) );

(%elements, %attributes) = ( (), () );

my ($html_files_ref,$css_files_ref) = directory_search_convert($ARGV[5]) if ( $ARGV[4] && $ARGV[4] eq 'dir' || $ARGV[4] eq 'directory' );
($html_files_ref,$css_files_ref) = file_convert($ARGV[4]) if ( $ARGV[4] && $ARGV[4] ne 'dir' && $ARGV[4] ne 'directory' );

print qq{\n};
printf "\t".@$html_files_ref.qq{ HTML document%s%s converted\n}, ( @$html_files_ref == 1 ? '' : 's' ), ( %elements || %attributes ? '' : ' successfully' ) if ( $ARGV[4] && @$html_files_ref );
printf "\t".@$css_files_ref.qq{ CSS document%s%s converted\n}, ( @$css_files_ref == 1 ? '' : 's' ), ( %elements || %attributes ? '' : ' successfully' ) if ( $ARGV[4] && @$css_files_ref );

printf qq{\n%s \n\n%s\n }, ( %attributes ? 'Did NOT validate all attributes, check invalid_attribute.txt for details...' : '' ), ( %elements ? 'Did NOT validate all elements, check invalid_elements.txt for details...' : '' ) if ( %attributes || %elements );

sub directory_search_convert
{
my $dir = ( $_[0] eq 'current' ? getcwd() : $_[0] );

my ($i, @HTML_files, @CSS_files) = ( '', (), () );

@HTML_files = <$dir/*.html>;
push (@HTML_files, <$dir/*.htm>);
	
	for ($i = 0; $i < @HTML_files; $i++)
	{
		splice(@HTML_files, $i, 1) if ( $HTML_files[$i] =~ /_xhtml\.html/ );
		convert_html_xhtml($HTML_files[$i]) if ( $HTML_files[$i] && $HTML_files[$i] !~ /_xhtml\.html/ );
	}

@CSS_files = <$dir/*.css>;

	for ($i = 0; $i < @CSS_files; $i++)
	{
		splice(@CSS_files, $i, 1) if ( $CSS_files[$i] =~ /_xhtml\.css/ );
		convert_css_xhtml($CSS_files[$i]) if ( $CSS_files[$i] && $CSS_files[$i] !~ /_xhtml\.css/ );
	}		
		
return \@HTML_files, \@CSS_files;
}
	
sub file_convert
{
my @files_now = split(/,\s{0,}/, $_[0]);

my ($i, $files_html, $files_css, @HTML_files, @CSS_files) = ( 0, 0, 0, (), () );

	for ($i = 0; $i < @files_now; $i++)
	{
		
		convert_html_xhtml($files_now[$i]) if ( $files_now[$i] =~ /\.htm/ && $files_now[$i] !~ /_xhtml\.html/ );
		convert_css_xhtml($files_now[$i]) if ( $files_now[$i] =~ /\.css/ && $files_now[$i] !~ /_xhtml\.css/ );
		
		$files_html++ if ( $files_now[$i] =~ /\.htm/ && $files_now[$i] !~ /_xhtml\.html/ );
		$files_css++ if ( $files_now[$i] =~ /\.css/ && $files_now[$i] !~ /_xhtml\.css/ );
		
		push (@HTML_files, $files_html) if ( $files_now[$i] =~ /\.htm/ && $files_now[$i] !~ /_xhtml\.html/ );
		push (@CSS_files, $files_css) if ( $files_now[$i] =~ /\.css/ && $files_now[$i] !~ /_xhtml\.css/ );
		
	}
		
return \@HTML_files, \@CSS_files;	
}

sub convert_html_xhtml
{
my $document = shift;

my $doctype_uri = ( $ARGV[1] =~ /strict/i ? 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd' : 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd' );

my $type = lc($ARGV[1]);

my $file2 = $document;
$file2 =~ s!\.htm$|\.html$!_xhtml\.html!g if ( $file2 !~ /_xhtml\.html/ );

open(FILE, "<", $document) or error(qq{Couldn't open $document for reading\n});	
lock($document, 'shared');
my (@lines) = <FILE>;         #  read file into @lines

my $SEMAPHOREHTML = $file2.'.lck';
open(SHTML, ">", $SEMAPHOREHTML) or error(qq{Couldn't open $SEMAPHOREHTML:'});
flock(SHTML, LOCK_EX) or die "flock() failed for $SEMAPHOREHTML: $!";	
open(OUTPUT, ">", $file2) or error(qq{Couldn't open $file2 for writing\n});

foreach (@lines)              #  loop thru file
{ 
	
	$_ =~ s~<\!DOCTYPE HTML PUBLIC (.+?)>~<?xml version=\"1.0\" encoding=\"$ARGV[0]\"?> \n<\!DOCTYPE html PUBLIC \"-\/\/W3C\/\/DTD XHTML 1.0 \u\l$ARGV[1]\/\/EN\" \"$doctype_uri\"> \n<html xmlns=\"http:\/\/www.w3.org\/1999\/xhtml\" xml:lang=\"en\" lang=\"en\">~i;		 	
	$_ =~ s!<META CONTENT\s{0,}=\s{0,}(.+?) HTTP-EQUIV\s{0,}=\s{0,}(.+?)>|<META HTTP-EQUIV\s{0,}=\s{0,}(.+?) CONTENT\s{0,}=\s{0,}(.+?)|<html>!!ig;		
	$_ =~ s!<META (.*?)>$!<meta \L$1\E \/>!ig;
	$_ =~ s!<LINK (.+?)>!<link \L$1\E \/>!ig;		
	$_ =~ s!<BODY>!<body lang=\"$ARGV[2]\" dir=\"$ARGV[3]\">!i;
	$_ =~ s!<BODY (.+?)>!<body \L$1\E>!mig;
	$_ =~ s!<IMG (.+?)>!<img $1 \/>!mig;
	$_ =~ s!<INPUT (.+?)>!<input $1\/>!ig;			
		
	$_ =~ s!<(\w*)>!<\L$1\E>!ig; #  matches everything like <b>
	$_ =~ s!<\/(\w*)>!<\/\L$1\E>!ig; #  matches everything like </b>
							
	$_ =~ s/\b(HREF|SRC|HEIGHT|WIDTH|DIV|BIG|MENU|SMALL|OPTION|ISMAP|NOSCRIPT|SCRIPT|PLUGINSPAGE|PLUGINURL)\b/\L$1\E/ig;
	$_ =~ s/\b(LOOP|PLAYCOUNT|MASTERSOUND|STARTTIME|ENDTIME|TBODY|NOWRAP|OPTGROUP|ISINDEX|AUTOSTART|HIDDEN|SELECTED)\b/\L$1\E/ig;
			
	$_ =~ s!\b(\w*)\s{0,}=\s{0,}\"(\w+)\"|\b(\w+)\s{0,}=\s{0,}(\w+)!\L$1\E=\"$2\"!ig; #  matches everything like dir = "ltr"			
	
	#  transformation
	$_ =~ s!<(caption|div|h[1..6]|hr|img|input|legend|p|table)\s{0,}ALIGN\s{0,}=\s{0,}\"(\w+)\"|<(caption|div|h[1..6]|hr|img|input|legend|p|table)\s{0,}ALIGN\s{0,}=\s{0,}(\w+)!<\L$1 style=\"text-align: $2"\E!ig; 	
	$_ =~ s/NAME\s{0,}=\s{0,}\"(\w+)\"|NAME\s{0,}=\s{0,}(\w+)/id=\"$1\"/ig;	
	
	print OUTPUT $_;
		
}

close(OUTPUT);
close(FILE);
close(SHTML);			
	
unlink $SEMAPHOREHTML;		

validate_xhtml(\$file2, \$type);

}	

sub validate_xhtml
{
my ($file2_ref, $type_ref) = @_;
my ($file2, $type) = ( $$file2_ref, $$type_ref );

my ($i, $SEMAPHOREHTML, $element, $attribute) = ( 0, '', '', '' );
(%elements, %attributes) = ( (), () );

$. = 1;

open(FILE, "<", $file2) or error(qq{Couldn't open $file2 for reading\n});	
lock($file2, 'shared');

while ( <FILE> )
{
	
	$_ =~ m/\b(applet|basefont|center|font|iframe|isindex|menu|noframes|s|strike|u)\b/i if ( $ARGV[1] =~ /strict/i );	
	$element = $1;	
	$elements{$type}->{element} .= $element.', ' if ( $element && $ARGV[1] =~ /strict/i );
	$elements{$type}->{line_number} .= $..', ' if ( $element && $ARGV[1] =~ /strict/i );
		
	$_ =~ m/\b(alink|background|bgcolor|border|align|code|codebase|color|cols|compact|dir|face|frameborder|height|hspace|ismap|lang|link|longdesc|marginheight|marginwidth|name|noresize|noshade|nowrap|object|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onload|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|onunload|rows|scrolling|size|src|start|style|target|text|title|type|version|vlink|vspace|width)\b/i if ( $ARGV[1] =~ /strict/i );	
	$attribute = $1;
	$attributes{$type}->{attribute} .= $attribute.', ' if ( $attribute && $ARGV[1] =~ /strict/i && $_ =~ /\b(applet|body|iframe|caption|div|h[1..6]|hr|img|input|legend|p|table|tr|td|th|font|basefont|frameset|dir|dl|menu|ol|ul|li|frame|a|html)\b/i );
	$attributes{$type}->{line_number} .= $..', ' if ( $attribute && $ARGV[1] =~ /strict/i && $_ =~ /\b(applet|body|iframe|caption|div|h[1..6]|hr|img|input|legend|p|table|tr|td|th|font|basefont|frameset|dir|dl|menu|ol|ul|li|frame|a|html)\b/i );
	
	$_ =~ m/\b(align|cols|dir|frameborder|height|lang|longdesc|marginheight|marginwidth|name|noresize|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onload|onmousedown|onmouseout|onmouseover|onmouseup|onunload|rows|scrolling|src|width)\b/i if ( $ARGV[1] =~ /strict/i );	
	$attribute = $1;
	$attributes{$type}->{attribute} .= $attribute.', ' if ( $attribute && $ARGV[1] =~ /strict/i && $_ =~ /\b(iframe|frameset|frame)\b/i );
	$attributes{$type}->{line_number} .= $..', ' if ( $attribute && $ARGV[1] =~ /strict/i && $_ =~ /\b(iframe|frameset|frame)\b/i );
		
	$.++;					
	
}
close(FILE);

my (@line_number, @element, @attribute) = ( 0, (), (), () );

if ( %elements )
{

	$SEMAPHOREHTML = 'invalid_element.txt.lck';
	open(SHTML, ">", $SEMAPHOREHTML) or error(qq{Couldn't open $SEMAPHOREHTML:'});
	flock(SHTML, LOCK_EX) or die "flock() failed for $SEMAPHOREHTML: $!";	
	open (ERROR, ">", 'invalid_element.txt') or error(qq{Couldn't open invalid_element.txt for writing}) if ( !-e 'invalid_element.txt' );
	open (ERROR, ">>", 'invalid_element.txt') or error(qq{Couldn't open invalid_element.txt for writing}) if ( -e 'invalid_element.txt' );
	print ERROR qq{\n\n\tYour Web page "$file2" is NOT valid because it contains\n1 or more elements (see below) that have been deprecated in XHTML 1.0 Strict.\n\n};

	foreach ( keys %elements ) 
	{ 
		@line_number = split(/, /, $elements{$_}->{line_number});
		@element = split(/, /, $elements{$_}->{element});
	
		for ($i = 0; $i < @line_number; $i++ )
		{
			print ERROR qq{Line #: $line_number[$i]\tElement: $element[$i]\n}; 
		
		}
			
	}
	
print ERROR <<EOF;


     Check out the following resources below for more information on creating valid XHTML 1.0 $type documents:

http://www.blackwidows.co.uk/resources/tutorials/xhtml/attribute-comparison.php "XHTML1.0 Element Attributes by DTD"

http://www.december.com/html/x1/ "XHTML 1.0 Strict Reference"

http://www.zvon.org/xxl/xhtmlReference/Output/comparison.html "Comparison of Strict and Transitional XHTML"

__________________________________________________________________________________________

EOF

close(ERROR);
close(SHTML);			
	
unlink $SEMAPHOREHTML;	
	
}

if ( %attributes )
{	
	
	$SEMAPHOREHTML = 'invalid_attribute.txt.lck';
	open(SHTML, ">", $SEMAPHOREHTML) or error(qq{Couldn't open $SEMAPHOREHTML:'});
	flock(SHTML, LOCK_EX) or die "flock() failed for $SEMAPHOREHTML: $!";		
	open (ERROR, ">", "invalid_attribute.txt") or error(qq{Couldn't open invalid_attribute.txt for writing}) if ( !-e 'invalid_attribute.txt' );
	open (ERROR, ">>", "invalid_attribute.txt") or error(qq{Couldn't open invalid_attribute.txt for writing}) if ( -e 'invalid_attribute.txt' );
	print ERROR qq{\n\n\tYour Web page "$file2" is NOT valid because it contains\n 1 or more attributes (see below) that are unvailable or deprecated in XHTML 1.0 $type.\n\n};

	foreach ( keys %attributes ) 
	{ 
		@line_number = split(/, /, $attributes{$_}->{line_number});
		@attribute = split(/, /, $attributes{$_}->{attribute});
	
		for ($i = 0; $i < @line_number; $i++ )
		{
			print ERROR qq{Line #: $line_number[$i]\tattribute: $attribute[$i]\n}; 
		
		}
			
	}
	
print ERROR <<EOF;


     Check out the following resources below for more information on creating valid XHTML 1.0 $type documents:

http://www.blackwidows.co.uk/resources/tutorials/xhtml/attribute-comparison.php "XHTML1.0 Element Attributes by DTD"

http://www.december.com/html/x1/ "XHTML 1.0 Strict Reference"

http://www.zvon.org/xxl/xhtmlReference/Output/comparison.html "Comparison of Strict and Transitional XHTML"

__________________________________________________________________________________________

EOF

close(ERROR);
close(SHTML);			
	
unlink $SEMAPHOREHTML;	
	
}

}

sub convert_css_xhtml
{
my $document = shift;

open(FILE, "<", $document) or error(qq{Couldn't open $document for reading\n});	

my (@lines) = <FILE>;         # read file into @lines

my $file2 = $document;
$file2 =~ s!\.css!_xhtml\.css!g if ( $file2 !~ /_xhtml\.css/ );

open(OUTPUT, ">", $file2) or error(qq{Couldn't open $file2 for writing\n});

foreach (@lines)              # loop thru file
{ 
	$_ =~ s/\s{0,}(\w+)\s{0,}{/\L$1\E {/ig;	 
			
	print OUTPUT $_;
}

close(OUTPUT);
close(FILE);

}

sub error
{
	
my $error = shift;

print $error."\n" if ( $error =~ /\s{1,}/ );
print qq{\tYou must specify a language for your document!\n} if ( $error eq 'language' );
print qq{\tYou must specify a direction for the language present in the document, either "LTR" or "RTL."\n} if ( $error eq 'direction' );
print qq{\tYou must specify a doctype, either "Strict" or "Transitional."\n} if ( $error eq 'doctype' );
print qq{\tYou must specify an encoding (i.e., UTF-8, UTF-16, ISO-ISO-8859-1)!\n} if ( $error eq 'encoding' );
print qq{\tYou did not enter anything to convert, please do so the next time.\n} if ( $error eq 'file' );
	
exit(0);

}