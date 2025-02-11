#!/usr/bin/env bash

# Replace with actual credentials
USER_ID=""
PASSWORD=""

# The access portal URL
PORTAL_URL="http://10.254.254.41/0/up/"

# Log file location
LOGFILE="/var/log/portal-check.log"

# Function to log messages with timestamps
log_message() {
  local MSG="$1"
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $MSG" >> "$LOGFILE"
}

# Function that performs the login
do_login() {
  log_message "Attempting to log in..."

  # Attempt login, saving output in a variable if you need to parse/verify
  RESPONSE=$(curl -s -X POST \
    --data "user=$USER_ID&pass=$PASSWORD&login=Login" \
    "$PORTAL_URL")

  # OPTIONAL: Check RESPONSE for some indication of successful login
  # This depends on the actual HTML or JSON response from your portal.
  # For demonstration, we'll just log success unconditionally.
  log_message "Login POST request sent. (Inspect 'RESPONSE' if needed)"

  # Give it a short wait to re-check connectivity
  sleep 2
}

# Function to check if the portal is reachable
check_portal_reachable() {
  # We use a short 3-second timeout; adjust as needed.
  curl -s --connect-timeout 3 "$PORTAL_URL" > /dev/null
}

# Function to check internet connectivity
check_internet() {
  # Pinging a stable host (Google DNS). You can change to any known IP.
  ping -c 1 -W 2 8.8.8.8 &> /dev/null
}

# Main loop
while true; do

  # 1. Check if internet is working
  if check_internet; then
    # Internet is up
    log_message "Internet is connected."
  else
    # Internet is down
    log_message "Internet is NOT connected. Checking portal..."

    # 2. Check if the portal is reachable
    if check_portal_reachable; then
      log_message "Portal is reachable. Attempting login..."
      do_login

      # 3. Verify internet after login attempt
      if check_internet; then
        log_message "Internet connected after login."
      else
        log_message "Internet still NOT connected after login attempt."
      fi
    else
      # Portal is not reachable
      log_message "Portal is NOT reachable. Waiting..."
    fi
  fi

  # Sleep before next check. Adjust according to your preference.
  sleep 30
done
