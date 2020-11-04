function fail
{
  exit 1
}
#config=custom-system.scm
#{
#  guix system build --fallback --root=system.build $config || fail
#}
#  { image_location=$(guix system vm-image $config)
#   if test -n "$image_location"
#    then
#      echo copying...
#      cp $image_location ./system.qcow2
#      echo copied.
#      chmod u+rw system.qcow2
#      echo done.
#    fi
#  }
#  {
#    image_location=$(guix system disk-image --save-provenance -t raw $config)
#    if test -n "$image_location"
#    then
#      echo copying...
#      cp $image_location ./system.img
#      echo copied.
#      chmod u+rw system.img
#      echo done
#    fi
#  }
#  { image_location=$(guix system disk-image --save-provenance -t iso9660 $config)
#    if test -n "$image_location"
#    then
#      echo copying...
#      cp $image_location ./system.iso
#      echo copied.
#      chmod u+rw system.iso
#     echo done
#    fi
#  }
config=custom-system.scm
{
  guix system build --fallback --verbosity=1 --system=armhf-linux --root=system.arm.build $config || fail
}
  { image_location=$(guix system disk-image --verbosity=1 --system=armhf-linux --save-provenance -t arm $config)
    if test -n "$image_location"
    then
      echo copying...
      cp $image_location ./system.arm.img
      echo copied.
      chmod u+rw system.arm.img
     echo done
    fi
  }
