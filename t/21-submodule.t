use strict;
use warnings;
use Test::More;
use Test::Git;
use Git::Repository;

has_git( '1.5.0' );

plan skip_all =>
    "Removing environment variables requires System::Command 1.04, this is only $System::Command::VERSION"
    if $System::Command::VERSION < 1.04;

plan tests => 1;

# clean up the environment
delete @ENV{qw( GIT_DIR GIT_WORK_TREE )};
$ENV{GIT_AUTHOR_NAME}     = 'Test Author';
$ENV{GIT_AUTHOR_EMAIL}    = 'test.author@example.com';
$ENV{GIT_COMMITTER_NAME}  = 'Test Committer';
$ENV{GIT_COMMITTER_EMAIL} = 'test.committer@example.com';

# create a small repository
my $s      = test_repository;
my $tree   = $s->run( mktree => { input => '' } );
my $commit = $s->run( 'commit-tree' => $tree, { input => 'empty tree' } );
$s->run( 'update-ref', 'refs/heads/master' => $commit );

# now test adding a submodule
my $r = test_repository;
$r->run(
    submodule => add => $s->work_tree => 'sub',
    { env => { GIT_WORK_TREE => undef } }
);

# do the test
my $status = $r->run('submodule', 'status', 'sub' );
is( $status,
    $r->version_ge('1.7.6.1') ? " $commit sub (heads/master)" : "-$commit sub",
    'git submodule status'
);

