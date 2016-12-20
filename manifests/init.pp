class packages {

  include stdlib

  #$packages = [ 'git' ]

  if $kernel == "Darwin" {
    Package { provider => 'macports' }
  }
  
  if $osfamily == "Suse" {
    Package { provider => 'zypper' }
  }
  
  # Populate using hiera_hash command as we want to merge data from multiple hiera configs
  $pkg_remove = hiera_hash('packages::remove', [])
  $pkg_add = hiera_hash('packages::add',[])

  $list_kernel_add = any2array( $pkg_add[$facts[kernel]] )
  $list_osfamily_add = any2array( $pkg_add[$facts[osfamily]] )
  $list_kernel_rm = any2array( $pkg_remove[$facts[kernel]] )
  $list_osfamily_rm = any2array( $pkg_remove[$facts[osfamily]] )

  $list_add = $list_kernel_add + $list_osfamily_add
  $list_remove = $list_kernel_rm + $list_osfamily_rm

  # Make sure we don't try to remove any we have tried to add
  $pkg_to_remove = $list_remove - $list_add
  unless empty( $pkg_to_remove ){
    Package { $pkg_to_remove:
      ensure => absent,
    }
  }

  $pkgs_to_add = $list_add
  unless empty( $pkgs_to_add ){
    Package { $pkgs_to_add:
      ensure => installed,
    }
  }



}
