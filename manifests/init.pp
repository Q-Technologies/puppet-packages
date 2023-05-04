# packages - class to easily manage lists of packages
class packages (
  String $provider,
) {
  include stdlib

  # Populate using lookup command as we want to merge data from multiple hiera configs
  $pkg_remove = lookup('packages::remove', Data, 'deep',  {})
  $pkg_add = lookup('packages::add', Data, 'deep', {})
  $pkg_ignore = lookup('packages::ignore', Data, 'deep', {})

  # get a list of packages from each subgroup from hiera
  $list_kernel_add = $pkg_add[$facts[kernel]]
  $list_osfamily_add = $pkg_add[$facts[osfamily]]
  $list_kernel_rm = $pkg_remove[$facts[kernel]]
  $list_osfamily_rm =  $pkg_remove[$facts[osfamily]]
  $list_kernel_ig = $pkg_ignore[$facts[kernel]]
  $list_osfamily_ig =  $pkg_ignore[$facts[osfamily]]

  # Merge these lists into one array
  if $list_osfamily_add {
    $list_add = unique(any2array($list_kernel_add) + any2array($list_osfamily_add))
  } else {
    $list_add = unique(any2array($list_kernel_add))
  }

  if $list_osfamily_rm {
    $list_remove = unique(any2array($list_kernel_rm) + any2array($list_osfamily_rm))
  } else {
    $list_remove = unique(any2array($list_kernel_rm))
  }

  if $list_osfamily_ig {
    $list_ignore = unique(any2array($list_kernel_ig) + any2array($list_osfamily_ig))
  } else {
    $list_ignore = unique(any2array($list_kernel_ig))
  }

  # Make sure we don't try to remove any we have tried to add
  $pkg_to_remove = unique( $list_remove - $list_add - $list_ignore )
  $pkg_to_remove.each | $pkg | {
    if $pkg != '' {
      Package { $pkg:
        ensure   => absent,
        provider => $provider,
      }
    }
  }

  $pkgs_to_add = unique( $list_add - $list_ignore )
  $pkgs_to_add.each | $pkg | {
    if $pkg != '' {
      if $pkg =~ Array {
        Package { $pkg[0]:
          ensure   => $pkg[1],
          provider => $provider,
        }
      } else {
        Package { $pkg:
          ensure   => installed,
          provider => $provider,
        }
      }
    }
  }
}
