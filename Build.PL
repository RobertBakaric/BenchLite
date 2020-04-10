use Module::Build;
# See perldoc Module::Build for details of how this works I will not
# be explaining this now

use File::Copy::Recursive qw(rcopy);
rcopy("./src/lib/*", "./lib");
rcopy("./src/bin/*", "./bin");
rcopy("./src/t/*", "./t");

my $class = Module::Build->subclass
(
    class => 'BenchLite',
    code => q{
        sub ACTION_build{
            my $self = shift;
            $self->do_system('perl ./bin/check.pl');
            $self->SUPER::ACTION_build();
        }
    }
);

my $mb = $class->new(
      dist_name       => 'BenchLite',
      dist_version    => '0.04',
      module_name     => 'BenchLite',
      license         => 'GPL.v3.0',
      dist_author     => 'Robert Bakaric & Neva Skrabar',
      dist_abstract   => "Abstract",
      #script_files    => './src/apps/build_ppipe',
      configure_requires => {
          'Module::Build' => 0.4224,
          'perl'          => 5.200,
          'File::Path'   => 2.12,
          'File::Copy::Recursive'  => 0.32
      },
      requires        => {
          'YAML'          => 1.24,
          'File::Copy'    => 2.32,
          'File::Find'    => 1.34,
          'File::Spec'    => 3.67,
          'Cwd'           => 3.67,
          'Carp'          => 1.42,
          'vars'          => 1.03,
          'IPC::Cmd'      => 0.96,
          'JSON'          => 4.02,
          'File::Basename'=> 2.85,
          'File::Slurp'   => 9999.19,
          'Getopt::Long'  => 2.49,
          'Time::HiRes'   => 1.9741,
          'Proc::ProcessTable' => 0.59,
          'IO::CaptureOutput'  => 1.1105,
          'Statistics::Basic'  => 1.6611,
          'Statistics::R' => 0.34,
          'Math::Complex' => 1.5901,
          'Array::Utils'  => 0.5,

      },
#      auto_features   => {
#          config_support => {
#              description => "Use compact YAML script",
#              requires    => {SVN::Notify::Config => 0.0906}
#          },
#          rsync_support => {
#              description => "Transfer files with rsync",
#              requires    => {File::Rsync => 0.42}
#          },
#      },
#      PL_files => {
#          't/002_config.t.PL' =>
#              ['t/testconfig','t/002_config.t','t/002_config'],
#      },
      add_to_cleanup =>
          ['t/00[2-4]*.t'],
    );

$mb->create_build_script;
