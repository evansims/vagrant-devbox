# vagrant-devbox

Avast, me hearties! This here be my [Vagrant](http://vagrantup.com/) setup for PHP development. It be includin' Nginx, MySQL, MongoDB, memcached and, as one might be expectin', PHP. It also has odds and ends a code wielding swashbuckler such as yourself might use, such as [Sass](http://sass-lang.com/).

Note — This project is inspired by [Dirk Pahl's work](https://github.com/dirkaholic/vagrant-php-dev-box) but is not a fork of it.

## Install

1. Install VirtualBox and Vagrant. [Duh.](http://vagrantup.com/v1/docs/getting-started/index.html)
2. Grab a box. I built this package to target "base", and I expect you to be using the precise64 box. You'll need to make modifications if this isn't the case. You can install this box by using `vagrant box add phpdevbox http://files.vagrantup.com/precise64.box`
3. Clone this here repository.
4. Install submodules with a quick `git submodule update --init`
5. Bring everything online with `vagrant up`. Puppet will deal with installation and configuration of the services.
6. You can access your server at http://localhost:8080
