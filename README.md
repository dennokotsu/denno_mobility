# Denno Mobility

## Get started

```sh
git clone https://github.com/dennokotsu/denno_mobility
cd denno_mobility/ops

bash setup.sh your-domain.example.com
# "Setup succeeded!" is expected.
# And `.env` is generated.

docker compose up -d

docker compose run --rm web bin/rails db:create
docker compose run --rm web bin/rails db:migrate

# Create an initial company and the admin user of it.
docker compose run --rm web bin/rake db:initial_company_user"[Your company name,your-company-code]"
```

```
事業者ID: your-company-code
ユーザーID: company_1_admin
パスワード: 0123...xxxx
```

`your-company-code` は ID になります．後から変更する場合は DB を直接操作する必要があります．

`https://your-domain.example.com/` にアクセスし，先程得た「事業者 ID」「ユーザー ID」「パスワード」を用いてログイン出来ます．

## Update company setting

```sh
docker compose run --rm web bin/rails c
```

For example:

```ruby
company = Company.find_by!(identifier: "your-company-code")

company.update!(setting_data: {
  "chat_type" => "all",
  "user_statuses" => %w[
    空車
    実車
    回送
  ],
  "user_attribute" => [
    {
      "name" => "something",
      "display_name" => "何かのデータ",
      "type" => "text",
      "require" => true,
      "default" => "デフォルト",
      "placeholder" => "入力例",
    },
    {
      "name" => "something_data_2",
      "display_name" => "何かのデータ2",
      "type" => "text",
      "require" => false,
      "default" => "",
      "placeholder" => nil
    },
  ],
  "slip_attribute" => [
    {
      "name" => "something_data",
      "display_name" => "何かの伝票データ",
      "type" => "text",
      "require" => false,
      "default" => "",
      "placeholder" => nil,
      "user_edit" => true
    },
  ],
})
```

For more details, refer [Company.example_setting_data method](/app/models/company.rb)

## Destroy all

```sh
docker compose run --rm -e DISABLE_DATABASE_ENVIRONMENT_CHECK=1 web bin/rails db:drop
```

## Backup & Restore

### Backup

```sh
docker compose stop https-portal
docker compose exec db mysqldump db > db-snapshot.sql
```

Keep `setup.sh`, `db-snapshot.sql`, `.env` and `docker-compose.yml`.

If you need, keep also `nginx` directory.

### Restore

Place 4 files.

Restore from `db-snapshot.sql`.

```sh
# To create 2 directories for DB and Nginx log.
bash setup.sh

# Restore web server from .env.
docker compose up -d

# Restore DB from the snapshot file.
docker compose run --rm web bin/rails db:create
docker compose exec -T db mysql db < db-snapshot.sql
```

---

## Development

```sh
asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf install
bin/setup

bin/rails s
```

Access to https://localhost:3001/

Login with

- Company code `example`
- User ID `user1`
- Password `password`
