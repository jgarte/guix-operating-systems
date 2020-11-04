(use-modules (gnu))
;(use-modules (gnu bootloader))
;(use-modules (gnu bootloader grub))
;(use-modules (gnu services base))
(use-modules (gnu services desktop))
(use-modules (gnu services networking))
(use-modules (gnu services xorg))
;(use-modules (gnu system file-systems))
(use-modules (srfi srfi-1))
;(use-modules (guix gexp))
(use-modules (gnu services dbus))
(use-modules (gnu services cups))

(define my-bootloader
  (bootloader-configuration
             (bootloader grub-bootloader)
              (timeout 0)))

(define (number-sequence min max)
  (letrec ((number-sequence*
                 (lambda (max current)
                         (if (< max min)
                             current
                             (number-sequence* (1- max) (cons max current))))))
           (number-sequence* max '())))

(define virtual-terminals
    (cons
    (service console-font-service-type
      (map (lambda (number)
             (cons (string-append "tty" (number->string number))
                %default-console-font))
           (number-sequence 2 63)))

    (map (lambda (number)
            (service mingetty-service-type
                     (mingetty-configuration
                          (tty (string-append "tty"
                                              (number->string number))))))
         (number-sequence 2 63))))

(define my-syslog.conf
  (plain-file "syslog.conf""\
     # Log all kernel messages, authentication messages of
     # level notice or higher and anything of level err or
     # higher to the console.
     # Don't log private authentication messages!
     *.err;kern.*;auth.notice;authpriv.none  /dev/console

     # Log anything (except mail) of level info or higher.
     # Don't log private authentication messages!
     *.info;mail.none;authpriv.none          /var/log/messages

     # The authpriv file has restricted access.
     authpriv.*                              /var/log/secure

     # Log all the mail messages in one place.
     mail.*                                  /var/log/maillog

     # Everybody gets emergency messages, plus log them on another
     # machine.
     *.emerg                                 *

     # Root gets alert and higher messages.
     *.alert                                 root

     # Simplify security auditing, by collecting sudo uses.
     ! sudo
     *.info                                  /var/log/sudo

     # Collect time server reports.
     #! ntpd
     *.*                                     /var/log/ntpd

     # Stop selecting on message tags.
     !*

     # Save mail and news errors of level err and higher in a
     # special file.
     uucp,news.crit                          /var/log/spoolerr"))


(define my-slim-service
  (service slim-service-type
          (slim-configuration
               (display ":1")
               (vt "vt1"))))

(define my-services
  (append
   virtual-terminals
   (list ;(service dhcp-client-service-type)
         (service syslog-service-type
                  (syslog-configuration (config-file my-syslog.conf)))
;	 (service provenance-service-type)
         ;(service gnome-desktop-service-type)
         ;(service mate-desktop-service-type)
         ;(service xfce-desktop-service-type)
         (service enlightenment-desktop-service-type)
                  my-slim-service)
       (remove (lambda (service)
                       (memq (service-kind service)
                             (list
                               ;network:
                               ;dhcp-client-service-type
                               sane-service-type
                               ;network-manager-service-type
                               ;wpa-supplicant-service-type
                               ;modem-manager-service-type
                               ;display manager:
                               gdm-service-type
                               ;console/mingetty:
                               console-font-service-type
                               mingetty-service-type
                               ;systemd:
                               ;dbus-root-service-type
                               geoclue-service-type
                               cups-pk-helper-service-type
                               ;upower-service-type
                               syslog-service-type)))
               %desktop-services)))

(define my-users
  (cons
    (user-account
      (name "foo")
      (group "users")
      (supplementary-groups '("wheel"
			     "audio"
			     "video")))
    %base-user-accounts))

(define my-os
  (operating-system
          (bootloader my-bootloader)
          (host-name "console")
          (file-systems
                (cons (file-system
                           (device (file-system-label "my-root"))
                           (mount-point "/")
                           (type "ext4"))
                      %base-file-systems))
          (timezone "America/Boise")
          (services my-services)))

my-os
