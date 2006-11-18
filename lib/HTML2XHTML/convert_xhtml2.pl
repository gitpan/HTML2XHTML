#!/usr/bin/perl -w

use strict;
use Cwd;
    
# Name     : 
# Author   : Obiora Embry
# Date     									: 09 November 2006 (Thu, November 09, 2006, 12:40:17 PM EST)
# Date Updated (Filename change, etc.)    	: 11 November 2006 (Sat, November 11, 2006, 10:28:40 AM EST)
# Date Complete 1							: 11 November 2006 (Sat, November 11, 2006, 12:47:45 PM EST)
# Date Updated 2							: 13 November 2006 (Mon, November 13, 2006, 12:15:50 PM EST)
# Date Completed 2							: 13 November 2006 (Mon, November 13, 2006, 5:39:28 PM EST)
# Description    							: convert from HTML 3.x/4.x to XHTML 1.0
#Usage										: see below

#user can specify that ALL HTML and CSS documents in a directory should be converted by putting 'dir' or 'directory'
#examples perl convert_xhtml.pl dir [relative|absolute directory path|'current'] || perl convert_xhtml.pl directory 
#[relative|absolute directory path|'current']
#-------------------------------------------------------
#user can specify the names of HTML and external CSS documents (with relative directory location, unless in current 
#directory) separated by commas) that should be converted 
#examples perl convert_xhtml.pl [relative|absolute directory path] filenames 

#Win32 users:
#..//foo//foo.html, ..\foo\foo.html, C://My Documents//foo//foo.html 

my ($html_files_ref,$css_files_ref) = directory_search_convert($ARGV[1]) if ($ARGV[0] && ($ARGV[0] eq 'dir' || $ARGV[0] eq 'directory'));
($html_files_ref,$css_files_ref) = file_convert(@ARGV) if ($ARGV[0] && ($ARGV[0] ne 'dir' && $ARGV[0] ne 'directory'));

printf "\t".$html_files_ref." HTML document%s successfully converted\n", ($html_files_ref == 1) ? '' : 's' if ($ARGV[0] && $html_files_ref);
printf "\t".$css_files_ref." CSS document%s successfully converted\n", ($css_files_ref == 1) ? '' : 's' if ($ARGV[0] && $css_files_ref);

error() unless ($ARGV[0]);
exit(0);

sub directory_search_convert
{
my $dir = ($_[0] eq 'current' ? getcwd() : $_[0]);

my $HTML_files_ref = findfiles($dir,'\.htm');
my $i;

	for ($i = 0; $i < @$HTML_files_ref; $i++)
	{
		convert_html_xhtml(@$HTML_files_ref[$i]);
	}

my $CSS_files_ref = findfiles($dir,'\.css');

	for ($i = 0; $i < @$CSS_files_ref; $i++)
	{
		convert_css_xhtml(@$CSS_files_ref[$i]);
	}		
	
	my $html_files = @$HTML_files_ref;
	my $css_files = @$CSS_files_ref;
	
	return $html_files, $css_files;
}
	
sub findfiles 
{
my ($searchdir, $document_type) = @_;	

my ($filename,@files) = ('',()); 
#current directory = "."

	opendir DIR, $searchdir or error($searchdir, 'directory'); 

	while (defined($filename = readdir(DIR)))
	{ 		
	    push (@files, $searchdir."\\".$filename) if ($filename !~ /^[.]+$/ && $filename =~ /$document_type/); #skip dot + double dot
	}									
	closedir(DIR);
	
	return \@files;
}

sub file_convert
{
my @files = @_;

my ($i,$files_html,$files_css);

	for ($i = 0; $i < @files; $i++)
	{
		$files[$i] =~ s/,//g;
		$files[$i] =~ s!\\!\/\/!g;
		
		error($files[$i], 'file'), next if (!(-e $files[$i]));
		
		convert_html_xhtml($files[$i]) if ($files[$i] =~ /\.htm/);
		convert_css_xhtml($files[$i]) if ($files[$i] =~ /\.css/);
		$files_html++ if ($files[$i] =~ /\.htm/);
		$files_css++ if ($files[$i] =~ /\.css/);
	}
		
	return $files_html,$files_css;	
}

sub convert_html_xhtml
{
my $document = shift;

open(FILE, "<$document") or die "Couldn't open $document for reading\n";	

my $lines;			
my (@lines) = <FILE>;         # read file into @lines
my $file2 = $document;
$file2 =~ s!\.htm|\.html!_xhtml\.html!g;
$file2 =~ s/ll$/l/g;

open(OUTPUT, ">$file2") or die "Couldn't open $file2 for writing\n";

foreach $lines (@lines)              # loop thru file
{ 
	$lines =~ s~<\!DOCTYPE HTML PUBLIC (.+?)>~<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?> \n<\!DOCTYPE html PUBLIC \"-\/\/W3C\/\/DTD XHTML 1.0 Strict\/\/EN\" \"http:\/\/www.w3.org\/TR\/xhtml1\/DTD\/xhtml1-strict.dtd\"> \n<html xmlns=\"http:\/\/www.w3.org\/1999\/xhtml\" xml:lang=\"en\" lang=\"en\">~ig;	
	$lines =~ s/<HTML>//ig;	 	
	$lines =~ s!<META CONTENT=(.+?) HTTP-EQUIV=(.+?)>!!ig;
	$lines =~ s!<META CONTENT =(.+?) HTTP-EQUIV =(.+?)>!!ig;
	$lines =~ s!<META HTTP-EQUIV=(.+?) CONTENT=(.+?)>!!ig;
	$lines =~ s!<META HTTP-EQUIV =(.+?) CONTENT =(.+?)>!!ig;
	$lines =~ s/html/html/ig;	 
	$lines =~ s/TITLE =|TITLE=/title=/ig;	 	
	$lines =~ s/<TITLE/<title/ig;
	$lines =~ s/<\/TITLE/<\/title/ig;
	$lines =~ s/CONTENT =|CONTENT=/content=/ig;		
	$lines =~ s/META/meta/ig;
	$lines =~ s/<META (.*?)>$/<meta $1\/>/ig;
	$lines =~ s/<LINK (.+?)>/<link $1\/>/ig;
	$lines =~ s/NAME/name/ig;	
	$lines =~ s/<HEAD/<head/ig;
	$lines =~ s/<\/HEAD/<\/head/ig;
	$lines =~ s/<LINK/<link/ig;	
	$lines =~ s/HREF/href/ig;
	$lines =~ s/TYPE =|TYPE=/type=/ig;	
	$lines =~ s/REL =|REL=/rel=/ig;
	$lines =~ s/MEDIA =|MEDIA=/media=/ig;		
	$lines =~ s/BODY/body/ig;	
	$lines =~ s/<P>/<p>/ig;	 	
	$lines =~ s/<\/P>/<\/p>/ig;	
	$lines =~ s!<IMG (.+?)>!<img $1\/>!mig;
	$lines =~ s/SRC/src/ig;
	$lines =~ s/CLASS =|CLASS=/class=/ig;
	$lines =~ s/ALT =|ALT=/alt=/ig;
	$lines =~ s/HEIGHT/height/ig;
	$lines =~ s/WIDTH/width/ig;
	$lines =~ s/DIV/div/ig;
	$lines =~ s/<SPAN/<span/ig;
	$lines =~ s/<\/SPAN/<\/span/ig;
	$lines =~ s/ID =|ID=/id=/ig;
	$lines =~ s/<LI/<li/ig;
	$lines =~ s/<\/LI/<\/li/ig;
	$lines =~ s/<A/<a/ig;
	$lines =~ s/<\/A/<\/a/ig;
	$lines =~ s/TARGET =|TARGET=/target=/ig;
	$lines =~ s/CLEAR =|CLEAR=/clear=/ig;	
	$lines =~ s/clear=\"(\w+)\"/clear=\"\L$1\"/ig;	
	$lines =~ s/<BR>/<br\/>/ig;	
	$lines =~ s/<BR (.+?)>/<br $1\/>/ig;	
	$lines =~ s/H(\d{1})/h$1/ig;
	$lines =~ s/<\/FORM/<\/form/ig;
	$lines =~ s/<FORM/<form/ig;	
	$lines =~ s/<UL/<ul/ig;
	$lines =~ s/UL /ul /ig;	
	$lines =~ s/TH /th /ig;
	$lines =~ s/B /b /ig;	
	$lines =~ s/P /p /ig;	
	$lines =~ s/MENU /menu /ig;
	$lines =~ s/SMALL/small/ig;
	$lines =~ s/<\/UL/<\/ul/ig;
	$lines =~ s/<\/ACRONYM/<\/acronym/ig;
	$lines =~ s/<ACRONYM/<acronym/ig;
	$lines =~ s/<\/ABBR/<\/abbr/ig;
	$lines =~ s/<ABBR/<abbr/ig;	
	$lines =~ s/BLOCKQUOTE/blockquote/ig;
	$lines =~ s/<ADDRESS/<address/ig;
	$lines =~ s/<\/ADDRESS/<\/address/ig;	
	$lines =~ s/<CITE/<cite/ig;
	$lines =~ s/<\/CITE/<\/cite/ig;	
	$lines =~ s/<CODE/<code/ig;
	$lines =~ s/<\/CODE/<\/code/ig;	
	$lines =~ s/<DFN/<dfn/ig;
	$lines =~ s/<\/DFN/<\/dfn/ig;	
	$lines =~ s/<PRE/<pre/ig;
	$lines =~ s/<\/PRE/<\/pre/ig;	
	$lines =~ s/<Q/<q/ig;
	$lines =~ s/<\/Q/<\/q/ig;	
	$lines =~ s/<SAMP/<samp/ig;
	$lines =~ s/<\/SAMP/<\/samp/ig;	
	$lines =~ s/<PRE/<pre/ig;
	$lines =~ s/<\/PRE/<\/pre/ig;	
	$lines =~ s/<STRONG/<strong/ig;
	$lines =~ s/<\/STRONG/<\/strong/ig;	
	$lines =~ s/<VAR/<var/ig;
	$lines =~ s/<\/VAR/<\/var/ig;	
	$lines =~ s/<DL/<dl/ig;
	$lines =~ s/<\/DL/<\/dl/ig;	
	$lines =~ s/<DT/<dt/ig;
	$lines =~ s/<\/DT/<\/dt/ig;	
	$lines =~ s/<DD/<dd/ig;
	$lines =~ s/<\/DD/<\/dd/ig;	
	$lines =~ s/<OL/<ol/ig;
	$lines =~ s/<\/OL/<\/ol/ig;	
	$lines =~ s/<PARAM/<param/ig;
	$lines =~ s/<\/PARAM/<\/param/ig;	
	$lines =~ s/<OBJECT/<object/ig;
	$lines =~ s/<\/OBJECT/<\/object/ig;	
	$lines =~ s/BIG/big/ig;
	$lines =~ s/<SUP/<sup/ig;
	$lines =~ s/<\/SUP/<\/sup/ig;	
	$lines =~ s/<SUB/<sub/ig;
	$lines =~ s/<\/SUB/<\/sub/ig;	
	$lines =~ s/<TT/<tt/ig;
	$lines =~ s/<\/TT/<\/tt/ig;	
	$lines =~ s/<DEL/<del/ig;
	$lines =~ s/<\/DEL/<\/del/ig;	
	$lines =~ s/<INS/<ins/ig;
	$lines =~ s/<\/INS/<\/ins/ig;	
	$lines =~ s/<BDO/<bdo/ig;
	$lines =~ s/<\/BDO/<\/bdo/ig;	
	$lines =~ s/<LEGEND/<legend/ig;
	$lines =~ s/<\/LEGEND/<\/legend/ig;	
	$lines =~ s/OPTION/option/ig;
	$lines =~ s/<AREA/<area/ig;
	$lines =~ s/<\/AREA/<\/area/ig;	
	$lines =~ s/<MAP/<map/ig;
	$lines =~ s/<\/MAP/<\/map/ig;	
	$lines =~ s/ISMAP/ismap/ig;
	$lines =~ s/NOSCRIPT/noscript/ig;
	$lines =~ s/SCRIPT/script/ig;
	$lines =~ s/<BASE/<base/ig;
	$lines =~ s/<\/BASE/<\/base/ig;	
	$lines =~ s/<RUBY/<ruby/ig;
	$lines =~ s/<\/RUBY/<\/ruby/ig;	
	$lines =~ s/<RBC/<rbc/ig;
	$lines =~ s/<\/RBC/<\/rbc/ig;	
	$lines =~ s/<RTC/<rtc/ig;
	$lines =~ s/<\/RTC/<\/rtc/ig;	
	$lines =~ s/<RB/<rb/ig;
	$lines =~ s/<\/RB/<\/rb/ig;	
	$lines =~ s/<RT/<rt/ig;
	$lines =~ s/<\/RT/<\/rt/ig;	
	$lines =~ s/<RP/<rp/ig;
	$lines =~ s/<\/RP/<\/rp/ig;		
	$lines =~ s/<TABLE/<table/ig;
	$lines =~ s/<\/TABLE/<\/table/ig;	
	$lines =~ s/TD/td/ig;	
	$lines =~ s/<TR/<tr/ig;
	$lines =~ s/<\/TR/<\/tr/ig;	
	$lines =~ s/TBODY/tbody/ig;	
	$lines =~ s/<CAPTION/<caption/ig;
	$lines =~ s/<\/CAPTION/<\/caption/ig;		
	$lines =~ s/THEAD/thead/ig;	
	$lines =~ s/TFOOT/tfoot/ig;	
	$lines =~ s/COLGROUP/colgroup/ig;	
	$lines =~ s/<COL/<col/ig;
	$lines =~ s/<\/COL/<\/col/ig;	
	$lines =~ s/<TH/<th/ig;
	$lines =~ s/<\/TH/<\/th/ig;	
	$lines =~ s/<EM/<em/ig;
	$lines =~ s/<\/EM/<\/em/ig;	
	$lines =~ s/<b/<b/ig;
	$lines =~ s/<\/b/<\/b/ig;		
	$lines =~ s/<I/<i/ig;
	$lines =~ s/<\/I/<\/i/ig;		
	$lines =~ s/<U/<u/ig;
	$lines =~ s/<\/U/<\/u/ig;		
	$lines =~ s/<BLINK/<blink/ig;
	$lines =~ s/<\/BLINK/<\/blink/ig;		
	$lines =~ s/<EMBED/<embed/ig;
	$lines =~ s/<\/EMBED/<\/embed/ig;	
	$lines =~ s/PLUGINSPAGE/pluginspage/ig;
	$lines =~ s/PLUGINURL/pluginurl/ig;
	$lines =~ s/HIDDEN/hidden/ig;
	$lines =~ s/AUTOSTART/autostart/ig;
	$lines =~ s/LOOP/loop/ig;
	$lines =~ s/PLAYCOUNT/playcount/ig;
	$lines =~ s/VOLUME =|VOLUME=/volume=/ig;
	$lines =~ s/CONTROLS =|VOLUME=/controls=/ig;
	$lines =~ s/CONTROLLER= |VOLUME=/controller=/ig;
	$lines =~ s/MASTERSOUND/mastersound/ig;
	$lines =~ s/STARTTIME/starttime/ig;
	$lines =~ s/ENDTIME/endtime/ig;	
	$lines =~ s/ALIGN =|ALIGN=/align=/ig; 	
	$lines =~ s/align=\"(\w+)\"/align=\"\L$1\"/ig;
	$lines =~ s/SUMMARY =|VOLUME=/summary=/ig; 
	$lines =~ s/DIR =|DIR=/dir=/ig; 		
	$lines =~ s/dir=\"(\w+)\"/dir=\"\L$1\"/ig; 		
	$lines =~ s/LANG =|LANG=/lang=/ig; 		
	$lines =~ s/lang=\"(\w+)\"/lang=\"\L$1\"/ig; 			
	$lines =~ s/SPAN =|SPAN=/span=/ig; 
	$lines =~ s/ROWSPAN =|ROWSPAN=/rowspan=/ig; 
	$lines =~ s/COLSPAN =|COLSPAN=/colspan=/ig; 
	$lines =~ s/NOWRAP/nowrap/ig; 
	$lines =~ s/AXIS =|AXIS=/axis=/ig; 
	$lines =~ s/STYLE =|STYLE=/style=/ig; 
	$lines =~ s/BGCOLOR =|BGCOLOR=/bgcolor=/ig; 
	$lines =~ s/COLOR =|COLOR=/color=/ig;
	$lines =~ s/VALIGN =|VALIGN=/valign=/ig;
	$lines =~ s/CHAR =|CHAR=/char=/ig;
	$lines =~ s/CHAROFF =|CHAROFF-/charoff=/ig;
	$lines =~ s/FRAME =|FRAME=/frame=/ig;
	$lines =~ s/RULES =|RULES=/rules=/ig;
	$lines =~ s/BORDER =|BORDER=/border=/ig;
	$lines =~ s/VSPACE =|VSPACE=/vspace=/ig;
	$lines =~ s/HSPACE =|HSPACE=/hspace=/ig;
	$lines =~ s/ARCHIVE =|ARCHIVE=/archive=/ig;
	$lines =~ s/DECLARE =|DECLARE=/declare=/ig;
	$lines =~ s/STANDBY =|STANDBY=/standby=/ig;
	$lines =~ s/DATA =|DATA=/data=/ig;
	$lines =~ s/CODETYPE =|CODETYPE=/codetype=/ig;
	$lines =~ s/CODEBASE =|CODEBASE=/codebase=/ig;
	$lines =~ s/CLASSID =|CLASSID=/classid=/ig;
	$lines =~ s/CELLSPACING =|CELLSPACING=/cellspacing=/ig;
	$lines =~ s/CELLPADDING =|CELLPADDING=/cellpadding=/ig;
	$lines =~ s/HEADERS =|HEADERS=/headers=/ig;
	$lines =~ s/TEXT =|TEXT=/text=/ig;
	$lines =~ s/BACKGROUND =|BACKGROUND=/background=/ig;
	$lines =~ s/VLINK =|VLINK=/vlink=/ig;
	$lines =~ s/ALINK =|ALINK=/alink=/ig;	
	$lines =~ s/<INPUT (.+?)>/<input $1\/>/ig;			
	$lines =~ s/<BUTTON/<button/ig;
	$lines =~ s/<\/button/<\/button/ig;					
	$lines =~ s/<SELECT/<select/ig;
	$lines =~ s/<\/SELECT/<\/select/ig;			
	$lines =~ s/OPTGROUP/optgroup/ig;	
	$lines =~ s/<TEXTAREA/<textarea/ig;
	$lines =~ s/<\/TEXTAREA/<\/textarea/ig;		
	$lines =~ s/<BUTTON/<button/ig;
	$lines =~ s/<\/BUTTON/<\/button/ig;		
	$lines =~ s/DISABLED =|DISABLED=/disabled=/ig;
	$lines =~ s/READONLY =|READONLY=/readonly=/ig;
	$lines =~ s/TABINDEX =|TABINDEX=/tabindex=/ig;	
	$lines =~ s/ISINDEX/isindex/ig;
	$lines =~ s/PROMPT =|PROMPT=/prompt=/ig;		
	$lines =~ s/<LABEL/<label/ig;
	$lines =~ s/<\/LABEL/<\/label/ig;	
	$lines =~ s/ACCESSKEY =|ACCESSKEY=/accesskey=/ig;
	$lines =~ s/METHOD =|METHOD=/method=/ig;
	$lines =~ s/ACTION =|ACTION=/action=/ig;
	$lines =~ s/ENCTYPE =|ENCTYPE=/enctype=/ig;
	$lines =~ s/<LEGEND/<legend/ig;
	$lines =~ s/<\/LEGEND/<\/legend/ig;	
	$lines =~ s/VALUE =|VALUE=/value=/ig;
	$lines =~ s/<FIELDSET/<fieldset/ig;
	$lines =~ s/<\/FIELDSET/<\/fieldset/ig;	
	$lines =~ s/FOR =|FOR=/for=/ig;	
	$lines =~ s/MAXLENGTH =|MAXLENGTH=/maxlength=/ig;	
	$lines =~ s/SIZE =|SIZE=/size=/ig;	
	$lines =~ s/dtd xhtml/DTD XHTML/ig;		
	$lines =~ s!\/DTD\/!DTD!ig;
	
	print OUTPUT $lines;
}

close(OUTPUT);
close(FILE);
}

sub convert_css_xhtml
{
my $document = shift;

open(FILE, "<$document") or die "Couldn't open $document for reading\n";	

my $lines;			
my (@lines) = <FILE>;         # read file into @lines

my $file2 = $document;
$file2 =~ s!\.css!_xhtml\.css!g;

open(OUTPUT, ">$file2") or die "Couldn't open $file2 for writing\n";

foreach $lines (@lines)              # loop thru file
{ 
	$lines =~ s/TITLE/title/ig;	 
	$lines =~ s/NAME/name/ig;
	$lines =~ s/LINK/link/ig;		
	$lines =~ s/BODY/body/ig;		
	$lines =~ s/P/p/ig;	 				 		
	$lines =~ s/HEIGHT/height/ig;
	$lines =~ s/WIDTH/width/ig;
	$lines =~ s/DIV/div/ig;
	$lines =~ s/SPAN/span/ig;
	$lines =~ s/IMG/img/ig;
	$lines =~ s/ID/id/ig;
	$lines =~ s/LI/li/ig;
	$lines =~ s/A/a/ig;
	$lines =~ s/BR/br/ig;	
	$lines =~ s/FORM/form/ig;
	$lines =~ s/UL/ul/ig;
	$lines =~ s/MENU/menu/ig;
	$lines =~ s/SMALL/small/ig;
	$lines =~ s/ACRONYM/acronym/ig;
	$lines =~ s/ABBR/abbr/ig;
	$lines =~ s/MEDIA/media/ig;	
	$lines =~ s/BLOCKQUOTE/blockquote/ig;
	$lines =~ s/TABLE/table/ig;
	$lines =~ s/TD/tr/ig;
	$lines =~ s/TR/tr/ig;
	$lines =~ s/TBODY/tbody/ig;	
	$lines =~ s/CAPTION/caption/ig;
	$lines =~ s/THEAD/thead/ig;	
	$lines =~ s/TFOOT/tfoot/ig;	
	$lines =~ s/COLGROUP/colgroup/ig;	
	$lines =~ s/COL/col/ig;	
	$lines =~ s/TH/th/ig;	
	$lines =~ s/EM/em/ig;	
	$lines =~ s/B/b/ig;	
	$lines =~ s/I/i/ig;	
	$lines =~ s/U/u/ig;	
	$lines =~ s!H(\d{1})!h$1!ig;
	$lines =~ s/BLINK/blink/ig;	
	$lines =~ s/EMBED/embed/ig;			
	$lines =~ s/EM/em/ig;	
	$lines =~ s/B/b/ig;	
	$lines =~ s/I/i/ig;	
	$lines =~ s/U/u/ig;	
	$lines =~ s/BLINK/blink/ig;	
	$lines =~ s/EMBED/embed/ig;				
	$lines =~ s/ROWSPAN/rowspan/ig;
	$lines =~ s/COLSPAN/colspan/ig;
	$lines =~ s/NOWRAP/nowrap/ig; 
	$lines =~ s/AXIS/axis/ig;	
	$lines =~ s/BGCOLOR/bgcolor/ig;
	$lines =~ s!COLOR!color!ig;
	$lines =~ s!VALIGN!valign!ig;
	$lines =~ s!CHAR!char!ig;
	$lines =~ s!CHAROFF!charoff!ig;
	$lines =~ s!FRAME!frame!ig;
	$lines =~ s!RULES!rules!ig;
	$lines =~ s!BORDER!border!ig;
	$lines =~ s!CELLSPACING!cellspacing!ig;
	$lines =~ s!CELLPADDING!cellpadding!ig;
	$lines =~ s!HEADERS!headers!ig;
	$lines =~ s!TEXT!text!ig;
	$lines =~ s!BACKGROUND!background!ig;
	$lines =~ s!VLINK!vlink!ig;
	$lines =~ s!ALINK!alink!ig;		
	$lines =~ s/INPUT/input/ig;	
	$lines =~ s/BUTTON/button/ig;	
	$lines =~ s/SELECT/select/ig;	
	$lines =~ s/OPTGROUP/optgroup/ig;	
	$lines =~ s/TEXTAREA/textarea/ig;	
	$lines =~ s/BUTTON/button/ig;	
	$lines =~ s/LABEL/label/ig;	
	$lines =~ s/LEGEND/legend/ig;	
	$lines =~ s/FIELDSET/fieldset/ig;
	$lines =~ s/ADDRESS/address/ig;	
	$lines =~ s/CITE/cite/ig;	
	$lines =~ s/CODE/code/ig;
	$lines =~ s/DFN/dfn/ig;	
	$lines =~ s/PRE/pre/ig;	
	$lines =~ s/Q/q/ig;	
	$lines =~ s/SAMP/samp/ig;	
	$lines =~ s/PRE/pre/ig;	
	$lines =~ s/STRONG/strong/ig;	
	$lines =~ s/VAR/var/ig;	
	$lines =~ s/DL/dl/ig;	
	$lines =~ s/DT/dt/ig;	
	$lines =~ s/DD/dd/ig;	
	$lines =~ s/OL/ol/ig;	
	$lines =~ s/PARAM/param/ig;	
	$lines =~ s/OBJECT/object/ig;	
	$lines =~ s/BIG/big/ig;
	$lines =~ s/SUP/sup/ig;	
	$lines =~ s/SUB/sub/ig;	
	$lines =~ s/TT/tt/ig;	
	$lines =~ s/DEL/del/ig;	
	$lines =~ s/INS/ins/ig;	
	$lines =~ s/BDO/bdo/ig;	
	$lines =~ s/LEGEND/legend/ig;	
	$lines =~ s/OPTION/option/ig;
	$lines =~ s/AREA/area/ig;	
	$lines =~ s/MAP/map/ig;
	$lines =~ s/ISMAP/ismap/ig;
	$lines =~ s/NOSCRIPT/noscript/ig;
	$lines =~ s/SCRIPT/script/ig;
	$lines =~ s/BASE/base/ig;	
	$lines =~ s/RUBY/ruby/ig;	
	$lines =~ s/RBC/rbc/ig;	
	$lines =~ s/RTC/rtc/ig;	
	$lines =~ s/RB/rb/ig;	
	$lines =~ s/RT/rt/ig;	
	$lines =~ s/RP/rp/ig;	
			
	print OUTPUT $lines;
}

close(OUTPUT);
close(FILE);
}

sub error
{
	print "\a\t".'You did not enter anything to convert to convert, please do so the next time.'."\n" if (!$_[0]);
	
	my $error = ($_[0] && $_[1] && $_[1] !~ /dir/ ? ("\a\t".'The '.$_[1].' '.$_[0]. ' does not exist, skipping...'."\n\n") :
	&do_me($_[0], $_[1]) ) if ($_[0]); 
	
	return $error if ($error);
}

sub do_me { print "\a\t".'The '.$_[1].' '.$_[0]. ' does not exist, exiting...'."\n\n"; sleep(2); exit(0); }
#gets called if directory does not exist