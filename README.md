# Allmon3

![GitHub](https://img.shields.io/github/license/AllStarLink/Allmon3)

![Bootstrap](https://img.shields.io/badge/bootstrap-%23563D7C.svg?style=for-the-badge&logo=bootstrap&logoColor=white) ![PHP](https://img.shields.io/badge/php-%23777BB4.svg?style=for-the-badge&logo=php&logoColor=white) ![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)

Allmon is the standard web-based montitoring and management for the AllStarLink
application. Allmon3 is the next generation of the venerable Allmon2 that is 
rewritten for performance, scalability, and responsiveness.

## Design Goals
Allmon3 features and functionality shall be governed by the following guidelines:

* Use of modern web responsive design for usability on all device form factors and screen sizes
* Clear separation between long-running tasks and client-based display updates
* Permit reduced workload on potentially slow repeater site links by cleanly supporting the ability to run only the pollers on the device controlling the repeater and run the dashaboard in the cloud; easy prevention of unnecessary web traffic, spidering, etc.
* Prioritization of the common use cases of AllStarLink for feature enhancements

## Community
All code of Allmon3 not otherwise licensed (e.g., Bootstrap, etc.) is licensed
under the [GNU Affero General Public License v3](https://www.gnu.org/licenses/why-affero-gpl.html).
The choice of the AGPLv3 promotes giving back to the amateur radio and
ASL communities.

## Requirements
Allmon3 requires the following:

* PHP with the PHP-ZMQ package
* Apache 2.4 configured to host PHP-based applications
* Python3 with the Python ZMQ package

Note: Using Nginx is possible as an alternative to Apache but
packaging and documentation assumes Apache.

## Installation

### Installation for Packages
The following directions can be used to install with the Debian package

1. Install the prerequisites

```
apt install -y apache2 php7.4-fpm php-zmq python3-zmq make
```

2. Install Allmon3's deb file (use the correct .deb file name)
```
deb -i allmon3_0.9.2-1_all.deb
```

3. Skip the next section and resume directions at **Configuration**

### Installation from Git
The following directions can be used to install from the Git sources.

1. Allmon3 requires Python, the Python ZMQ module, Apache, PHP 7 or 8,
and the PHP ZMQ module. On Debian-based systems this can be installed
as followed (example uses Debian 11).
```
apt install -y apache2 php7.4-fpm php-zmq python3-zmq make
```

Note that is is **strongly** recommended to use the PHP-FPM FastCGI
style of PHP invocation rather than the old mod_php methods. This
allows Apache to be operated in the efficient mpm_workers mode to 
support HTTP/2 and offloads PHP execution to the more-efficient
php-fpm daemon. See "Configuring Apache" below for more information.

2. Install the application using make
```
make install
```

This will install everything into `/usr`, `/etc`, and `/lib`. 
The applications will install in `/usr/bin`.
Configuration will be stored in `/etc/allmon3`.
The web files will be in `/usr/share/allmon3` while examples and
other (future) documentation will be in `/usr/share/doc/allmon3`.
Systemd service files will be installed in `/lib/systemd/system`.

Installation is relocatable using the following make(1) parameters:

* `prefix=` will alter the core prefix of `/usr` files and is most
commonly used to install into `/usr/local`. This is recommended
when you care about distro/FHS/packaging fidelity. This relocates
items installed `/usr/bin` and `/usr/share` to, for example,
`/usr/local/bin` and `/usr/local/share`.

* `sysconfdir=` will alter the location of the configuration files to 
`$sysconfdir/allmon3`.

* `sysd_service=` will alter the location of the systemd service files.
The only practical alternative to `/lib/systemd/system` is `/etc/systemd/system`.

* `datadir=` will relocate the web application portion of Allmon3
to `$datadir/allmon3`.

* `docdir=` will relocate the documentation and examples to `$docdir/allmon3`.

For example:

```
make install prefix=/usr/local sysconfdir=/usr/local/etc datadir=/var/www/html sysd_service=/etc/systemd/system
```

All the above variables are also modified further by the `destdir=` variable
which will install the complete system in an alternative location. This is
only really useful for testing in development.

For example:

```
make install destdir=/path/to/temp/location
```

## Configuration

Edit `/etc/allmon3/allmon3.ini` for at least one ASL AMI interface. Each node
must have a separately-numbered `monport=` and `cmdport=` value. It's recommended
to start with port 6750 for `monport` and 6850 for `cmdport`
 and count up from there for each node configured in the .ini file. 
Here's an example for monitoring three ASL Nodes:

```
[50815]
ip=172.17.16.36
user=admin
pass=password
monport=6750
cmdport=6850

[460180]
ip=172.17.16.217
user=admin
pass=password
monport=6751
cmdport=6851

[48496]
ip=208.167.248.86
user=admin
pass=password
monport=6752
cmdport=6852
```

Enable and start the services
```
systemctl daemon-reload
systemctl enable asl-statmon@NODE
systemctl enable asl-cmdlink@NODE
systemctl start asl-statmon@NODE
systemctl start asl-cmdlink@NODE
```

In the above, replace "NODE" with your ASL node ID - for example:

```
systemctl enable asl-statmon@1999
systemctl enable asl-cmdlink@1999
systemctl start asl-statmon@1999
systemctl start asl-cmdlink@1999
```

If you have multiple nodes, you need one each of `asl-statmon@NODE` and `asl-cmdlink@NODE` per node. Multiple nodes on the same syste should use the `multinodes=/colocated_on=` structure described in `allmon3.ini`.

Note, that for the web interface a separate, distinct configuration file
can be placed in `/etc/allmon3/allmon3-web.ini`
which will be used **in place of** the common `/etc/allmon3/allmon3.ini`
for the website only. No configuration is need to use a web-specific
configuration when `/etc/allmon3/allmon3.ini` and `/etc/allmon3/allmon3-web.ini`
would have identical contents.

## Usernames / Passwords for the Site
Usernames and passwords are stored in the `api/passwords.php` file in
the webroot directory for Allmon3. The default-configured username
and password combination is `user / password`. **You *must* change this**.

Set a password and remove the default user with the following:

1. Change to the API directory - `cd /usr/share/allmon3/api`

2. `php password-generate.php USERNAME` will prompt you for a username and password. It will
look something like this:

```
$ php password-generate.php N8EI
        Password: supersecretpass
Confirm Password: supersecretpass
Copy the following line into passwords.php including the ending comma!

'N8EI' => '$argon2id$v=19$m=65536,t=4,p=1$TVpxbGpRYzJVekZ3MEYydA$QXfIeHH15UztDsbBa6tzKzFgYxwsDgt7FLx9GPfJ1Q4',

```

3. Copy the line specified into the file `passwords.php` and delete the row labeled `user`. For example,
the stock file looks like this:

```
## DO NOT EDIT ANYTHING BEFORE THIS LINE!!

'user' => '$argon2id$v=19$m=65536,t=4,p=1$bHhmVEI5RzduN0Z4VE9VRA$Y+KPUyBIwC3jumcSzBtVI3vFupmtCt9F4ejPtoYK6uc',

## DO NOT EDIT ANYTHING AFTER THIS LINE!!

```

After making this change you should see something like:

```
## DO NOT EDIT ANYTHING BEFORE THIS LINE!!

'N8EI' => '$argon2id$v=19$m=65536,t=4,p=1$TVpxbGpRYzJVekZ3MEYydA$QXfIeHH15UztDsbBa6tzKzFgYxwsDgt7FLx9GPfJ1Q4',

## DO NOT EDIT ANYTHING AFTER THIS LINE!!
```
Note that the trailing comma is important!!

You can add more than one user to the file by simply adding multiple lines.

## Allmon3 Web Configuration

Allmon3 has two configuration files to consider. The first is `/etc/allmon3/config.php`. This
is where the site name and optional logo can be placed. In a future release, these
two items will be moved to an .ini file.

The second is `/etc/allmon3/menu.ini` for creating a customized menu structure. See `api/menu.ini.example`
for complete instructions on how to configure a menu. To enable a menu, simply
rename `menu.ini.example` to `menu.ini` and edit to taste.

Certain colors are able to be modified by editing `/usr/share/allmon3/css/custom.css`. See the internal comments
for directions.

## Configuring Apache 

### Basic Application Configuration
For best results, Apache should be configure according to these directions not based
on historical configurations from Allmon3, Supermon, etc. These directions are for
Debian-based systems. Due to widely varying web server configurations, the Debian
package of allmon3 does not (yet?) try to enable itself within the webserver
configuration.

1. If Apache2 is already installed, remove any Apache configuration for mod_php:

```
a2dismod php7.4
a2dismodapt mpm_prefork
a2enmod mpm_event
apt remove libapache2-mod-php libapache2-mod-php7.4
apt install apache2
apt autoremove
```

Note that the extra `apt install apache2` fixes apache2 as a requested package
which may not be the case depending on how it was already installed.

2. Ensure that PHP-FPM is installed. On Debian-based systems do `apt install php7.4-fpm`
(or use the correct version for your system, php7.4-fpm is for stock Debian 11).

3. Enable PHP-FPM as the handler for PHP in apache with `a2enconf php7.4-fpm`

4. Enable the proxy_fcgi module to hand off to PHP-FOM with `a2enmod proxy_fcgi`

5. Edit `/etc/php/7.4/fpm/pool.d/www.conf` and set the following values:
```
pm = dynamic
pm.max_children = 25
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 10
pm.max_requests = 1000
```

6. Restart php-fpm with `systemctl restart php7.4-fpm`

7. Edit `/etc/apache2/sites-available/000-default.conf` to look like the following:
```
<VirtualHost *:80>
	ServerAdmin YOUREMAIL@ADDRESS
	DocumentRoot /var/www/html
	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined env=!nolog
	SetEnvIf Request_URI "api/asl-statmon.php" nolog
</VirtualHost>
```

8. Execute `cp /etc/allmon3/apache.conf /etc/apache2/conf-available/allmon3.conf`

9. Enable the Apache Allmon3 configuration: `a2enconf allmon3`

10. Restart Apache: `systemctl restart apache2`

11. If there is no other content at the root of the webserver Allmon3 is installed
on, create `/var/www/html/index.html` with the following contents:

```
<html>
	<head>
		<meta http-equiv="Refresh" content="0; URL=/allmon3/" />
	</head>
</html>
```

This will direct people to the Allmon3 index directly.

### Important Web Log Performance Consideration

As a "modern" web application, Allmon3 makes *extensive* use of AJAX callbacks
to the webserver. Depending on your configuration this could results in dozens
or hundreds of log entries per second in the Apache or NGINX access logs. For 
a standard PC-type system (normal hard drive or a virtual machine/VPS), this is not 
a problem. However, as many people install ASL and Allmon on a Raspberry Pi with
an SD Card, this behavior can quickly wear out the card! In these situations, suppressing
access logging from the `api/asl-statmon.php` URI is essential.

For Apache you can take the following steps:

1. For every configuration location of `AccessLog` or `CustomLog` append
the statement `env=!nolog`.

2. Add a single configuration of `SetEnvIf Request_URI "api/asl-statmon.php" nolog`

For example, in a standard vhost-style configuration:

```
CustomLog ${APACHE_LOG_DIR}/access.log combined env=!nolog
SetEnvIf Request_URI "api/asl-statmon.php" nolog
```

## Three-Tier Structure
Allmon3 is organized around a tierd structure: Asterisk AMI, message poller daemons (asl-statmon
and asl-cmdlink), and the web client. In order to reduce webserver and Asterisk AMI load experience
in Allmon2 (especially for systems using workers with php-fpm) and on Asterisk AMI calls, 
one asl-statmon and asl-cmdlink process oprates against each Asterisk AMI port as a 
[0MQ Messaging Publisher](https://www.zeromq.org/) messaging bus. This results in 
polling AMI one time per cycle and distributing the information to many web clients 
efficiently. It also allows for interesting things such as different views and abstractions 
of clusters of Asterisk servers and it permits polling of many nodes running on the same
Asterisk server to be efficient. This structure results in load reductions against busy
nodes of up to 91% in real-world testing.

A generalized architecture is as follows:

![Allmon3 Diagram](https://raw.githubusercontent.com/AllStarLink/Allmon3/develop/.github/Allmon3%20Tier.jpg)
