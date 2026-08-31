#!/bin/bash_shellshock
# ==============================================================================
# VULNERABILITY: Shellshock (CVE-2014-6271)
# ==============================================================================
# DEFINITION: Older versions of Bash had a severe bug where they would not stop
# parsing function definitions passed via environment variables.
# If an environment variable started with `() { :;};`, Bash would parse the
# function, but then mistakenly EXECUTE any trailing commands immediately when
# the Bash shell started.
#
# HOW IT WORKS HERE: Apache passes HTTP headers (like User-Agent) to CGI scripts
# as environment variables (e.g., HTTP_USER_AGENT). Because this script uses
# `#!/bin/bash_shellshock` (a vulnerable version), the attacker's trailing
# commands in the User-Agent header are executed with web server privileges.
# ==============================================================================

echo "Content-Type: text/plain"
echo ""
echo "SEED Shellshock Vulnerable CGI Endpoint (vul.cgi)"
echo "Environment variable evaluation active."
