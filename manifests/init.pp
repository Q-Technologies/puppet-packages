class packages {

  #$packages = [ 'git' ]

  if $kernel == "Darwin" {
    Package { provider => 'macports' }
  }
  
  if $osfamily == "Suse" {
    Package { provider => 'zypper' }
  }
  
  # Populate using hiera_hash command as we want to merge data from multiple hiera configs
  $pkg_remove = hiera_array('packages::remove', [])
  $pkg_add = hiera_array('packages::add',[])

  # Make sure we don't try to remove any we have tried to add
  $pkg_to_remove = $pkg_remove - $pkg_add
  Package { $pkg_to_remove:
    ensure => absent,
  }

  Package { $pkg_add:
    ensure => installed,
  }



}
