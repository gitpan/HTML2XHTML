use 5.00001;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'HTML2XHTML',
    VERSION_FROM      => 'lib/HTML2XHTML/HTML2XHTML.pm', 
    PREREQ_PM         => {
        'Cwd'         => 3.05}
);
