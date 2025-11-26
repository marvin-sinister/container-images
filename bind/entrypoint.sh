#!/bin/sh
# check if default config is pressent
if [ -e "/etc/bind/named.conf.d/marvinsinister.default_config" ]; then
  echo "Default config found, applying env."
  # check BIND_RNDC_KEY is defined, generate key if not, set if defined
  if [ -z "$BIND_RNDC_KEY" ]; then
    # check if key doesn't exist, generate it
    if ! [ -e "/etc/bind/named.conf.d/rndc.key" ]; then
      echo "Generating rndc.key."
      /usr/sbin/rndc-confgen | head -5 | tail -4 > /etc/bind/named.conf.d/rndc.key
    fi
  else
    # if defined, set key
    echo "Setting rndc.key"
    cat > /etc/bind/named.conf.d/rndc.key << EOF
key "rndc-key" {
  algorithm hmac-sha256;
  secret "$BIND_RNDC_KEY";
};
EOF
  fi

  # if port isn't defined, use default
  if [ -z "$BIND_PORT" ]; then
    export BIND_PORT=5053
  fi

  # if port isn't defined, use default
  if [ -z "$BIND_RNDC_PORT" ]; then
    export BIND_RNDC_PORT=5953
  fi

  # replace ports in default config
  echo "Configuring port $BIND_PORT."
  sed -i "s/\$BIND_PORT/$BIND_PORT/g" /etc/bind/named.conf.d/marvinsinister.named.conf.options
  echo "Configuring rndc port $BIND_RNDC_PORT."
  sed -i "s/\$BIND_RNDC_PORT/$BIND_RNDC_PORT/g" /etc/bind/named.conf.d/marvinsinister.named.conf.controls
else
  echo "Default config not found, nothing applied from env."
fi

# run server
exec /usr/sbin/named -g -4
