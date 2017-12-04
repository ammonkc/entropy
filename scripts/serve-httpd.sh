#!/usr/bin/env bash

declare -A params=$6     # Create an associative array
paramsTXT=""
if [ -n "$6" ]; then
    for element in "${!params[@]}"
    do
        paramsTXT="${paramsTXT}
        SetEnv ${element} \"${params[$element]}\""
    done
fi

block="
<VirtualHost *:${3:-80}>
    ServerAdmin acasey@panda-group.com
    ServerName $1
    ServerAlias www.$1
    DocumentRoot "$2"
    $paramsTXT

    <Directory $2>
      Options -Indexes +FollowSymLinks +MultiViews
      AllowOverride All
      Require all granted
    </Directory>

    # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
    # error, crit, alert, emerg.
    # It is also possible to configure the loglevel for particular
    # modules, e.g.
    #LogLevel info ssl:warn

    ErrorLog \${APACHE_LOG_DIR}/$1-error.log
    CustomLog \${APACHE_LOG_DIR}/$1-access.log combined
    LogLevel warn

</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
"

echo "$block" > "/etc/httpd/sites-available/$1.conf"
ln -fs "/etc/httpd/sites-available/$1.conf" "/etc/httpd/sites-enabled/$1.conf"

blockssl="<IfModule mod_ssl.c>
    <VirtualHost *:{$4:-443}>

        ServerAdmin acasey@panda-group.com
        ServerName $1
        ServerAlias www.$1
        DocumentRoot "$2"
        $paramsTXT

        <Directory "$2">
            Options -Indexes +FollowSymLinks +MultiViews
            AllowOverride All
            Require all granted
        </Directory>

        # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
        # error, crit, alert, emerg.
        # It is also possible to configure the loglevel for particular
        # modules, e.g.
        #LogLevel info ssl:warn

        ErrorLog \${APACHE_LOG_DIR}/$1-error.log
        CustomLog \${APACHE_LOG_DIR}/$1-access.log combined

        # For most configuration files from conf-available/, which are
        # enabled or disabled at a global level, it is possible to
        # include a line for only one particular virtual host. For example the
        # following line enables the CGI configuration for this host only
        # after it has been globally disabled with "a2disconf".
        #Include conf-available/serve-cgi-bin.conf

        #   SSL Engine Switch:
        #   Enable/Disable SSL for this virtual host.
        SSLEngine on

        #   A self-signed (snakeoil) certificate can be created by installing
        #   the ssl-cert package. See
        #   /usr/share/doc/httpd/README.Debian.gz for more info.
        #   If both key and certificate are stored in the same file, only the
        #   SSLCertificateFile directive is needed.
        #SSLCertificateFile  /etc/ssl/certs/ssl-cert-snakeoil.pem
        #SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key

        SSLCertificateFile      /etc/httpd/ssl/$1.crt
        SSLCertificateKeyFile   /etc/httpd/ssl/$1.key

        #   Server Certificate Chain:
        #   Point SSLCertificateChainFile at a file containing the
        #   concatenation of PEM encoded CA certificates which form the
        #   certificate chain for the server certificate. Alternatively
        #   the referenced file can be the same as SSLCertificateFile
        #   when the CA certificates are directly appended to the server
        #   certificate for convinience.
        #SSLCertificateChainFile /etc/httpd/ssl.crt/server-ca.crt

        #   Certificate Authority (CA):
        #   Set the CA certificate verification path where to find CA
        #   certificates for client authentication or alternatively one
        #   huge file containing all of them (file must be PEM encoded)
        #   Note: Inside SSLCACertificatePath you need hash symlinks
        #    to point to the certificate files. Use the provided
        #    Makefile to update the hash symlinks after changes.
        #SSLCACertificatePath /etc/ssl/certs/
        #SSLCACertificateFile /etc/httpd/ssl.crt/ca-bundle.crt

        #   Certificate Revocation Lists (CRL):
        #   Set the CA revocation path where to find CA CRLs for client
        #   authentication or alternatively one huge file containing all
        #   of them (file must be PEM encoded)
        #   Note: Inside SSLCARevocationPath you need hash symlinks
        #    to point to the certificate files. Use the provided
        #    Makefile to update the hash symlinks after changes.
        #SSLCARevocationPath /etc/httpd/ssl.crl/
        #SSLCARevocationFile /etc/httpd/ssl.crl/ca-bundle.crl

        #SSLVerifyClient require
        #SSLVerifyDepth  10

        <FilesMatch \"\.(cgi|shtml|phtml|php)$\">
            SSLOptions +StdEnvVars
        </FilesMatch>
        <Directory /usr/lib/cgi-bin>
            SSLOptions +StdEnvVars
        </Directory>

        BrowserMatch \"MSIE [2-6]\" \
            nokeepalive ssl-unclean-shutdown \
            downgrade-1.0 force-response-1.0
        # MSIE 7 and newer should be able to use keepalive
        BrowserMatch \"MSIE [17-9]\" ssl-unclean-shutdown

    </VirtualHost>
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
"

echo "$blockssl" > "/etc/httpd/sites-available/$1-ssl.conf"
ln -fs "/etc/httpd/sites-available/$1-ssl.conf" "/etc/httpd/sites-enabled/$1-ssl.conf"
