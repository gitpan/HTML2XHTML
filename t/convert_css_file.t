use strict;

use Test::More 'no_plan';

use lib 'blib/lib/HTML2XHTML/'; 
use HTML2XHTML;

my $convert = new HTML2XHTML(file_name => 't/sample/try.css');
ok($convert, "1 CSS document successfully converted");

# ----------------------------------------------------------------
;1;
# ----------------------------------------------------------------

