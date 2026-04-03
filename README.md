Репозиторий с образами anet-server для docker

Порты задаются через `.env`

Если не хочется чтобы при смерти сервера падало вообще все, то в `client.toml` ставим `manual_routing = true`

v0.5.1 - Кривая 
Я хоть и создал тег но anet-auth не поднимется, потому что в исходном репозитории нету миграций

`manage.sh` не соответствует последней версии и будет редактироватся, но даже так 

## Quick start

  1. Клонируем репозиторий
```sh 
clone https://git.lisenblsh.art/lisenblsh/anet-docker.git
cd anet-docker
```
  2. Копируем .env.example в .env, и меняем переменные на нужные
  ```sh
cp .env.example .env
```
  3. Генерируем конфиг для сервера
  ```sh
./manage.sh -g
```
  4. Запускаем сервер
```sh
docker compose up -d
```

  5. Генерируем конфиг для клиента
```sh
./manage.sh -c <user name> > client.toml
```
  6. Отдаем конфиг пользователю (себе, кошке и котятам)

source - https://github.com/ZeroTworu/anet
