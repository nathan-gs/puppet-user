class user (
	$email,
	$home = undef,
	$shell = "/bin/bash", 
	$id = undef, 
	$password, 
	$groups = undef, 
	$system = false,
	$ssh_public = undef,
	$ssh_type = 'ssh-rsa'
) {

        $username = $name
	if ($home == undef) {
		$real_home = "/home/$username"
	} else {
		$real_home = $home
	}
	

        user { $username:
		comment => "$email",
                    home    => $real_home,
                    shell   => $shell,
                    uid     => $id,
		    password => $password,
		    groups  => $groups,
#		    system => $system,
            }

            group { $username:
                    gid     => $id,
                    require => User[$username]
            }

            file { $real_home:
                    ensure  => directory,
                    owner   => $username,
                    group   => $username,
                    mode    => 750,
                    require => [ User[$username], Group[$username] ]
            }

            file { "${real_home}/.ssh":
                    ensure  => directory,
                    owner   => $username,
                    group   => $username,
                    mode    => 700,
                    require => File[$real_home]
            }


            # now make sure that the ssh key authorized files is around
            file { "${real_home}/.ssh/authorized_keys":
                    ensure  => present,
                    owner   => $username,
                    group   => $username,
                    mode    => 600,
                    require => File["${real_home}/.ssh"]
            }
	if ($ssh_public != undef) {
		ssh_authorized_key{ "${username}":
        	    ensure  => present,
                    key     => $ssh_public,
                    type    => $ssh_type,
                    user    => $username,
                    require => File["${real_home}/.ssh/authorized_keys"]

		}
	}
}
