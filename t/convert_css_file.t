use strict;

use Test::More 'no_plan';

use lib 'blib/lib/HTML2XHTML/'; 
use HTML2XHTML;

my $convert = new HTML2XHTML(encoding => 'UTF-8', file_name => 't/sample/try.css', doctype=>'Transitional', direction=>'LTR', lang=>'en');
ok($convert, "1 CSS document successfully converted");

# ----------------------------------------------------------------
;1;
# ----------------------------------------------------------------

