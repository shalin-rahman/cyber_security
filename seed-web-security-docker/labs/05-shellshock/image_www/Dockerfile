FROM handsonsecurity/seed-server:apache-php
RUN cp /bin/bash /bin/bash_shellshock
COPY vul.cgi /usr/lib/cgi-bin/vul.cgi
COPY safe.cgi /usr/lib/cgi-bin/safe.cgi
RUN chmod +x /usr/lib/cgi-bin/vul.cgi /usr/lib/cgi-bin/safe.cgi
