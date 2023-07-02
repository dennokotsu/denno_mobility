set -ex

mkdir -p db
sudo chown -R 999:999 db

mkdir -p nginx
sudo chown -R 1:1 nginx

if [ ! -f .env ]; then
  cat <<EOF > .env
SECRET_KEY_BASE=$(cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 128 | head -1)
DOMAIN=$1
EOF
fi
chmod 600 .env

echo "Setup succeeded!"
