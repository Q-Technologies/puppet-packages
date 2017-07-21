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
  $pkg_remove = hiera_hash('packages::remove', {})
  $pkg_add = hiera_hash('packages::add',{})

  # get a list of packages from each subgroup from hiera
  $list_kernel_add = $pkg_add[$facts[kernel]]
  $list_osfamily_add = $pkg_add[$facts[osfamily]]
  $list_kernel_rm = $pkg_remove[$facts[kernel]]
  $list_osfamily_rm =  $pkg_remove[$facts[osfamily]]

  # Merge these lists into one array
  if $list_osfamily_add {
    $list_add = any2array($list_kernel_add) + any2array($list_osfamily_add)
  } else {
    $list_add = any2array($list_kernel_add)
  }

  if $list_osfamily_rm {
    $list_remove = any2array($list_kernel_rm) + any2array($list_osfamily_rm)
  } else {
    $list_remove = any2array($list_kernel_rm)
  }

  # Make sure we don't try to remove any we have tried to add
  $pkg_to_remove = $list_remove - $list_add
  $pkg_to_remove.each | $pkg | {
    if $pkg != "" {
      Package { $pkg:
        ensure => absent,
      }
    }
  }

  $pkgs_to_add = $list_add
  $pkgs_to_add.each | $pkg | {
    if $pkg != "" {
      Package { $pkg:
        ensure => installed,
      }
    }
  }



}
